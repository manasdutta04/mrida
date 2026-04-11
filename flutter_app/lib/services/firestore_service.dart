import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/field.dart';

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
}
