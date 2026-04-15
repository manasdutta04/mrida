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


def validate_crop_advisory_profiles() -> list[str]:
    profiles = load_json(DATA / "crop_advisory_profiles.json")
    required_fields = [
        "suitable_soil_orders",
        "suitable_ph_range",
        "preferred_npk_pattern",
        "season_windows_by_state",
        "water_need_mm_total",
        "irrigation_stages_critical",
        "pre_sowing_instructions",
        "common_pests",
        "common_diseases",
        "preventive_actions",
        "confidence_notes",
    ]
    errors: list[str] = []
    if len(profiles.keys()) < 20:
        errors.append("CROP ADVISORY PROFILES < 20")
    for crop, payload in profiles.items():
        for field in required_fields:
            if field not in payload:
                errors.append(f"MISSING FIELD '{field}' in crop profile {crop}")
    return errors


def validate_pest_disease_matrix() -> list[str]:
    matrix = load_json(DATA / "pest_disease_risk_matrix.json")
    rules = matrix.get("rules", [])
    required_rule_fields = [
        "crop",
        "season",
        "moisture_surrogate",
        "soil_condition",
        "risk_level",
        "likely_attack",
        "early_symptoms",
        "preventive_spray_or_ipm",
        "confidence",
    ]
    errors: list[str] = []
    if not rules:
        errors.append("PEST DISEASE MATRIX has no rules")
    for idx, rule in enumerate(rules):
        for field in required_rule_fields:
            if field not in rule:
                errors.append(f"MISSING FIELD '{field}' in risk rule index {idx}")
    return errors


if __name__ == "__main__":
    all_errors: list[str] = []
    all_errors.extend(validate_regional_profiles())
    all_errors.extend(validate_crop_data())
    all_errors.extend(validate_munsell())
    all_errors.extend(validate_crop_advisory_profiles())
    all_errors.extend(validate_pest_disease_matrix())

    if all_errors:
        print("DATA VALIDATION FAILED:")
        for e in all_errors:
            print(f"  - {e}")
        sys.exit(1)
    print("All data files valid.")
    sys.exit(0)
