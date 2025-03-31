# Project 6 - *TranslateMe*

Submitted by: **Samuel Lopez**

**TranslateMe** is an app that translates text entered by the user using the MyMemory REST API and stores the translation history in Firebase Firestore. 
Users can input a word, phrase, or sentence, tap the "Translate" button, and see the translated result appear immediately.
The app also maintains a scrollable history of translations, which can be cleared when desired, allowing users to review past translations effortlessly.

Time spent: **10** hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] Users open the app to a TranslationMe home page with a place to enter a word, phrase or sentence, a button to translate, and another field that should initially be empty
- [x] When users tap translate, the word written in the upper field translates in the lower field. The requirement is only that you can translate from one language to another.
- [x] A history of translations can be stored (in a scroll view in the same screen, or a new screen)
- [x] The history of translations can be erased
 
The following **optional** features are implemented:

- [ ] Add a variety of choices for the languages
- [x] Add UI flair

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

## Video Walkthrough

https://youtube.com/shorts/RVtndIfiEWw?feature=share

## Notes

Setting up Firebase Firestore and configuring security rules was challenging. Initially, the app encountered “Missing or insufficient permissions” 
errors when attempting to write and read translation history. Adjusting the Firestore rules for testing and properly configuring Firebase App Check 
was necessary to ensure smooth Firestore operations.
