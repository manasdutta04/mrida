import base64
import json
import os
from pathlib import Path
from typing import Any

import google.generativeai as genai
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from preprocessing import preprocess_soil_image
from prompts import build_user_prompt
from storage import store_scan_result
from validation import validate_against_regional_profile


app = FastAPI(title="MRIDA AI Backend", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

root = Path(__file__).resolve().parent.parent
with (root / "data" / "regional_soil_profiles.json").open("r", encoding="utf-8") as f:
    REGIONAL_PROFILES: dict[str, Any] = json.load(f)
with (root / "prompts" / "system_prompt.txt").open("r", encoding="utf-8") as f:
    SYSTEM_PROMPT = f.read()

genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))
model = genai.GenerativeModel(model_name="gemini-2.0-flash", system_instruction=SYSTEM_PROMPT)


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
    warning_note: str | None
    image_url: str


@app.post("/scan", response_model=ScanResponse)
async def analyze_soil(request: ScanRequest) -> ScanResponse:
    try:
        image_bytes = base64.b64decode(request.image_base64)
        processed_b64 = preprocess_soil_image(image_bytes)
        user_prompt = build_user_prompt(
            state=request.state,
            district=request.district,
            season=request.season,
            crop=request.crop,
            language=request.language,
        )
        image_part = {"mime_type": "image/jpeg", "data": processed_b64}
        response = model.generate_content(
            [user_prompt, image_part],
            generation_config=genai.GenerationConfig(
                temperature=0.1,
                response_mime_type="application/json",
            ),
        )
        result = json.loads(response.text)
        result = validate_against_regional_profile(result, request.state, REGIONAL_PROFILES)
        if result["confidence"] < 0.40:
            raise HTTPException(
                status_code=422,
                detail={"error": "low_confidence", "message": "Image quality insufficient for accurate analysis.", "confidence": result["confidence"]},
            )
        scan_id, image_url = await store_scan_result(result=result, image_bytes=image_bytes, request=request)
        return ScanResponse(scan_id=scan_id, image_url=image_url, **result)
    except json.JSONDecodeError as exc:
        raise HTTPException(status_code=500, detail="Gemini returned malformed JSON. Retry.") from exc
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
