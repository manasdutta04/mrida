import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> sendOTP(String phoneNumber) async {
    final regex = RegExp(r'^\+[1-9]\d{7,14}$');
    if (!regex.hasMatch(phoneNumber)) {
      throw FirebaseAuthException(
        code: 'invalid-phone-number',
        message: 'Phone number must be in E.164 format.',
      );
    }

    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
