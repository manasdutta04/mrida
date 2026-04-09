import 'package:cloud_firestore/cloud_firestore.dart';

class Field {
  const Field({
    required this.fieldId,
    required this.userId,
    required this.name,
    required this.location,
    required this.areaAcres,
    required this.crops,
    this.lastScanId,
    this.lastHealthScore,
    this.lastScannedAt,
  });
  final String fieldId;
  final String userId;
  final String name;
  final GeoPoint location;
  final double areaAcres;
  final List<String> crops;
  final String? lastScanId;
  final double? lastHealthScore;
  final DateTime? lastScannedAt;

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        fieldId: json['fieldId'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        location: json['location'] as GeoPoint,
        areaAcres: (json['areaAcres'] as num).toDouble(),
        crops: (json['crops'] as List).map((e) => e.toString()).toList(),
        lastScanId: json['lastScanId'] as String?,
        lastHealthScore: (json['lastHealthScore'] as num?)?.toDouble(),
        lastScannedAt: json['lastScannedAt'] == null ? null : DateTime.parse(json['lastScannedAt'] as String),
      );
}
