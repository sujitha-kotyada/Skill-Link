# Development Setup & Local Environment Guide — Skill-Link 2.0

## 1. System Requirements

- **Operating System:** Windows 10/11, macOS, or Linux.
- **Flutter SDK:** Version 3.22.0 or higher (Installed: 3.41.4 Stable).
- **Dart SDK:** Version 3.4.0 or higher (Installed: 3.11.1 Stable).
- **Node.js & npm:** Required for Firebase CLI tools (`firebase-tools`).
- **Web Browser:** Google Chrome or Microsoft Edge.
- **Android Studio (Optional for Android device runs):** Android SDK Platform-Tools and Command-line Tools.

---

## 2. Setting Up the Repository

```bash
# 1. Clone repository or navigate to root
cd Skill-Link

# 2. Get Flutter package dependencies
flutter pub get

# 3. Verify clean environment
flutter analyze
flutter test
```

---

## 3. Running with Local Firebase Emulators

Using local emulators allows full end-to-end testing with zero cloud costs or live credentials:

1. **Start the Emulators:**
   ```bash
   firebase emulators:start
   ```
   Ports configured in `firebase.json`:
   - Auth Emulator: `9099`
   - Firestore Emulator: `8080`
   - Storage Emulator: `9199`
   - Emulator UI: `http://localhost:4000`

2. **Launch Flutter in Emulator Mode:**
   ```bash
   flutter run -d chrome --dart-define=USE_EMULATOR=true
   ```

---

## 4. Running Against Live Firebase Project

1. Configure `lib/firebase_options.dart` (or run `flutterfire configure`).
2. Run on Chrome:
   ```bash
   flutter run -d chrome
   ```
3. Run on Edge:
   ```bash
   flutter run -d edge
   ```
4. Run on Connected Android Device:
   ```bash
   flutter run -d android
   ```

---

## 5. Building for Production

### Flutter Web Build
```bash
flutter build web --release
```
Artifacts are compiled into `build/web/` ready for Firebase Hosting, Netlify, or Vercel.

### Android APK / App Bundle
```bash
flutter build apk --release
# or for Play Store release:
flutter build appbundle --release
```
Artifacts are generated in `build/app/outputs/flutter-apk/`.
