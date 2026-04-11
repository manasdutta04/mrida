import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/field.dart';
import '../services/firestore_service.dart';
import 'user_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final fieldsStreamProvider = StreamProvider<List<Field>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(const <Field>[]);
  }
  return ref.watch(firestoreServiceProvider).watchFields(userId);
});
