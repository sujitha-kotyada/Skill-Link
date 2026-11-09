import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _useEmulator = const bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  static bool _isLiveConnected = false;

  static bool get isInitialized => _initialized;
  static bool get isLiveConnected => _isLiveConnected;
  static bool get isUsingEmulator => _useEmulator;

  static Future<void> initialize({bool useEmulator = false}) async {
    if (_initialized) return;

    _useEmulator = useEmulator || const bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      _isLiveConnected = DefaultFirebaseOptions.isConfigured;

      if (_useEmulator) {
        await _connectToEmulators();
      }
    } catch (e) {
      debugPrint('Firebase initialization note: $e');
      // If live credentials are placeholder, Firebase may throw invalid API key
      // in production or during web builds. We mark initialized so app can render.
      _initialized = true;
      _isLiveConnected = false;
    }
  }

  static Future<void> _connectToEmulators() async {
    const host = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
    try {
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseStorage.instance.useStorageEmulator(host, 9199);
      debugPrint('Connected to Firebase Emulators at $host');
    } catch (e) {
      debugPrint('Emulator connection notice: $e');
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
}

