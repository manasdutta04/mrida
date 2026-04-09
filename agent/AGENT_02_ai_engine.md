# Agent 02 — AI Engine & Accuracy Layer
# Scope: Gemini prompt engineering, Cloud Run backend, confidence scoring, data grounding.
# This is the most critical agent. Accuracy first, always.

---

## Why accuracy is hard and how we solve it

A photo of soil is ambiguous. Lighting changes perceived color. Camera white balance drifts. Wet soil looks dark, dry soil looks pale — same field, different readings. Every other "AI + agriculture" project ignores this and ships garbage results.

MRIDA solves this with a 4-layer accuracy stack:

```
Layer 1: Image preprocessing      → normalize before Gemini ever sees it
Layer 2: Structured Gemini prompt  → force systematic reasoning, not guessing
Layer 3: Regional profile grounding→ Gemini output validated against ICAR state data
Layer 4: Confidence gating         → low confidence = honest warning, not false precision
```

---

## Layer 1 — Image preprocessing (Python, runs on Cloud Run before Gemini call)

```python
from PIL import Image, ImageEnhance
import io, base64

def preprocess_soil_image(image_bytes: bytes) -> str:
    """
    Normalize soil image before sending to Gemini.
    Returns base64 encoded JPEG.
    
    Steps:
    1. Resize to 1024px longest edge (Gemini optimal)
    2. Auto white balance correction (reduces camera color cast)
    3. Slight contrast boost (helps Gemini distinguish subtle color differences)
    4. Convert to JPEG 90% (quality vs size balance)
    """
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    
    # Resize — maintain aspect ratio
    max_dim = 1024
    w, h = img.size
    scale = min(max_dim / w, max_dim / h)
    if scale < 1:
        img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
    
    # Auto white balance — shift mean to neutral gray
    r, g, b = img.split()
    r_mean, g_mean, b_mean = r.getextrema()[1], g.getextrema()[1], b.getextrema()[1]
    # Gentle correction — don't overcorrect, soil has real warm tones
    r = r.point(lambda p: min(255, int(p * (128 / max(r_mean, 1)))))
    b = b.point(lambda p: min(255, int(p * (128 / max(b_mean, 1)))))
    img = Image.merge("RGB", (r, g, b))
    
    # Slight contrast boost
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.15)  # 15% boost — subtle, not aggressive
    
    # Encode
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=90)
    return base64.b64encode(buffer.getvalue()).decode()
```

---

## Layer 2 — The Gemini Prompt (the entire accuracy of MRIDA lives here)

### System prompt (loaded once, passed as system role)

```
You are an expert soil scientist and agronomist trained on Indian Agricultural Research Institute (ICAR) standards, the National Bureau of Soil Survey (NBSS&LUP) soil classification system, and the Munsell Soil Color system.

Your task is to analyze a soil photograph and provide a scientifically grounded soil health assessment. You must be precise, honest about uncertainty, and never fabricate specific numbers.

## What you can determine from a photo (with confidence)
- Munsell soil color family (hue, value, chroma approximation)
- Relative organic matter content (dark = higher OM, pale = lower OM)
- Approximate clay content (fine texture, strong structure, shrink-swell cracks)
- Surface crusting and compaction signs
- Moisture regime at time of photo (dry/moist/wet surface)
- Approximate soil order (Vertisols, Alfisols, Entisols, Inceptisols, Aridisols) based on color + structure

## What you CANNOT determine from a photo alone
- Exact NPK values in mg/kg (you can estimate ranges, not exact numbers)
- Precise pH (only rough estimate from color + regional context)
- Micronutrient status (except iron — visible as red/yellow hue)
- Salinity or sodicity (unless white surface efflorescence is visible)

## Munsell Color Reference (use this to classify soil color)
10R: Red soils — laterite, iron-rich, common in Karnataka/Kerala
2.5YR–5YR: Red-brown to yellowish-red — Alfisols, moderate fertility
7.5YR–10YR: Brown to dark yellowish-brown — high OM if dark, low if pale
2.5Y: Olive — high clay, poor drainage
10YR 2/1 to 3/2 (very dark): High organic matter, >1.5% likely
10YR 5/3 to 6/4 (brown/pale): Low OM, <0.5% likely

## Indian soil order reference (match to visible characteristics)
- Black (Vertisols, "regur"): Very dark, strong blocky structure, wide desiccation cracks → high clay, neutral-alkaline pH, high P/K retention
- Red (Alfisols): Reddish, moderate structure → iron-rich, low OM, often nitrogen-deficient
- Alluvial (Entisols/Inceptisols): Pale to medium brown, loose → variable, check region
- Laterite: Bright red-orange, hardened → iron/aluminum-rich, acidic, P fixation high
- Sandy (Entisols, coastal/desert): Pale, single-grain → low OM, nutrients, poor retention

## Confidence scoring rules
- Score 0.85–1.0: Clear high-contrast image, identifiable soil order, consistent signals
- Score 0.65–0.84: Some ambiguity (e.g. poor lighting, mixed signals)
- Score 0.40–0.64: Significant uncertainty — image quality poor or signals contradictory
- Score below 0.40: Return a graceful refusal — do not produce NPK estimates
```

### User prompt template (dynamic, built per request)

```python
def build_user_prompt(state: str, district: str, season: str, crop: str, language: str) -> str:
    return f"""
Analyze this soil photograph carefully.

Context provided by the farmer:
- State: {state}
- District: {district}  
- Current season: {season} (Kharif / Rabi / Zaid)
- Intended crop: {crop}
- Language for prescription: {language}

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
Based on soil order + color + regional context for {state}, estimate:
- Nitrogen: low / medium / high with range in kg/ha (not exact numbers — ranges only)
- Phosphorus: low / medium / high with range in kg/ha
- Potassium: low / medium / high with range in kg/ha

For each nutrient, explain the visual or regional basis for your estimate.

Step 4: pH ESTIMATION  
Estimate pH range (not a single number — always a range like 6.0–6.8).
Basis: soil color, regional typical values for {district}, {state}.

Step 5: DEFICIENCY FLAGS
List likely deficiencies given soil order + color. Only flag deficiencies you have a scientific basis for. Common patterns:
- Red soils → nitrogen, zinc often deficient
- Black soils → iron, manganese occasionally deficient
- Laterite → phosphorus fixation, boron deficiency
- Pale sandy → most nutrients low

Step 6: FERTILIZER PRESCRIPTION
For crop: {crop} in season: {season} in {state}:
Write a specific, actionable fertilizer recommendation following ICAR state-specific fertilizer recommendation guidelines.
Format: "Apply X kg/acre of Y before sowing, followed by Z at Z weeks."
Use real ICAR recommended doses — not generic advice.

Step 7: CONFIDENCE SCORE
Give an overall confidence score from 0.0 to 1.0.
If score < 0.60, add a warning explaining what made analysis uncertain.

## Output format — respond ONLY with this JSON, nothing else

{{
  "grade": "A" | "B" | "C" | "D",
  "confidence": 0.0-1.0,
  "signals": {{
    "color_description": "string — Munsell description",
    "texture_observation": "string",
    "crack_pattern": "none | fine | medium | wide",
    "moisture_level": "dry | moist | wet",
    "organic_matter_hint": "low | medium | high"
  }},
  "soil_order": "string — ICAR classification",
  "npk": {{
    "nitrogen": "Low | Medium | High",
    "nitrogen_range": "string e.g. <140 kg/ha",
    "nitrogen_basis": "string — why you estimated this",
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
    "interpretation": "string — what this means for the crop"
  }},
  "deficiencies": ["nitrogen", "zinc"],
  "prescription": {{
    "text": "Full prescription in {language} — 3-4 sentences, specific doses",
    "audio_short": "Shorter version for TTS, 1-2 sentences in {language}"
  }},
  "warning_note": null | "string — shown when confidence < 0.60"
}}
"""
```

---

## Layer 3 — Regional Profile Grounding (validates Gemini output)

### Data source: `data/regional_soil_profiles.json`
This file contains ICAR state-level typical soil profiles. Built from NBSS&LUP publications (public domain).

```json
{
  "West Bengal": {
    "dominant_soil_orders": ["Inceptisols", "Entisols"],
    "typical_ph_range": [5.5, 7.0],
    "typical_nitrogen": "low_to_medium",
    "typical_phosphorus": "low",
    "typical_potassium": "medium_to_high",
    "common_deficiencies": ["nitrogen", "zinc", "boron"],
    "notes": "Alluvial soils dominant in plains. Terai has acidic soils."
  },
  "Maharashtra": {
    "dominant_soil_orders": ["Vertisols", "Alfisols"],
    "typical_ph_range": [7.0, 8.5],
    "typical_nitrogen": "low",
    "typical_phosphorus": "medium",
    "typical_potassium": "high",
    "common_deficiencies": ["nitrogen", "sulfur", "iron"],
    "notes": "Black cotton soil dominant in Vidarbha, Marathwada."
  }
  // ... all 29 states + UTs
}
```

### Validation function

```python
def validate_against_regional_profile(
    gemini_result: dict,
    state: str,
    regional_profiles: dict
) -> dict:
    """
    Cross-check Gemini's output against known regional soil profiles.
    Flags anomalies and adjusts confidence downward if results deviate significantly.
    Does NOT override Gemini — only adds flags and adjusts confidence.
    """
    profile = regional_profiles.get(state)
    if not profile:
        return gemini_result  # no profile for this state, pass through
    
    anomalies = []
    confidence_penalty = 0.0
    
    # pH check
    ph_min = gemini_result["ph"]["min"]
    ph_max = gemini_result["ph"]["max"]
    regional_ph = profile["typical_ph_range"]
    
    if ph_max < regional_ph[0] - 1.0 or ph_min > regional_ph[1] + 1.0:
        anomalies.append(
            f"pH estimate ({ph_min}–{ph_max}) deviates significantly from "
            f"typical {state} soils ({regional_ph[0]}–{regional_ph[1]}). "
            f"Consider lab verification."
        )
        confidence_penalty += 0.10
    
    # Check if Gemini flagged deficiencies consistent with regional patterns
    regional_deficiencies = set(profile["common_deficiencies"])
    gemini_deficiencies = set(gemini_result["deficiencies"])
    
    if gemini_deficiencies and not gemini_deficiencies.intersection(regional_deficiencies):
        anomalies.append(
            f"Flagged deficiencies {list(gemini_deficiencies)} are uncommon "
            f"for {state}. Regional data suggests watching for: "
            f"{list(regional_deficiencies)}."
        )
        confidence_penalty += 0.05
    
    # Apply penalty
    adjusted_confidence = max(0.0, gemini_result["confidence"] - confidence_penalty)
    gemini_result["confidence"] = round(adjusted_confidence, 2)
    
    if anomalies:
        existing_warning = gemini_result.get("warning_note") or ""
        gemini_result["warning_note"] = (existing_warning + " " + " ".join(anomalies)).strip()
    
    return gemini_result
```

---

## Layer 4 — Confidence gating (what the app does with the score)

```
confidence >= 0.75 → Show full result, no warning. Grade prominently displayed.
confidence 0.60–0.74 → Show result with amber banner: "Moderate confidence — consider lab test for critical decisions"
confidence 0.40–0.59 → Show result with red banner: "Low confidence — lighting or image quality limited analysis. Recommendation is approximate."
confidence < 0.40 → Do NOT show NPK or prescription. Show: "Unable to analyze this image accurately. Please retake in natural daylight with soil spread flat."
```

---

## Cloud Run backend — FastAPI

### `backend/main.py`

```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import json, os, base64
from PIL import Image
import io

app = FastAPI(title="MRIDA AI Backend", version="1.0.0")

# Load regional profiles at startup (not on every request)
with open("data/regional_soil_profiles.json") as f:
    REGIONAL_PROFILES = json.load(f)

# Load SYSTEM_PROMPT at startup
with open("prompts/system_prompt.txt") as f:
    SYSTEM_PROMPT = f.read()

genai.configure(api_key=os.environ["GEMINI_API_KEY"])
model = genai.GenerativeModel(
    model_name="gemini-2.0-flash",
    system_instruction=SYSTEM_PROMPT
)

class ScanRequest(BaseModel):
    image_base64: str        # raw image bytes, base64 encoded
    user_id: str
    field_id: str
    state: str
    district: str
    season: str              # kharif | rabi | zaid
    crop: str
    language: str            # hi | bn | ta | te | mr | en
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
async def analyze_soil(request: ScanRequest):
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
            language=request.language
        )
        
        # 3. Call Gemini Vision
        image_part = {
            "mime_type": "image/jpeg",
            "data": processed_b64
        }
        
        response = model.generate_content(
            [user_prompt, image_part],
            generation_config=genai.GenerationConfig(
                temperature=0.1,          # low temp = consistent, less hallucination
                response_mime_type="application/json"
            )
        )
        
        # 4. Parse response
        result = json.loads(response.text)
        
        # 5. Validate against regional profiles
        result = validate_against_regional_profile(result, request.state, REGIONAL_PROFILES)
        
        # 6. Confidence gate — override if too low
        if result["confidence"] < 0.40:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "low_confidence",
                    "message": "Image quality insufficient for accurate analysis.",
                    "confidence": result["confidence"]
                }
            )
        
        # 7. Store to Firestore via Admin SDK + Firebase Storage
        scan_id, image_url = await store_scan_result(
            result=result,
            image_bytes=image_bytes,
            request=request
        )
        
        return ScanResponse(scan_id=scan_id, image_url=image_url, **result)
    
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Gemini returned malformed JSON. Retry.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health():
    return {"status": "ok", "model": "gemini-2.0-flash"}
```

### `backend/Dockerfile`
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

### `backend/requirements.txt`
```
fastapi==0.110.0
uvicorn==0.27.1
google-generativeai==0.5.2
firebase-admin==6.4.0
Pillow==10.2.0
pydantic==2.6.3
python-multipart==0.0.9
```

---

## Deployment

```bash
# Build and deploy to Cloud Run
gcloud builds submit --tag gcr.io/PROJECT_ID/mrida-backend
gcloud run deploy mrida-backend \
  --image gcr.io/PROJECT_ID/mrida-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-secrets GEMINI_API_KEY=gemini-api-key:latest \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10
```

---

## Prompt testing — do this before connecting Flutter

Create `backend/test_prompts.py`:

Run 10 test images through the Gemini prompt before connecting to the app.
Test images should cover:
1. Dark black cotton soil (Vertisol)
2. Red laterite soil
3. Sandy pale soil
4. Alluvial dark soil
5. Poor quality image (blurry)
6. Not-soil image (should return low confidence)
7. Wet soil
8. Dry cracked soil
9. Red soil with crust
10. Mixed/ambiguous sample

For each, log: grade, confidence, npk estimates, warning_note.
Tune the system prompt until results are scientifically consistent across all 10.

---

## Deliverables checklist
- [ ] Image preprocessing function tested with 10 soil images
- [ ] System prompt finalized — produces valid JSON 100% of the time
- [ ] User prompt template tested with 5 different state/crop combinations
- [ ] Regional profiles JSON populated for all states (use ICAR data)
- [ ] Validation function correctly flags pH anomalies in test cases
- [ ] Confidence gating tested — low quality image returns 422, not garbage result
- [ ] FastAPI server runs locally: `uvicorn main:app --reload`
- [ ] `/health` endpoint returns 200
- [ ] `/scan` endpoint tested with Postman/httpie using real soil images
- [ ] Deployed to Cloud Run, URL added to `lib/core/constants/api_constants.dart`
- [ ] Gemini temperature set to 0.1 (confirmed in code)
- [ ] response_mime_type set to application/json (confirmed — prevents prose responses)
