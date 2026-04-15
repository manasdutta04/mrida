def build_user_prompt(state: str, district: str, season: str, crop: str, language: str) -> str:
    return f"""
Analyze this soil photograph carefully.

Context provided by the farmer:
- State: {state}
- District: {district}
- Current season: {season} (Kharif / Rabi / Zaid)
- Intended crop: {crop}
- Language for prescription: {language}

## Your analysis process - follow this order exactly
Step 1: VISUAL SIGNALS
Step 2: SOIL ORDER CLASSIFICATION
Step 3: NPK ESTIMATION
Step 4: pH ESTIMATION
Step 5: DEFICIENCY FLAGS
Step 6: FERTILIZER PRESCRIPTION
Step 7: CONFIDENCE SCORE

Step 8: CROP ADVISORY
- Recommend top 3 crops suitable for inferred soil order + pH + state + season.
- Provide fit score (0.0-1.0), basis, and expected water need.

Step 9: WATER PLAN
- Provide total seasonal water requirement range.
- Mention critical irrigation stages.
- Add practical field note for farmer.

Step 10: PRE-SOWING PLAN
- Provide 3-5 practical pre-sowing instructions.

Step 11: PEST/DISEASE RISK
- List likely pest/disease risks for recommended crops in this season.
- Add risk level, early signs, and prevention actions with confidence.

## Output format - respond ONLY with JSON
{{
  "grade": "A",
  "confidence": 0.0,
  "signals": {{
    "color_description": "string",
    "texture_observation": "string",
    "crack_pattern": "none | fine | medium | wide",
    "moisture_level": "dry | moist | wet",
    "organic_matter_hint": "low | medium | high"
  }},
  "soil_order": "string",
  "npk": {{
    "nitrogen": "Low | Medium | High",
    "nitrogen_range": "string",
    "nitrogen_basis": "string",
    "phosphorus": "Low | Medium | High",
    "phosphorus_range": "string",
    "phosphorus_basis": "string",
    "potassium": "Low | Medium | High",
    "potassium_range": "string",
    "potassium_basis": "string"
  }},
  "ph": {{
    "min": 5.5,
    "max": 7.0,
    "interpretation": "string"
  }},
  "deficiencies": ["nitrogen"],
  "prescription": {{
    "text": "Full prescription in {language}",
    "audio_short": "Shorter version in {language}"
  }},
  "warning_note": null
  "crop_advisory": {{
    "recommended_crops": [
      {{
        "crop": "string",
        "fit_score": 0.0,
        "why": "string",
        "season_fit": "string",
        "expected_water_need": "string",
        "confidence": 0.0
      }}
    ],
    "water_plan": {{
      "total_requirement_mm": "string",
      "critical_irrigation_stages": ["string"],
      "field_note": "string",
      "confidence": 0.0
    }},
    "pre_sowing_plan": {{
      "steps": ["string"],
      "confidence": 0.0
    }},
    "pest_disease_risk": [
      {{
        "name": "string",
        "type": "pest|disease",
        "risk_level": "low|medium|high",
        "why_likely": "string",
        "early_signs": ["string"],
        "prevention": ["string"],
        "confidence": 0.0
      }}
    ]
  }}
}}
"""
