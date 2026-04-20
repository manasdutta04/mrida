import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage (Hive)
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('mandi_cache');
  
  // Load local environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Falling back to platform defaults.");
  }

  // Initialize Firebase
  // On Android, we can rely on the google-services.json for automatic initialization
  // to avoid conflicts with manual options.
  try {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // We still call runApp so the app can show an error or partial UI instead of hanging
  }
  
  runApp(const ProviderScope(child: MridaApp()));
}
