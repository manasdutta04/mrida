import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
///
/// This file has been refactored to AVOID HARDCODING sensitive credentials.
/// It reads from the .env file at runtime using flutter_dotenv.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for MRIDA.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not configured.');
    }
  }

  static String get _apiKey => dotenv.get('FIREBASE_API_KEY');
  static String get _projectId => dotenv.get('FIREBASE_PROJECT_ID', fallback: 'mrida-app');
  static String get _senderId => dotenv.get('FIREBASE_MESSAGING_SENDER_ID');

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _apiKey,
    appId: dotenv.get('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: '$_projectId.appspot.com',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _apiKey,
    appId: dotenv.get('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: '$_projectId.appspot.com',
    iosBundleId: 'com.mrida.mrida',
  );
}
