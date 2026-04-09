import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def validate_regional_profiles() -> list[str]:
    profiles = load_json(DATA / "regional_soil_profiles.json")
    required_states = [
        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
        "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
        "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram",
        "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu",
        "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal",
        "Delhi", "Puducherry",
    ]
    required_fields = [
        "dominant_soil_orders", "typical_ph_range", "typical_nitrogen",
        "typical_phosphorus", "typical_potassium", "common_deficiencies", "major_crops"
    ]

    errors: list[str] = []
    for state in required_states:
        if state not in profiles:
            errors.append(f"MISSING STATE: {state}")
            continue
        for field in required_fields:
            if field not in profiles[state]:
                errors.append(f"MISSING FIELD '{field}' in {state}")
    return errors


def validate_crop_data() -> list[str]:
    crops = load_json(DATA / "crop_nutrient_requirements.json")
    required_crops = [
        "rice", "wheat", "cotton", "maize", "groundnut", "sugarcane",
        "soybean", "potato", "mustard", "onion", "tur_dal", "bengal_gram"
    ]
    errors: list[str] = []
    for crop in required_crops:
        if crop not in crops:
            errors.append(f"MISSING CROP: {crop}")
    return errors


def validate_munsell() -> list[str]:
    munsell = load_json(DATA / "munsell_soil_reference.json")
    entries = munsell.get("munsell_mappings", [])
    if len(entries) < 20:
        return ["MUNSELL ENTRIES < 20"]
    return []


if __name__ == "__main__":
    all_errors: list[str] = []
    all_errors.extend(validate_regional_profiles())
    all_errors.extend(validate_crop_data())
    all_errors.extend(validate_munsell())

    if all_errors:
        print("DATA VALIDATION FAILED:")
        for e in all_errors:
            print(f"  - {e}")
        sys.exit(1)
    print("All data files valid.")
    sys.exit(0)
