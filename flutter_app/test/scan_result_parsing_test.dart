import 'package:flutter_test/flutter_test.dart';
import 'package:mrida/models/scan_result.dart';

void main() {
  test('parses crop advisory with snake_case', () {
    final parsed = ScanResult.fromJson({
      'scanId': 's1',
      'fieldId': 'f1',
      'userId': 'u1',
      'imageUrl': '',
      'grade': 'A',
      'npk': {
        'nitrogen': 'Low',
        'phosphorus': 'Medium',
        'potassium': 'High',
      },
      'ph': {'min': 6.0, 'max': 7.0, 'interpretation': 'ok'},
      'deficiencies': ['zinc'],
      'prescriptionText': 'text',
      'prescriptionAudio': 'audio',
      'confidenceScore': 0.8,
      'signals': {
        'color_description': 'brown',
        'texture_observation': 'granular',
        'crack_pattern': 'none',
        'moisture_level': 'moist',
        'organic_matter_hint': 'medium'
      },
      'languageCode': 'en',
      'location': {'_latitude': 0.0, '_longitude': 0.0},
      'scannedAt': DateTime.now().toIso8601String(),
      'crop_advisory': {
        'recommended_crops': [
          {
            'crop': 'rice',
            'fit_score': 0.82,
            'why': 'good fit',
            'season_fit': 'kharif',
            'expected_water_need': '1100-1500',
            'confidence': 0.8
          }
        ],
        'water_plan': {
          'total_requirement_mm': '1100-1500',
          'critical_irrigation_stages': ['tillering'],
          'field_note': 'monitor',
          'confidence': 0.74
        },
        'pre_sowing_plan': {
          'steps': ['level field'],
          'confidence': 0.7
        },
        'pest_disease_risk': [
          {
            'name': 'blast',
            'type': 'disease',
            'risk_level': 'medium',
            'why_likely': 'humid',
            'early_signs': ['lesion'],
            'prevention': ['spray'],
            'confidence': 0.72
          }
        ]
      }
    });

    expect(parsed.cropAdvisory, isNotNull);
    expect(parsed.cropAdvisory!.recommendedCrops.first.crop, 'rice');
    expect(parsed.cropAdvisory!.waterPlan.totalRequirementMm, '1100-1500');
    expect(parsed.cropAdvisory!.pestDiseaseRisk.first.name, 'blast');
  });
}
