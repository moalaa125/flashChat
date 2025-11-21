# Flash Chat ⚡

A modern real-time messaging application built with Flutter and Firebase. This app features a beautiful UI with glassmorphism effects and secure authentication.

## ✨ Features

* **Real-time Messaging:** Instant chat updates using Cloud Firestore.
* **Secure Authentication:** User login and registration via Firebase Auth.
* **Modern UI:** Custom "Apple VisionOS" style glass buttons and animations.
* **Animations:** Hero animations and custom motion effects.

## 🚀 How to Run the App

**Note:** For security reasons, the Firebase configuration file is not included in this repository.

To run this app locally, you must provide your own Firebase project:

1.  Clone the repository.
2.  Create a new project on the [Firebase Console](https://console.firebase.google.com/).
3.  Add an Android app to your Firebase project with the package name: `com.example.flash_chat` (check your AndroidManifest.xml to confirm).
4.  Download the **`google-services.json`** file.
5.  Place the file in this directory:
    ```
    android/app/google-services.json
    ```
6.  Run the following commands:
    ```bash
    flutter pub get
    flutter run
    ```

## 🛠️ Tech Stack

* [Flutter](https://flutter.dev/) - UI Toolkit
* [Firebase](https://firebase.google.com/) - Backend (Auth & Firestore)
* [Liquid Glass Renderer](https://pub.dev/packages/liquid_glass_renderer) - For UI effects