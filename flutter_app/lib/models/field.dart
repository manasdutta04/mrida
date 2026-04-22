import 'package:cloud_firestore/cloud_firestore.dart' hide Field;

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
        fieldId: (json['fieldId'] ?? json['field_id'] ?? '') as String,
        userId: (json['userId'] ?? json['user_id'] ?? '') as String,
        name: (json['name'] ?? json['field_name'] ?? 'Untitled Field') as String,
        location: json['location'] as GeoPoint? ?? const GeoPoint(0, 0),
        areaAcres: ((json['areaAcres'] ?? json['area_acres'] ?? 0) as num).toDouble(),
        crops: ((json['crops'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        lastScanId: json['lastScanId'] as String?,
        lastHealthScore: (json['lastHealthScore'] as num?)?.toDouble(),
        lastScannedAt: _parseDate(json['lastScannedAt'] ?? json['last_scanned_at']),
      );

  factory Field.fromFirestore(
    String fieldId,
    Map<String, dynamic> data,
  ) {
    return Field.fromJson({
      ...data,
      'fieldId': fieldId,
    });
  }

  Map<String, dynamic> toFirestore() => {
        'fieldId': fieldId,
        'userId': userId,
        'name': name,
        'location': location,
        'areaAcres': areaAcres,
        'crops': crops,
        'lastScanId': lastScanId,
        'lastHealthScore': lastHealthScore,
        'lastScannedAt': lastScannedAt?.toIso8601String(),
      };

  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
