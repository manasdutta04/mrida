import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import 'field_provider.dart';

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).watchUserProfile(userId);
});
