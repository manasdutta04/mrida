import 'package:cloud_firestore/cloud_firestore.dart';

import 'soil_grade.dart';

class ScanResult {
  const ScanResult({
    required this.scanId,
    required this.fieldId,
    required this.userId,
    required this.imageUrl,
    required this.grade,
    required this.npk,
    required this.ph,
    required this.deficiencies,
    required this.prescriptionText,
    required this.prescriptionAudio,
    required this.confidenceScore,
    required this.signals,
    required this.languageCode,
    required this.location,
    required this.scannedAt,
    this.warningNote,
  });
  final String scanId;
  final String fieldId;
  final String userId;
  final String imageUrl;
  final SoilGrade grade;
  final NPKEstimate npk;
  final PHRange ph;
  final List<String> deficiencies;
  final String prescriptionText;
  final String prescriptionAudio;
  final double confidenceScore;
  final SoilSignals signals;
  final String languageCode;
  final GeoPoint location;
  final DateTime scannedAt;
  final String? warningNote;

  /// Parse backend response (Mode 2 — Cloud Run / Firestore document)
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    return ScanResult(
      scanId: (json['scanId'] ?? json['scan_id'] ?? '') as String,
      fieldId: (json['fieldId'] ?? json['field_id'] ?? '') as String,
      userId: (json['userId'] ?? json['user_id'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      grade: _parseGrade(json['grade'] as String? ?? 'C'),
      npk: NPKEstimate.fromJson(Map<String, dynamic>.from(json['npk'] as Map)),
      ph: PHRange.fromJson(Map<String, dynamic>.from(json['ph'] as Map)),
      deficiencies: (json['deficiencies'] as List).map((e) => e.toString()).toList(),
      prescriptionText: _extractPrescriptionText(json),
      prescriptionAudio: _extractPrescriptionAudio(json),
      confidenceScore: (json['confidenceScore'] ?? json['confidence'] as num? ?? 0.0).toDouble(),
      signals: SoilSignals.fromJson(Map<String, dynamic>.from(json['signals'] as Map)),
      languageCode: (json['languageCode'] ?? json['language'] ?? 'en') as String,
      location: loc != null
          ? GeoPoint(
              (loc['_latitude'] ?? loc['latitude'] as num? ?? 0.0).toDouble(),
              (loc['_longitude'] ?? loc['longitude'] as num? ?? 0.0).toDouble(),
            )
          : const GeoPoint(0, 0),
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : DateTime.now(),
      warningNote: (json['warningNote'] ?? json['warning_note']) as String?,
    );
  }

  /// Parse direct Gemini API response (Mode 1 — direct call)
  /// This JSON comes straight from Gemini, so it uses the prompt's schema
  /// (snake_case keys), and has no scan_id, user_id, image_url etc.
  factory ScanResult.fromGeminiJson(
    Map<String, dynamic> json, {
    required String userId,
    required String fieldId,
    required double latitude,
    required double longitude,
  }) {
    final prescription = json['prescription'] as Map<String, dynamic>? ?? {};

    return ScanResult(
      scanId: 'local-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldId,
      userId: userId,
      imageUrl: '', // No image URL in direct mode
      grade: _parseGrade(json['grade'] as String? ?? 'C'),
      npk: NPKEstimate.fromJson(Map<String, dynamic>.from(json['npk'] as Map)),
      ph: PHRange.fromJson(Map<String, dynamic>.from(json['ph'] as Map)),
      deficiencies: (json['deficiencies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      prescriptionText: (prescription['text'] ?? '') as String,
      prescriptionAudio: (prescription['audio_short'] ?? '') as String,
      confidenceScore: (json['confidence'] as num? ?? 0.0).toDouble(),
      signals: SoilSignals.fromJson(Map<String, dynamic>.from(json['signals'] as Map)),
      languageCode: 'en',
      location: GeoPoint(latitude, longitude),
      scannedAt: DateTime.now(),
      warningNote: json['warning_note'] as String?,
    );
  }

  static SoilGrade _parseGrade(String grade) {
    return SoilGrade.values.firstWhere(
      (e) => e.name.toUpperCase() == grade.toUpperCase(),
      orElse: () => SoilGrade.c,
    );
  }

  static String _extractPrescriptionText(Map<String, dynamic> json) {
    if (json['prescriptionText'] != null) return json['prescriptionText'] as String;
    final prescription = json['prescription'];
    if (prescription is Map) return (prescription['text'] ?? '') as String;
    return '';
  }

  static String _extractPrescriptionAudio(Map<String, dynamic> json) {
    if (json['prescriptionAudio'] != null) return json['prescriptionAudio'] as String;
    final prescription = json['prescription'];
    if (prescription is Map) return (prescription['audio_short'] ?? '') as String;
    return '';
  }
}

class NPKEstimate {
  const NPKEstimate({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.nitrogenRaw,
    required this.phosphorusRaw,
    required this.potassiumRaw,
  });
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String nitrogenRaw;
  final String phosphorusRaw;
  final String potassiumRaw;

  factory NPKEstimate.fromJson(Map<String, dynamic> json) => NPKEstimate(
        nitrogen: (json['nitrogen'] ?? 'Unknown') as String,
        phosphorus: (json['phosphorus'] ?? 'Unknown') as String,
        potassium: (json['potassium'] ?? 'Unknown') as String,
        nitrogenRaw: (json['nitrogenRaw'] ?? json['nitrogen_range'] ?? json['nitrogen_basis'] ?? '') as String,
        phosphorusRaw: (json['phosphorusRaw'] ?? json['phosphorus_range'] ?? json['phosphorus_basis'] ?? '') as String,
        potassiumRaw: (json['potassiumRaw'] ?? json['potassium_range'] ?? json['potassium_basis'] ?? '') as String,
      );
}

class PHRange {
  const PHRange({required this.min, required this.max, required this.interpretation});
  final double min;
  final double max;
  final String interpretation;
  factory PHRange.fromJson(Map<String, dynamic> json) => PHRange(
        min: (json['min'] as num).toDouble(),
        max: (json['max'] as num).toDouble(),
        interpretation: (json['interpretation'] ?? '') as String,
      );
}

class SoilSignals {
  const SoilSignals({
    required this.colorDescription,
    required this.textureObservation,
    required this.crackPattern,
    required this.moistureLevel,
    required this.organicMatterHint,
  });
  final String colorDescription;
  final String textureObservation;
  final String crackPattern;
  final String moistureLevel;
  final String organicMatterHint;

  factory SoilSignals.fromJson(Map<String, dynamic> json) => SoilSignals(
        colorDescription: (json['colorDescription'] ?? json['color_description'] ?? '') as String,
        textureObservation: (json['textureObservation'] ?? json['texture_observation'] ?? '') as String,
        crackPattern: (json['crackPattern'] ?? json['crack_pattern'] ?? '') as String,
        moistureLevel: (json['moistureLevel'] ?? json['moisture_level'] ?? '') as String,
        organicMatterHint: (json['organicMatterHint'] ?? json['organic_matter_hint'] ?? '') as String,
      );
}
