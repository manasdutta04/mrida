from validation import (
    validate_against_regional_profile,
    validate_crop_recommendations,
    validate_water_plan,
    validate_pest_disease_risk,
)


def _sample_result():
    return {
        "confidence": 0.8,
        "soil_order": "Vertisols",
        "ph": {"min": 6.8, "max": 7.4},
        "deficiencies": ["nitrogen"],
        "crop_advisory": {
            "recommended_crops": [
                {
                    "crop": "soybean",
                    "fit_score": 0.84,
                    "season_fit": "kharif",
                    "why": "black soil fit",
                }
            ],
            "water_plan": {
                "total_requirement_mm": "450-700",
                "critical_irrigation_stages": ["flowering"],
            },
            "pre_sowing_plan": {"steps": ["seed treatment"], "confidence": 0.7},
            "pest_disease_risk": [
                {
                    "name": "girdle beetle",
                    "risk_level": "medium",
                    "why_likely": "soybean in kharif",
                }
            ],
        },
    }


def test_advisory_validators():
    crop_profiles = {
        "soybean": {
            "suitable_soil_orders": ["Vertisols"],
            "suitable_ph_range": [6.0, 7.8],
            "season_windows_by_state": {"Maharashtra": ["kharif"]},
            "water_need_mm_total": "450-700",
        }
    }
    risk_matrix = {"rules": [{"likely_attack": ["girdle beetle"]}]}
    regional_profiles = {
        "Maharashtra": {
            "typical_ph_range": [6.5, 8.5],
            "common_deficiencies": ["nitrogen", "sulfur", "zinc"],
        }
    }

    result = _sample_result()
    crop_anom, crop_penalty = validate_crop_recommendations(result, "Maharashtra", crop_profiles)
    water_anom, water_penalty = validate_water_plan(result, crop_profiles)
    risk_anom, risk_penalty = validate_pest_disease_risk(result, risk_matrix)

    assert crop_penalty >= 0
    assert water_penalty >= 0
    assert risk_penalty >= 0
    assert isinstance(crop_anom, list)
    assert isinstance(water_anom, list)
    assert isinstance(risk_anom, list)

    final = validate_against_regional_profile(
        result,
        "Maharashtra",
        regional_profiles,
        crop_profiles=crop_profiles,
        risk_matrix=risk_matrix,
    )
    assert "confidence" in final
