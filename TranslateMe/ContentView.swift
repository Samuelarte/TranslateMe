//
//  ContentView.swift
//  TranslateMe
//
//  Created by Samuel Lopez on 3/28/25.
//

import SwiftUI
import FirebaseFirestore

// A single "history" item in our Firestore (and UI list)
struct TranslationRecord: Identifiable {
    var id: String       // Document ID from Firestore
    var originalText: String
    var translatedText: String
    var timestamp: Date
}

struct ContentView: View {
    // MARK: - State
    @State private var sourceText: String = ""             // What user types
    @State private var translatedText: String = ""          // Result from MyMemory
    @State private var translations: [TranslationRecord] = [] // History list
    
    // Translate from English to Spanish by default.
    @State private var sourceLang: String = "en"
    @State private var targetLang: String = "es"
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                Text("TranslateMe")
                    .font(.largeTitle)
                    .bold()
                
                // MARK: - Text Fields
                TextField("Enter text to translate", text: $sourceText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // “Translate” button
                Button(action: {
                    performTranslation()
                }) {
                    Text("Translate")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // MARK: - Translated Text Field
                TextField("Translation appears here", text: $translatedText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .disabled(true)  // user can’t edit the translated field
                
                // MARK: - History List
                Text("Translation History")
                    .font(.headline)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(translations) { record in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• \(record.originalText)")
                                    .fontWeight(.semibold)
                                Text("→ \(record.translatedText)")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Erase History Button
                Button(action: {
                    clearHistory()
                }) {
                    Text("Clear History")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchHistory()
        }
    }
}

// MARK: - Private Helper Methods
extension ContentView {
    
    // MARK: Perform Translation
    private func performTranslation() {
        // Check if input exceeds MyMemory's 500-byte limit.
        if sourceText.utf8.count > 500 {
            DispatchQueue.main.async {
                self.translatedText = "Input exceeds 500 bytes limit."
            }
            return
        }
        
        // Build the MyMemory API request.
        // Example: https://api.mymemory.translated.net/get?q=Hello%20World!&langpair=en|es
        let baseURL = "https://api.mymemory.translated.net/get"
        let query = sourceText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?q=\(query)&langpair=\(sourceLang)|\(targetLang)"
        
        guard let url = URL(string: urlString), !sourceText.isEmpty else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let responseData = jsonObject["responseData"] as? [String: Any],
                       let translated = responseData["translatedText"] as? String {
                        
                        DispatchQueue.main.async {
                            self.translatedText = translated
                            self.addToHistory(original: self.sourceText, translated: translated)
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: Add to History (Manual Dictionary Approach)
    private func addToHistory(original: String, translated: String) {
        let docData: [String: Any] = [
            "originalText": original,
            "translatedText": translated,
            "timestamp": Date()
        ]
        
        db.collection("translations").addDocument(data: docData) { error in
            if let error = error {
                print("Error saving translation to Firestore: \(error)")
            } else {
                print("Translation saved to Firestore.")
            }
        }
    }
    
    // MARK: Fetch History (Manual Dictionary Approach)
    private func fetchHistory() {
        db.collection("translations")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching translations: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                print("Fetched \(documents.count) documents from Firestore.")
                DispatchQueue.main.async {
                    self.translations = documents.map { doc in
                        let data = doc.data()
                        let original = data["originalText"] as? String ?? ""
                        let translated = data["translatedText"] as? String ?? ""
                        let ts = data["timestamp"] as? Timestamp
                        let date = ts?.dateValue() ?? Date()
                        return TranslationRecord(
                            id: doc.documentID,
                            originalText: original,
                            translatedText: translated,
                            timestamp: date
                        )
                    }
                }
            }
    }
    
    // MARK: Clear History (Manual Dictionary Approach)
    private func clearHistory() {
        let batch = db.batch()
        db.collection("translations").getDocuments { snapshot, err in
            if let snapshot = snapshot {
                for doc in snapshot.documents {
                    batch.deleteDocument(doc.reference)
                }
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("Error clearing translations: \(batchError)")
                    } else {
                        print("History cleared.")
                    }
                }
            }
        }
    }
}

