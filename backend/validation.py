def validate_against_regional_profile(gemini_result: dict, state: str, regional_profiles: dict) -> dict:
    profile = regional_profiles.get(state)
    if not profile:
        return gemini_result

    anomalies: list[str] = []
    confidence_penalty = 0.0

    ph_min = gemini_result["ph"]["min"]
    ph_max = gemini_result["ph"]["max"]
    regional_ph = profile["typical_ph_range"]
    if ph_max < regional_ph[0] - 1.0 or ph_min > regional_ph[1] + 1.0:
        anomalies.append(
            f"pH estimate ({ph_min}-{ph_max}) deviates from typical {state} soils "
            f"({regional_ph[0]}-{regional_ph[1]}). Consider lab verification."
        )
        confidence_penalty += 0.10

    regional_def = set(profile["common_deficiencies"])
    model_def = set(gemini_result.get("deficiencies", []))
    if model_def and not model_def.intersection(regional_def):
        anomalies.append(
            f"Flagged deficiencies {sorted(model_def)} are uncommon for {state}; "
            f"regional watchlist: {sorted(regional_def)}."
        )
        confidence_penalty += 0.05

    gemini_result["confidence"] = round(max(0.0, gemini_result["confidence"] - confidence_penalty), 2)
    if anomalies:
        existing = gemini_result.get("warning_note") or ""
        gemini_result["warning_note"] = (existing + " " + " ".join(anomalies)).strip()
    return gemini_result
