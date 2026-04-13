import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/field.dart';
import '../models/user_profile.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _fieldsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('fields');
  }

  Stream<List<Field>> watchFields(String userId) {
    return _fieldsRef(userId).orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Field.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Field> addField({
    required String userId,
    required String name,
    required double areaAcres,
    required String primaryCrop,
    required GeoPoint location,
  }) async {
    final ref = _fieldsRef(userId).doc();
    final field = Field(
      fieldId: ref.id,
      userId: userId,
      name: name,
      location: location,
      areaAcres: areaAcres,
      crops: [primaryCrop],
      lastScanId: null,
      lastHealthScore: null,
      lastScannedAt: null,
    );

    await ref.set(field.toFirestore());
    return field;
  }

  // --- User Profile Methods ---

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfile.fromJson({
        'uid': snapshot.id,
        ...snapshot.data()!,
      });
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(
          data,
          SetOptions(merge: true),
        );
  }
}
