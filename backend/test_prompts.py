import base64
import json
import os
from pathlib import Path

import google.generativeai as genai

from prompts import build_user_prompt
from preprocessing import preprocess_soil_image


def main() -> None:
    system_prompt = (Path(__file__).resolve().parent.parent / "prompts" / "system_prompt.txt").read_text(encoding="utf-8")
    genai.configure(api_key=os.environ["GEMINI_API_KEY"])
    model = genai.GenerativeModel(model_name="gemini-2.0-flash", system_instruction=system_prompt)

    test_images = sorted((Path(__file__).parent / "test_images").glob("*"))[:3]
    for image in test_images:
        processed = preprocess_soil_image(image.read_bytes())
        user_prompt = build_user_prompt("Maharashtra", "Pune", "kharif", "soybean", "en")
        response = model.generate_content(
            [user_prompt, {"mime_type": "image/jpeg", "data": processed}],
            generation_config=genai.GenerationConfig(temperature=0.1, response_mime_type="application/json"),
        )
        payload = json.loads(response.text)
        print(f"\n### {image.name}")
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        print(f"confidence={payload.get('confidence')}")


if __name__ == "__main__":
    main()
