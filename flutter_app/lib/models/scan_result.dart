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

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    return ScanResult(
      scanId: json['scanId'] as String,
      fieldId: json['fieldId'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      grade: SoilGrade.values.firstWhere((e) => e.name.toUpperCase() == (json['grade'] as String).toUpperCase(), orElse: () => SoilGrade.c),
      npk: NPKEstimate.fromJson(Map<String, dynamic>.from(json['npk'] as Map)),
      ph: PHRange.fromJson(Map<String, dynamic>.from(json['ph'] as Map)),
      deficiencies: (json['deficiencies'] as List).map((e) => e.toString()).toList(),
      prescriptionText: json['prescriptionText'] as String,
      prescriptionAudio: json['prescriptionAudio'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      signals: SoilSignals.fromJson(Map<String, dynamic>.from(json['signals'] as Map)),
      languageCode: json['languageCode'] as String,
      location: GeoPoint((loc['_latitude'] as num).toDouble(), (loc['_longitude'] as num).toDouble()),
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      warningNote: json['warningNote'] as String?,
    );
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
        nitrogen: json['nitrogen'] as String,
        phosphorus: json['phosphorus'] as String,
        potassium: json['potassium'] as String,
        nitrogenRaw: json['nitrogenRaw'] as String,
        phosphorusRaw: json['phosphorusRaw'] as String,
        potassiumRaw: json['potassiumRaw'] as String,
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
        interpretation: json['interpretation'] as String,
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
        colorDescription: json['colorDescription'] as String,
        textureObservation: json['textureObservation'] as String,
        crackPattern: json['crackPattern'] as String,
        moistureLevel: json['moistureLevel'] as String,
        organicMatterHint: json['organicMatterHint'] as String,
      );
}
