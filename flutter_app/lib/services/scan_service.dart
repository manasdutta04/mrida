import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/scan_result.dart';

/// Service for analyzing soil images. Supports two modes:
/// - [ScanMode.direct]: Calls Gemini API directly (Phase 1, zero billing)
/// - [ScanMode.backend]: Calls the Cloud Run FastAPI backend (Phase 2)
class ScanService {
  ScanService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static Map<String, dynamic>? _cropProfiles;
  static Map<String, dynamic>? _riskMatrix;

  Future<ScanResult> analyzeSoil({
    required File imageFile,
    required String fieldId,
    required String state,
    required String district,
    required String season,
    required String crop,
    required String language,
    required Position location,
  }) async {
    await _ensureAdvisoryDataLoaded();
    switch (ApiConstants.scanMode) {
      case ScanMode.direct:
        return _analyzeDirect(
          imageFile: imageFile,
          fieldId: fieldId,
          state: state,
          district: district,
          season: season,
          crop: crop,
          language: language,
          location: location,
        );
      case ScanMode.backend:
        return _analyzeViaBackend(
          imageFile: imageFile,
          fieldId: fieldId,
          state: state,
          district: district,
          season: season,
          crop: crop,
          language: language,
          location: location,
        );
    }
  }

  /// Mode 1: Direct Gemini API call (Phase 1 — zero billing)
  Future<ScanResult> _analyzeDirect({
    required File imageFile,
    required String fieldId,
    required String state,
    required String district,
    required String season,
    required String crop,
    required String language,
    required Position location,
  }) async {
    if (ApiConstants.geminiApiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not set. Run with: '
        'flutter run --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final imageBytes = await imageFile.readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    final prompt = _buildPrompt(
      state: state,
      district: district,
      season: season,
      crop: crop,
      language: language,
    );

    final url = Uri.parse(
      '${ApiConstants.geminiEndpoint}?key=${ApiConstants.geminiApiKey}',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': imageBase64,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'responseMimeType': 'application/json',
      },
    });

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      debugPrint('Gemini API error: ${response.body}');
      throw Exception('Gemini API returned ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseJson['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates returned from Gemini');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final text = parts[0]['text'] as String;

    final scanJson = jsonDecode(text) as Map<String, dynamic>;

    // Check confidence gate on client side
    final confidence = (scanJson['confidence'] as num).toDouble();
    if (confidence < 0.40) {
      throw Exception(
        'Low confidence ($confidence). '
        'Please retake the photo in natural daylight.',
      );
    }

    var parsed = ScanResult.fromGeminiJson(
      scanJson,
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'demo-user',
      fieldId: fieldId,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    parsed = _validateCropAdvisory(parsed, state: state, season: season);
    return parsed;
  }

  /// Mode 2: Backend API call (Phase 2 — Cloud Run)
  Future<ScanResult> _analyzeViaBackend({
    required File imageFile,
    required String fieldId,
    required String state,
    required String district,
    required String season,
    required String crop,
    required String language,
    required Position location,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    final response = await _client.post(
      Uri.parse(ApiConstants.scanEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image_base64': imageBase64,
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'demo-user',
        'field_id': fieldId,
        'state': state,
        'district': district,
        'season': season,
        'crop': crop,
        'language': language,
        'latitude': location.latitude,
        'longitude': location.longitude,
      }),
    );

    if (response.statusCode == 422) {
      throw Exception('Low confidence. Retake in better lighting.');
    }

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    var parsed = ScanResult.fromJson(data);
    parsed = _validateCropAdvisory(parsed, state: state, season: season);
    return parsed;
  }

  /// Build the user prompt matching the AGENT_02 spec exactly.
  String _buildPrompt({
    required String state,
    required String district,
    required String season,
    required String crop,
    required String language,
  }) {
    return '''
Analyze this soil photograph carefully.

Context provided by the farmer:
- State: $state
- District: $district
- Current season: $season (Kharif / Rabi / Zaid)
- Intended crop: $crop
- Language for prescription: $language

## Your analysis process — follow this order exactly

Step 1: VISUAL SIGNALS
Describe what you observe:
- Soil color in Munsell terms (hue, approximate value/chroma)
- Surface texture (granular / blocky / platy / single-grain)
- Crack patterns (none / fine / medium / wide) and their spacing
- Surface crust (none / light / heavy)
- Apparent moisture (dry / moist / wet)
- Any visible features (stones, organic debris, efflorescence)

Step 2: SOIL ORDER CLASSIFICATION
Based on color and structure, identify the most likely ICAR soil order.
State your confidence in this classification and why.

Step 3: NPK ESTIMATION
Based on soil order + color + regional context for $state, estimate:
- Nitrogen: low / medium / high with range in kg/ha (not exact numbers — ranges only)
- Phosphorus: low / medium / high with range in kg/ha
- Potassium: low / medium / high with range in kg/ha

For each nutrient, explain the visual or regional basis for your estimate.

Step 4: pH ESTIMATION
Estimate pH range (not a single number — always a range like 6.0–6.8).
Basis: soil color, regional typical values for $district, $state.

Step 5: DEFICIENCY FLAGS
List likely deficiencies given soil order + color. Only flag deficiencies you have a scientific basis for.

Step 6: FERTILIZER PRESCRIPTION
For crop: $crop in season: $season in $state:
Write a specific, actionable fertilizer recommendation following ICAR state-specific fertilizer recommendation guidelines.
Format: "Apply X kg/acre of Y before sowing, followed by Z at Z weeks."
Use real ICAR recommended doses — not generic advice.

Step 7: CONFIDENCE SCORE
Give an overall confidence score from 0.0 to 1.0.
If score < 0.60, add a warning explaining what made analysis uncertain.

Step 8: CROP ADVISORY
Recommend top 3 crops for this soil + season + state with fit score, reasons and water need.

Step 9: WATER PLAN
Provide total requirement (mm range), critical irrigation stages, and one practical field note.

Step 10: PRE-SOWING PLAN
Provide 3-5 actionable preparation instructions before sowing.

Step 11: PEST/DISEASE RISK
List likely pest/disease attacks for recommended crops in this season with confidence.

## Output format — respond ONLY with this JSON, nothing else

{
  "grade": "A",
  "confidence": 0.0,
  "signals": {
    "color_description": "string — Munsell description",
    "texture_observation": "string",
    "crack_pattern": "none | fine | medium | wide",
    "moisture_level": "dry | moist | wet",
    "organic_matter_hint": "low | medium | high"
  },
  "soil_order": "string — ICAR classification",
  "npk": {
    "nitrogen": "Low | Medium | High",
    "nitrogen_range": "string e.g. <140 kg/ha",
    "nitrogen_basis": "string — why you estimated this",
    "phosphorus": "Low | Medium | High",
    "phosphorus_range": "string",
    "phosphorus_basis": "string",
    "potassium": "Low | Medium | High",
    "potassium_range": "string",
    "potassium_basis": "string"
  },
  "ph": {
    "min": 5.5,
    "max": 7.0,
    "interpretation": "string — what this means for the crop"
  },
  "deficiencies": ["nitrogen", "zinc"],
  "prescription": {
    "text": "Full prescription in $language — 3-4 sentences, specific doses",
    "audio_short": "Shorter version for TTS, 1-2 sentences in $language"
  },
  "warning_note": null
  "crop_advisory": {
    "recommended_crops": [
      {
        "crop": "string",
        "fit_score": 0.0,
        "why": "string",
        "season_fit": "string",
        "expected_water_need": "string",
        "confidence": 0.0
      }
    ],
    "water_plan": {
      "total_requirement_mm": "string",
      "critical_irrigation_stages": ["string"],
      "field_note": "string",
      "confidence": 0.0
    },
    "pre_sowing_plan": {
      "steps": ["string"],
      "confidence": 0.0
    },
    "pest_disease_risk": [
      {
        "name": "string",
        "type": "pest|disease",
        "risk_level": "low|medium|high",
        "why_likely": "string",
        "early_signs": ["string"],
        "prevention": ["string"],
        "confidence": 0.0
      }
    ]
  }
}
''';
  }

  Future<void> _ensureAdvisoryDataLoaded() async {
    if (_cropProfiles != null && _riskMatrix != null) return;
    final cropRaw = await rootBundle.loadString('assets/data/crop_advisory_profiles.json');
    final riskRaw = await rootBundle.loadString('assets/data/pest_disease_risk_matrix.json');
    _cropProfiles = jsonDecode(cropRaw) as Map<String, dynamic>;
    _riskMatrix = jsonDecode(riskRaw) as Map<String, dynamic>;
  }

  ScanResult _validateCropAdvisory(ScanResult input, {required String state, required String season}) {
    var confidence = input.confidenceScore;
    final advisory = input.cropAdvisory;
    if (advisory == null) {
      return input;
    }
    final warnings = <String>[];
    for (final rec in advisory.recommendedCrops) {
      final profile = _cropProfiles?[rec.crop.toLowerCase().replaceAll(' ', '_')] as Map<String, dynamic>?;
      if (profile == null) {
        confidence -= 0.03;
        warnings.add('No profile for ${rec.crop}.');
        continue;
      }
      final orders = (profile['suitable_soil_orders'] as List).map((e) => e.toString()).toSet();
      if (!orders.contains(input.signals.colorDescription.contains('black') ? 'Vertisols' : input.grade.name)) {
        confidence -= 0.02;
      }
      final range = (profile['suitable_ph_range'] as List).map((e) => (e as num).toDouble()).toList();
      if (input.ph.max < range.first || input.ph.min > range.last) {
        confidence -= 0.03;
        warnings.add('${rec.crop} has weak pH fit.');
      }
      final windows = ((profile['season_windows_by_state'] as Map<String, dynamic>)[state] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
      if (windows.isNotEmpty && !windows.contains(season.toLowerCase())) {
        confidence -= 0.03;
        warnings.add('${rec.crop} is atypical for $season in $state.');
      }
    }
    final adjusted = confidence.clamp(0.0, 1.0);
    if (warnings.isEmpty) return input;
    return ScanResult(
      scanId: input.scanId,
      fieldId: input.fieldId,
      userId: input.userId,
      imageUrl: input.imageUrl,
      grade: input.grade,
      npk: input.npk,
      ph: input.ph,
      deficiencies: input.deficiencies,
      prescriptionText: input.prescriptionText,
      prescriptionAudio: input.prescriptionAudio,
      confidenceScore: adjusted,
      signals: input.signals,
      languageCode: input.languageCode,
      location: input.location,
      scannedAt: input.scannedAt,
      cropAdvisory: input.cropAdvisory,
      warningNote: ((input.warningNote ?? '') + ' ' + warnings.join(' ')).trim(),
    );
  }
}
