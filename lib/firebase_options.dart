// File generated for Skill-Link
// Replace placeholder values below with your Firebase project credentials or run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const bool isConfigured = false; // Set to true once credentials are added

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'FIREBASE_WEB_API_KEY_PLACEHOLDER',
    appId: '1:1234567890:web:skilllinkplaceholder',
    messagingSenderId: '1234567890',
    projectId: 'skill-link-app',
    authDomain: 'skill-link-app.firebaseapp.com',
    storageBucket: 'skill-link-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'FIREBASE_ANDROID_API_KEY_PLACEHOLDER',
    appId: '1:1234567890:android:skilllinkplaceholder',
    messagingSenderId: '1234567890',
    projectId: 'skill-link-app',
    storageBucket: 'skill-link-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FIREBASE_IOS_API_KEY_PLACEHOLDER',
    appId: '1:1234567890:ios:skilllinkplaceholder',
    messagingSenderId: '1234567890',
    projectId: 'skill-link-app',
    storageBucket: 'skill-link-app.appspot.com',
    iosBundleId: 'com.skilllink.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'FIREBASE_WINDOWS_API_KEY_PLACEHOLDER',
    appId: '1:1234567890:windows:skilllinkplaceholder',
    messagingSenderId: '1234567890',
    projectId: 'skill-link-app',
    storageBucket: 'skill-link-app.appspot.com',
  );
}
