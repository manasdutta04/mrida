import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../models/user_profile.dart';
import 'field_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) => LocalStorageService());

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    yield null;
    return;
  }

  // Initial value from Local Storage
  final local = ref.read(localStorageServiceProvider).getProfile();
  yield UserProfile(
    uid: userId,
    phoneNumber: local['phoneNumber'] ?? '',
    languageCode: local['languageCode'] ?? 'en',
    displayName: local['displayName'],
  );

  // Watch remote and update local cache
  try {
    await for (final remote in ref.watch(firestoreServiceProvider).watchUserProfile(userId)) {
      if (remote != null) {
        ref.read(localStorageServiceProvider).saveProfile(
              name: remote.displayName,
              phone: remote.phoneNumber,
              language: remote.languageCode,
            );
      }
      yield remote;
    }
  } catch (e) {
    // Keep yielding the local version if remote fails
    return;
  }
});
