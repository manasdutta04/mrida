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
}}
"""
