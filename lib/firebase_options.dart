// File generated for Skill-Link
// Replace placeholder values below with your Firebase project credentials or run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const bool isConfigured = true; // Set to true once credentials are added

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
    apiKey: 'your api key',
    appId: '1:906834929541:web:d1ccaa0ab04a32047586ec',
    messagingSenderId: '906834929541',
    projectId: 'skill-link-2de23',
    authDomain: 'skill-link-2de23.firebaseapp.com',
    storageBucket: 'skill-link-2de23.firebasestorage.app',
    measurementId: 'G-FFZ84N7H57',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDK9VjOlUUCh4syslK28wfRmLnPDSDxISM',
    appId: '1:906834929541:web:d1ccaa0ab04a32047586ec',
    messagingSenderId: '906834929541',
    projectId: 'skill-link-2de23',
    storageBucket: 'skill-link-2de23.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDK9VjOlUUCh4syslK28wfRmLnPDSDxISM',
    appId: '1:906834929541:web:d1ccaa0ab04a32047586ec',
    messagingSenderId: '906834929541',
    projectId: 'skill-link-2de23',
    storageBucket: 'skill-link-2de23.firebasestorage.app',
    iosBundleId: 'com.skilllink.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDK9VjOlUUCh4syslK28wfRmLnPDSDxISM',
    appId: '1:906834929541:web:d1ccaa0ab04a32047586ec',
    messagingSenderId: '906834929541',
    projectId: 'skill-link-2de23',
    storageBucket: 'skill-link-2de23.firebasestorage.app',
  );
}

