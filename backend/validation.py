def _append_warning(result: dict, message: str) -> None:
    existing = result.get("warning_note") or ""
    result["warning_note"] = (existing + " " + message).strip()


def validate_crop_recommendations(gemini_result: dict, state: str, crop_profiles: dict) -> tuple[list[str], float]:
    anomalies: list[str] = []
    penalty = 0.0
    advisory = gemini_result.get("crop_advisory", {})
    recs = advisory.get("recommended_crops", [])
    soil_order = (gemini_result.get("soil_order") or "").strip()
    ph = gemini_result.get("ph", {})
    ph_min, ph_max = ph.get("min", 0), ph.get("max", 14)
    season_fit_text = " ".join((r.get("season_fit", "") for r in recs)).lower()
    for rec in recs:
        crop_name = rec.get("crop", "").lower().replace(" ", "_")
        profile = crop_profiles.get(crop_name)
        if not profile:
            anomalies.append(f"No advisory profile found for recommended crop '{rec.get('crop')}'.")
            penalty += 0.03
            continue
        if soil_order and soil_order not in profile.get("suitable_soil_orders", []):
            anomalies.append(f"{rec.get('crop')} weak soil-order fit for inferred {soil_order}.")
            penalty += 0.04
        ph_range = profile.get("suitable_ph_range", [0, 14])
        if ph_max < ph_range[0] or ph_min > ph_range[1]:
            anomalies.append(f"{rec.get('crop')} pH fit is weak for estimated pH {ph_min}-{ph_max}.")
            penalty += 0.04
        state_windows = profile.get("season_windows_by_state", {})
        if state in state_windows:
            seasons = [s.lower() for s in state_windows[state]]
            if not any(s in season_fit_text for s in seasons):
                anomalies.append(f"{rec.get('crop')} season-fit note does not align with {state} windows.")
                penalty += 0.03
    return anomalies, penalty


def validate_water_plan(gemini_result: dict, crop_profiles: dict) -> tuple[list[str], float]:
    anomalies: list[str] = []
    penalty = 0.0
    advisory = gemini_result.get("crop_advisory", {})
    plan = advisory.get("water_plan", {})
    total = str(plan.get("total_requirement_mm", "")).strip()
    recs = advisory.get("recommended_crops", [])
    if not total:
        anomalies.append("Water plan is missing total requirement.")
        return anomalies, 0.05
    if recs:
        crop = recs[0].get("crop", "").lower().replace(" ", "_")
        profile = crop_profiles.get(crop)
        if profile and str(profile.get("water_need_mm_total", "")) not in total:
            anomalies.append(f"Water requirement for {recs[0].get('crop')} appears approximate; verify locally.")
            penalty += 0.03
    return anomalies, penalty


def validate_pest_disease_risk(gemini_result: dict, risk_matrix: dict) -> tuple[list[str], float]:
    anomalies: list[str] = []
    penalty = 0.0
    advisory = gemini_result.get("crop_advisory", {})
    risks = advisory.get("pest_disease_risk", [])
    rec_crops = {r.get("crop", "").lower() for r in advisory.get("recommended_crops", [])}
    known_rules = risk_matrix.get("rules", [])
    known_attacks = {a.lower() for rule in known_rules for a in rule.get("likely_attack", [])}
    for risk in risks:
        name = str(risk.get("name", "")).lower()
        if name and name not in known_attacks:
            anomalies.append(f"Risk '{risk.get('name')}' is weakly grounded in risk matrix.")
            penalty += 0.03
        if not rec_crops:
            continue
        why = str(risk.get("why_likely", "")).lower()
        if not any(crop in why for crop in rec_crops):
            anomalies.append(f"Risk rationale for '{risk.get('name')}' does not reference recommended crops.")
            penalty += 0.02
    return anomalies, penalty


def validate_against_regional_profile(
    gemini_result: dict,
    state: str,
    regional_profiles: dict,
    crop_profiles: dict | None = None,
    risk_matrix: dict | None = None,
) -> dict:
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

    regional_def = set(profile.get("common_deficiencies", []))
    model_def = set(gemini_result.get("deficiencies", []))
    if model_def and not model_def.intersection(regional_def):
        anomalies.append(
            f"Flagged deficiencies {sorted(model_def)} are uncommon for {state}; "
            f"regional watchlist: {sorted(regional_def)}."
        )
        confidence_penalty += 0.08  # Increased penalty

    # District context check (if provided in request and available in data)
    district = gemini_result.get("district")
    if district and "district_context" in profile:
        context = profile["district_context"].get(district)
        if context:
            gemini_result["regional_note"] = f"District context ({district}): {context}"

    gemini_result["confidence"] = round(max(0.1, gemini_result["confidence"] - confidence_penalty), 2)

    if crop_profiles is not None:
        crop_anomalies, crop_penalty = validate_crop_recommendations(gemini_result, state, crop_profiles)
        anomalies.extend(crop_anomalies)
        gemini_result["confidence"] = round(max(0.0, gemini_result["confidence"] - crop_penalty), 2)

        water_anomalies, water_penalty = validate_water_plan(gemini_result, crop_profiles)
        anomalies.extend(water_anomalies)
        gemini_result["confidence"] = round(max(0.0, gemini_result["confidence"] - water_penalty), 2)

    if risk_matrix is not None:
        risk_anomalies, risk_penalty = validate_pest_disease_risk(gemini_result, risk_matrix)
        anomalies.extend(risk_anomalies)
        gemini_result["confidence"] = round(max(0.0, gemini_result["confidence"] - risk_penalty), 2)

    if anomalies:
        _append_warning(gemini_result, " ".join(anomalies))
    return gemini_result
