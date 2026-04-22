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
    this.cropAdvisory,
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
  final CropAdvisory? cropAdvisory;
  final String? warningNote;

  /// Parse backend response
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    
    // Handle Firestore Timestamp vs ISO String
    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return DateTime.now();
    }

    return ScanResult(
      scanId: (json['scanId'] ?? json['scan_id'] ?? '') as String,
      fieldId: (json['fieldId'] ?? json['field_id'] ?? '') as String,
      userId: (json['userId'] ?? json['user_id'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      grade: _parseGrade((json['grade'] ?? 'C') as String),
      npk: NPKEstimate.fromJson(Map<String, dynamic>.from((json['npk'] ?? {}) as Map)),
      ph: PHRange.fromJson(Map<String, dynamic>.from((json['ph'] ?? {'min': 6.0, 'max': 7.0, 'interpretation': 'Normal'}) as Map)),
      deficiencies: (json['deficiencies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      prescriptionText: _extractPrescriptionText(json),
      prescriptionAudio: _extractPrescriptionAudio(json),
      confidenceScore: (json['confidenceScore'] ?? json['confidence'] as num? ?? 0.0).toDouble(),
      signals: SoilSignals.fromJson(Map<String, dynamic>.from((json['signals'] ?? {}) as Map)),
      languageCode: (json['languageCode'] ?? json['language'] ?? 'en') as String,
      location: loc is GeoPoint
          ? loc
          : loc is Map
              ? GeoPoint(
                  ((loc['latitude'] ?? loc['_latitude']) as num? ?? 0.0).toDouble(),
                  ((loc['longitude'] ?? loc['_longitude']) as num? ?? 0.0).toDouble(),
                )
              : const GeoPoint(0, 0),
      scannedAt: parseTime(json['scannedAt'] ?? json['scanned_at']),
      cropAdvisory: json['crop_advisory'] != null || json['cropAdvisory'] != null
          ? CropAdvisory.fromJson(
              Map<String, dynamic>.from(
                (json['crop_advisory'] ?? json['cropAdvisory']) as Map,
              ),
            )
          : null,
      warningNote: (json['warningNote'] ?? json['warning_note']) as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'scanId': scanId,
      'fieldId': fieldId,
      'userId': userId,
      'imageUrl': imageUrl,
      'grade': grade.name.toUpperCase(),
      'npk': {
        'nitrogen': npk.nitrogen,
        'phosphorus': npk.phosphorus,
        'potassium': npk.potassium,
        'nitrogenRaw': npk.nitrogenRaw,
        'phosphorusRaw': npk.phosphorusRaw,
        'potassiumRaw': npk.potassiumRaw,
      },
      'ph': {
        'min': ph.min,
        'max': ph.max,
        'interpretation': ph.interpretation,
      },
      'deficiencies': deficiencies,
      'prescriptionText': prescriptionText,
      'prescriptionAudio': prescriptionAudio,
      'confidenceScore': confidenceScore,
      'signals': {
        'colorDescription': signals.colorDescription,
        'textureObservation': signals.textureObservation,
        'crackPattern': signals.crackPattern,
        'moistureLevel': signals.moistureLevel,
        'organicMatterHint': signals.organicMatterHint,
      },
      'languageCode': languageCode,
      'location': location,
      'scannedAt': Timestamp.fromDate(scannedAt),
      if (cropAdvisory != null) 'cropAdvisory': cropAdvisory!.toJson(),
      'warningNote': warningNote,
    };
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
      grade: _parseGrade((json['grade'] ?? 'C') as String),
      npk: NPKEstimate.fromJson(Map<String, dynamic>.from((json['npk'] ?? {}) as Map)),
      ph: PHRange.fromJson(Map<String, dynamic>.from((json['ph'] ?? {}) as Map)),
      deficiencies: (json['deficiencies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      prescriptionText: (prescription['text'] ?? '') as String,
      prescriptionAudio: (prescription['audio_short'] ?? '') as String,
      confidenceScore: (json['confidence'] as num? ?? 0.0).toDouble(),
      signals: SoilSignals.fromJson(Map<String, dynamic>.from((json['signals'] ?? {}) as Map)),
      languageCode: 'en',
      location: GeoPoint(latitude, longitude),
      scannedAt: DateTime.now(),
      warningNote: json['warning_note'] as String?,
      cropAdvisory: json['crop_advisory'] != null
          ? CropAdvisory.fromJson(Map<String, dynamic>.from(json['crop_advisory'] as Map))
          : null,
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

class CropAdvisory {
  const CropAdvisory({
    required this.recommendedCrops,
    required this.waterPlan,
    required this.preSowingPlan,
    required this.pestDiseaseRisk,
  });

  final List<RecommendedCrop> recommendedCrops;
  final WaterPlan waterPlan;
  final PreSowingPlan preSowingPlan;
  final List<PestDiseaseRisk> pestDiseaseRisk;

  factory CropAdvisory.fromJson(Map<String, dynamic> json) => CropAdvisory(
        recommendedCrops: ((json['recommended_crops'] ?? json['recommendedCrops']) as List? ?? [])
            .map((e) => RecommendedCrop.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        waterPlan: WaterPlan.fromJson(
          Map<String, dynamic>.from((json['water_plan'] ?? json['waterPlan'] ?? {}) as Map),
        ),
        preSowingPlan: PreSowingPlan.fromJson(
          Map<String, dynamic>.from((json['pre_sowing_plan'] ?? json['preSowingPlan'] ?? {}) as Map),
        ),
        pestDiseaseRisk: ((json['pest_disease_risk'] ?? json['pestDiseaseRisk']) as List? ?? [])
            .map((e) => PestDiseaseRisk.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'recommendedCrops': recommendedCrops.map((e) => e.toJson()).toList(),
        'waterPlan': waterPlan.toJson(),
        'preSowingPlan': preSowingPlan.toJson(),
        'pestDiseaseRisk': pestDiseaseRisk.map((e) => e.toJson()).toList(),
      };
}

class RecommendedCrop {
  const RecommendedCrop({
    required this.crop,
    required this.fitScore,
    required this.why,
    required this.seasonFit,
    required this.expectedWaterNeed,
    required this.confidence,
  });
  final String crop;
  final double fitScore;
  final String why;
  final String seasonFit;
  final String expectedWaterNeed;
  final double confidence;

  factory RecommendedCrop.fromJson(Map<String, dynamic> json) => RecommendedCrop(
        crop: (json['crop'] ?? '') as String,
        fitScore: ((json['fit_score'] ?? json['fitScore'] ?? 0) as num).toDouble(),
        why: (json['why'] ?? '') as String,
        seasonFit: (json['season_fit'] ?? json['seasonFit'] ?? '') as String,
        expectedWaterNeed: (json['expected_water_need'] ?? json['expectedWaterNeed'] ?? '') as String,
        confidence: ((json['confidence'] ?? 0.5) as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'fitScore': fitScore,
        'why': why,
        'seasonFit': seasonFit,
        'expectedWaterNeed': expectedWaterNeed,
        'confidence': confidence,
      };
}

class WaterPlan {
  const WaterPlan({
    required this.totalRequirementMm,
    required this.criticalIrrigationStages,
    required this.fieldNote,
    required this.confidence,
  });
  final String totalRequirementMm;
  final List<String> criticalIrrigationStages;
  final String fieldNote;
  final double confidence;

  factory WaterPlan.fromJson(Map<String, dynamic> json) => WaterPlan(
        totalRequirementMm: (json['total_requirement_mm'] ?? json['totalRequirementMm'] ?? '') as String,
        criticalIrrigationStages: ((json['critical_irrigation_stages'] ?? json['criticalIrrigationStages']) as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        fieldNote: (json['field_note'] ?? json['fieldNote'] ?? '') as String,
        confidence: ((json['confidence'] ?? 0.5) as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'totalRequirementMm': totalRequirementMm,
        'criticalIrrigationStages': criticalIrrigationStages,
        'fieldNote': fieldNote,
        'confidence': confidence,
      };
}

class PreSowingPlan {
  const PreSowingPlan({
    required this.steps,
    required this.confidence,
  });
  final List<String> steps;
  final double confidence;

  factory PreSowingPlan.fromJson(Map<String, dynamic> json) => PreSowingPlan(
        steps: ((json['steps'] ?? json['pre_sowing_plan'] ?? []) as List).map((e) => e.toString()).toList(),
        confidence: ((json['confidence'] ?? 0.5) as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'confidence': confidence,
      };
}

class PestDiseaseRisk {
  const PestDiseaseRisk({
    required this.name,
    required this.type,
    required this.riskLevel,
    required this.whyLikely,
    required this.earlySigns,
    required this.prevention,
    required this.confidence,
  });
  final String name;
  final String type;
  final String riskLevel;
  final String whyLikely;
  final List<String> earlySigns;
  final List<String> prevention;
  final double confidence;

  factory PestDiseaseRisk.fromJson(Map<String, dynamic> json) => PestDiseaseRisk(
        name: (json['name'] ?? '') as String,
        type: (json['type'] ?? '') as String,
        riskLevel: (json['risk_level'] ?? json['riskLevel'] ?? '') as String,
        whyLikely: (json['why_likely'] ?? json['whyLikely'] ?? '') as String,
        earlySigns: ((json['early_signs'] ?? json['earlySigns']) as List? ?? []).map((e) => e.toString()).toList(),
        prevention: ((json['prevention'] ?? []) as List).map((e) => e.toString()).toList(),
        confidence: ((json['confidence'] ?? 0.5) as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'riskLevel': riskLevel,
        'whyLikely': whyLikely,
        'earlySigns': earlySigns,
        'prevention': prevention,
        'confidence': confidence,
      };
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
        min: ((json['min'] ?? json['min_ph'] ?? 6.0) as num).toDouble(),
        max: ((json['max'] ?? json['max_ph'] ?? 7.5) as num).toDouble(),
        interpretation: (json['interpretation'] ?? 'Normal') as String,
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
