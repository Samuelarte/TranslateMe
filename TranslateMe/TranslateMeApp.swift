//
//  TranslateMeApp.swift
//  TranslateMe
//
//  Created by Samuel Lopez on 3/28/25.
//

import SwiftUI
import FirebaseCore  // Make sure you've added Firebase to your project

@main
struct TranslateMeApp: App {
    
    // Initialize Firebase in the app's init (or in body)
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // The single ContentView for our entire app
            ContentView()
        }
    }
}

