import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder',
    appId: 'placeholder',
    messagingSenderId: 'placeholder',
    projectId: 'placeholder',
    storageBucket: 'placeholder',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder',
    appId: 'placeholder',
    messagingSenderId: 'placeholder',
    projectId: 'placeholder',
    storageBucket: 'placeholder',
    iosBundleId: 'com.mrida.mrida',
  );
}
