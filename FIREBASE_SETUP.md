# Firebase Configuration & Setup Guide — Skill-Link 2.0

This guide details how to configure your Firebase project and link it to Skill-Link.

---

## 1. Firebase Project Creation

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it (e.g. `skill-link-prod`).
3. Enable or disable Google Analytics based on your preference and create the project.

---

## 2. Enable Required Services

In the Firebase Console for your project:

### A. Authentication
1. Navigate to **Build > Authentication > Sign-in method**.
2. Enable **Email/Password**.
3. (Optional) Customize the Password Reset template under **Templates**.

### B. Cloud Firestore
1. Navigate to **Build > Firestore Database**.
2. Click **Create Database**.
3. Choose your preferred primary region (e.g., `asia-south1` for India).
4. Start in **Production mode** (our `firestore.rules` will be deployed directly).

### C. Firebase Storage
1. Navigate to **Build > Storage**.
2. Click **Get Started** and select the same region as Firestore.
3. Accept default bucket settings.

---

## 3. Registering Client Apps

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Log in to Firebase CLI:
   ```bash
   firebase login
   ```
3. Run the configuration wizard from the project root:
   ```bash
   flutterfire configure --project=YOUR_PROJECT_ID
   ```
4. Select `android`, `ios`, `web`, and `windows`. This will automatically update `lib/firebase_options.dart`.

### Option B: Manual Configuration

If configuring manually, update `lib/firebase_options.dart` with your values from the Firebase Console Project Settings:

```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static const bool isConfigured = true; // Set to true

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}
```

For Android builds:
- Download `google-services.json` from Project Settings > General > Your Android App.
- Place it at `android/app/google-services.json` (Note: This file is ignored by `.gitignore` to prevent secret leakage).

---

## 4. Deploying Rules & Indexes

Using Firebase CLI from the repository root:

```bash
# 1. Login to Firebase CLI
firebase login

# 2. Select your Firebase project
firebase use YOUR_PROJECT_ID

# 3. Deploy Firestore Security Rules & Indexes
firebase deploy --only firestore

# 4. Deploy Storage Rules
firebase deploy --only storage
```

---

## 5. Local Development with Firebase Emulator Suite

Skill-Link includes complete local emulator configurations in `firebase.json`.

1. Install emulator dependencies:
   ```bash
   firebase setup:emulators:firestore
   firebase setup:emulators:storage
   ```
2. Start the emulators:
   ```bash
   firebase emulators:start
   ```
   The emulator UI will be available at `http://localhost:4000`.

3. Run Flutter in Emulator Mode:
   ```bash
   flutter run -d chrome --dart-define=USE_EMULATOR=true
   ```
