import json
import os
from pathlib import Path

import google.generativeai as genai

from prompts import build_user_prompt


SCENARIOS = [
    ("black_soil_kharif_soybean", "Maharashtra", "Pune", "kharif", "soybean"),
    ("red_soil_rabi_chickpea", "Karnataka", "Dharwad", "rabi", "bengal_gram"),
    ("sandy_low_confidence", "Rajasthan", "Jaisalmer", "kharif", "bajra"),
    ("humid_rice_disease_risk", "West Bengal", "Nadia", "kharif", "rice"),
    ("alluvial_wheat", "Uttar Pradesh", "Varanasi", "rabi", "wheat"),
    ("cotton_black_soil", "Gujarat", "Rajkot", "kharif", "cotton"),
    ("groundnut_coastal", "Andhra Pradesh", "Nellore", "rabi", "groundnut"),
    ("mustard_rabi_plains", "Haryana", "Hisar", "rabi", "mustard"),
    ("onion_irrigated", "Maharashtra", "Nashik", "rabi", "onion"),
    ("maize_kharif", "Bihar", "Purnia", "kharif", "maize"),
]


def _placeholder_image_b64() -> str:
    # 1x1 transparent PNG
    return (
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAoMBgXnVfS0AAAAASUVORK5CYII="
    )


def run() -> None:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("GEMINI_API_KEY not found. Printing scenario prompts only.")
        for name, state, district, season, crop in SCENARIOS:
            print(f"\n## {name}")
            print(build_user_prompt(state, district, season, crop, "en")[:250] + "...")
        return

    system_prompt = (Path(__file__).resolve().parent.parent / "prompts" / "system_prompt.txt").read_text(encoding="utf-8")
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(model_name="gemini-2.5-flash", system_instruction=system_prompt)

    for name, state, district, season, crop in SCENARIOS:
        prompt = build_user_prompt(state, district, season, crop, "en")
        response = model.generate_content(
            [prompt, {"mime_type": "image/png", "data": _placeholder_image_b64()}],
            generation_config=genai.GenerationConfig(temperature=0.1, response_mime_type="application/json"),
        )
        payload = json.loads(response.text)
        advisory = payload.get("crop_advisory", {})
        print(f"\n## {name}")
        print("Top crops:", [c.get("crop") for c in advisory.get("recommended_crops", [])[:3]])
        print("Water:", advisory.get("water_plan", {}).get("total_requirement_mm"))
        print("Risk:", [r.get("name") for r in advisory.get("pest_disease_risk", [])[:3]])
        print("Confidence:", payload.get("confidence"))


if __name__ == "__main__":
    run()
