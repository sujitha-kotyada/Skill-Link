import 'package:flutter/material.dart';
import 'app.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (supports live configuration, emulator mode, or safe preview)
  await FirebaseService.initialize();

  runApp(const SkillLinkApp());
}
