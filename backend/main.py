import base64
import json
import os
from pathlib import Path
from typing import Any
from urllib.parse import urlencode
from urllib.request import urlopen

import google.generativeai as genai
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from preprocessing import preprocess_soil_image
from prompts import build_user_prompt
from storage import store_scan_result
from validation import validate_against_regional_profile

load_dotenv()

app = FastAPI(title="MRIDA AI Backend", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent
# Handle both local dev (backend/main.py -> ../data) and Docker (/app/main.py -> ./data)
if (BASE_DIR / "data").exists():
    root = BASE_DIR
else:
    root = BASE_DIR.parent

with (root / "data" / "regional_soil_profiles.json").open("r", encoding="utf-8") as f:
    REGIONAL_PROFILES: dict[str, Any] = json.load(f)
with (root / "data" / "crop_advisory_profiles.json").open("r", encoding="utf-8") as f:
    CROP_ADVISORY_PROFILES: dict[str, Any] = json.load(f)
with (root / "data" / "pest_disease_risk_matrix.json").open("r", encoding="utf-8") as f:
    PEST_DISEASE_MATRIX: dict[str, Any] = json.load(f)
with (root / "prompts" / "system_prompt.txt").open("r", encoding="utf-8") as f:
    SYSTEM_PROMPT = f.read()

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY environment variable is required")

genai.configure(api_key=api_key)
model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    system_instruction=SYSTEM_PROMPT,
)


def _fetch_weather_summary(latitude: float, longitude: float) -> str:
    try:
        query = urlencode(
            {
                "latitude": latitude,
                "longitude": longitude,
                "current": "temperature_2m,relative_humidity_2m,precipitation",
            }
        )
        url = f"https://api.open-meteo.com/v1/forecast?{query}"
        with urlopen(url, timeout=8) as response:
            payload = json.loads(response.read().decode("utf-8"))
        current = payload.get("current", {})
        temp = current.get("temperature_2m", "NA")
        humidity = current.get("relative_humidity_2m", "NA")
        rain = current.get("precipitation", "NA")
        return f"Temp {temp}C, Humidity {humidity}%, Rain {rain}mm"
    except Exception:
        return "Weather data unavailable"


def _ensure_advisory_shape(result: dict) -> dict:
    result.setdefault("crop_advisory", {})
    advisory = result["crop_advisory"]
    advisory.setdefault("recommended_crops", [])
    advisory.setdefault(
        "water_plan",
        {
            "total_requirement_mm": "approximate",
            "critical_irrigation_stages": [],
            "field_note": "Use local weather and soil moisture for final scheduling.",
            "confidence": 0.4,
        },
    )
    advisory.setdefault("pre_sowing_plan", {"steps": [], "confidence": 0.4})
    advisory.setdefault("pest_disease_risk", [])
    return result


def _apply_advisory_confidence_policy(result: dict) -> dict:
    advisory = result.get("crop_advisory", {})
    warnings: list[str] = []

    recs = advisory.get("recommended_crops", [])
    rec_conf = (
        sum(float(r.get("confidence", 0.5)) for r in recs) / len(recs)
        if recs
        else 0.45
    )
    water_conf = float(advisory.get("water_plan", {}).get("confidence", 0.45))
    pre_conf = float(advisory.get("pre_sowing_plan", {}).get("confidence", 0.45))
    risks = advisory.get("pest_disease_risk", [])
    risk_conf = (
        sum(float(r.get("confidence", 0.5)) for r in risks) / len(risks)
        if risks
        else 0.45
    )

    if rec_conf < 0.65:
        warnings.append("Crop recommendation confidence is moderate/low.")
    if water_conf < 0.65:
        warnings.append("Water plan is approximate.")
    if pre_conf < 0.65:
        warnings.append("Pre-sowing plan confidence is moderate.")
    if risk_conf < 0.65:
        warnings.append("Pest/disease risk confidence is moderate.")

    refusal_template = (
        "Confidence is below threshold for reliable advisory. "
        "Retake photo in natural daylight and confirm with local agronomist/lab."
    )
    if rec_conf < 0.5:
        advisory["recommended_crops"] = [
            {
                "crop": "insufficient_confidence",
                "fit_score": 0.0,
                "why": refusal_template,
                "season_fit": "insufficient_confidence",
                "expected_water_need": "insufficient_confidence",
                "confidence": round(rec_conf, 2),
            }
        ]
    if water_conf < 0.5:
        advisory.setdefault("water_plan", {})
        advisory["water_plan"]["field_note"] = refusal_template
        advisory["water_plan"]["total_requirement_mm"] = "insufficient_confidence"
    if pre_conf < 0.5:
        advisory["pre_sowing_plan"] = {
            "steps": [refusal_template],
            "confidence": round(pre_conf, 2),
        }
    if risk_conf < 0.5:
        advisory["pest_disease_risk"] = [
            {
                "name": "insufficient_confidence",
                "type": "disease",
                "risk_level": "medium",
                "why_likely": refusal_template,
                "early_signs": ["Retake image and verify with extension officer."],
                "prevention": ["Use local integrated pest management advisory."],
                "confidence": round(risk_conf, 2),
            }
        ]

    if warnings:
        existing = result.get("warning_note") or ""
        result["warning_note"] = (existing + " " + " ".join(warnings)).strip()
    result["crop_advisory"] = advisory
    return result


class ScanRequest(BaseModel):
    image_base64: str
    user_id: str
    field_id: str
    state: str
    district: str
    season: str
    crop: str
    language: str
    latitude: float
    longitude: float


class ScanResponse(BaseModel):
    scan_id: str
    grade: str
    confidence: float
    signals: dict
    soil_order: str
    npk: dict
    ph: dict
    deficiencies: list
    prescription: dict
    crop_advisory: dict
    warning_note: str | None
    image_url: str


@app.post("/scan", response_model=ScanResponse)
async def analyze_soil(request: ScanRequest) -> ScanResponse:
    try:
        # 1. Preprocess image
        image_bytes = base64.b64decode(request.image_base64)
        processed_b64 = preprocess_soil_image(image_bytes)

        # 2. Build user prompt
        user_prompt = build_user_prompt(
            state=request.state,
            district=request.district,
            season=request.season,
            crop=request.crop,
            language=request.language,
            weather_summary=_fetch_weather_summary(request.latitude, request.longitude),
        )

        # 3. Call Gemini Vision (direct API — no Vertex AI)
        image_part = {"mime_type": "image/jpeg", "data": processed_b64}
        response = model.generate_content(
            [user_prompt, image_part],
            generation_config=genai.GenerationConfig(
                temperature=0.1,
                response_mime_type="application/json",
            ),
        )

        # 4. Parse structured JSON response
        result = json.loads(response.text)
        result = _ensure_advisory_shape(result)

        # 5. Validate against regional profiles
        result = validate_against_regional_profile(
            result,
            request.state,
            REGIONAL_PROFILES,
            crop_profiles=CROP_ADVISORY_PROFILES,
            risk_matrix=PEST_DISEASE_MATRIX,
        )
        result = _apply_advisory_confidence_policy(result)

        # 6. Confidence gate — reject if too low
        if result["confidence"] < 0.40:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "low_confidence",
                    "message": "Image quality insufficient for accurate analysis.",
                    "confidence": result["confidence"],
                },
            )

        # 7. Store to Firestore
        scan_id, image_url = await store_scan_result(
            result=result, image_bytes=image_bytes, request=request
        )

        return ScanResponse(scan_id=scan_id, image_url=image_url, **result)

    except json.JSONDecodeError as exc:
        raise HTTPException(
            status_code=500, detail="Gemini returned malformed JSON. Retry."
        ) from exc
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "model": "gemini-2.5-flash"}
