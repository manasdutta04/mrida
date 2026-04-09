# Agent 04 — Data Accuracy & Soil Reference Corpus
# Scope: Build the ground-truth data layer that makes MRIDA scientifically credible.
# This agent runs PARALLEL to Agent 02 — its output feeds the AI engine.

---

## Why this matters
The difference between a toy and a tool is the data behind it.
Gemini Vision is powerful but untrained on Indian soil science specifically.
We ground it with:
1. Munsell Soil Color Chart → maps photo color to soil properties
2. ICAR state fertilizer recommendations → real government prescription data
3. NBSS&LUP regional soil profiles → typical ranges by geography
4. Crop-specific nutrient requirements → ICAR-published NPK doses

All sources are public domain Indian government research. No copyright issues.

---

## File 1: `data/munsell_soil_reference.json`
Munsell color → soil interpretation mapping.
Gemini uses this to identify soil type from photo color.

```json
{
  "munsell_mappings": [
    {
      "hue": "10R",
      "value_range": "3-5",
      "chroma_range": "3-8",
      "color_name": "Red",
      "soil_order_hint": "Alfisols, Ultisols",
      "organic_matter": "low",
      "iron_content": "high",
      "typical_regions_india": ["Karnataka", "Kerala", "Tamil Nadu", "Andhra Pradesh"],
      "notes": "Laterite-derived red soils. Iron oxide dominant."
    },
    {
      "hue": "2.5YR",
      "value_range": "3-5",
      "chroma_range": "4-8",
      "color_name": "Reddish brown",
      "soil_order_hint": "Alfisols",
      "organic_matter": "low_to_medium",
      "iron_content": "moderate",
      "typical_regions_india": ["Maharashtra", "Telangana", "Karnataka"],
      "notes": "Moderate fertility. Nitrogen often limiting."
    },
    {
      "hue": "10YR",
      "value_range": "2-3",
      "chroma_range": "1-2",
      "color_name": "Very dark brown to black",
      "soil_order_hint": "Vertisols (black cotton soil)",
      "organic_matter": "medium_to_high",
      "clay_content": "very_high",
      "typical_regions_india": ["Maharashtra", "Madhya Pradesh", "Gujarat", "Telangana"],
      "notes": "High shrink-swell. P and K generally adequate. N limiting. Wide desiccation cracks when dry."
    },
    {
      "hue": "10YR",
      "value_range": "4-6",
      "chroma_range": "3-4",
      "color_name": "Brown to yellowish brown",
      "soil_order_hint": "Inceptisols, Entisols (alluvial)",
      "organic_matter": "low_to_medium",
      "typical_regions_india": ["Uttar Pradesh", "Bihar", "West Bengal", "Punjab", "Haryana"],
      "notes": "Alluvial plains. Generally good fertility. Zinc often deficient."
    },
    {
      "hue": "2.5Y",
      "value_range": "4-6",
      "chroma_range": "2-4",
      "color_name": "Olive to light olive brown",
      "soil_order_hint": "Inceptisols, poorly drained",
      "organic_matter": "medium",
      "drainage": "poor_to_moderate",
      "typical_regions_india": ["Coastal Odisha", "Coastal AP", "Coastal Tamil Nadu"],
      "notes": "Coastal alluvials. Often saline in low-lying areas."
    },
    {
      "hue": "7.5YR",
      "value_range": "5-7",
      "chroma_range": "2-4",
      "color_name": "Light brown to pale brown",
      "soil_order_hint": "Aridisols, Entisols",
      "organic_matter": "very_low",
      "typical_regions_india": ["Rajasthan", "Gujarat (arid)", "parts of Haryana"],
      "notes": "Desert/semi-arid soils. Very low OM. Irrigation essential. Micro-nutrients often adequate (calcareous)."
    }
  ]
}
```

Build out all major Munsell hue/value combinations relevant to Indian soils. Min 20 entries covering all major soil types.

---

## File 2: `data/regional_soil_profiles.json`
All 28 states + major UTs. Source: NBSS&LUP soil maps + ICAR annual reports.

```json
{
  "Andhra Pradesh": {
    "dominant_soil_orders": ["Alfisols", "Inceptisols", "Vertisols"],
    "typical_ph_range": [5.5, 8.0],
    "ph_note": "Red soils acidic (5.5-6.5), alluvial neutral-alkaline (7.0-8.0)",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low_to_medium",
    "typical_potassium": "medium_to_high",
    "common_deficiencies": ["nitrogen", "zinc", "boron", "sulfur"],
    "problem_areas": ["Boron deficiency in groundnut belt", "Iron deficiency in upland rice"],
    "major_crops": ["rice", "groundnut", "cotton", "chili", "sugarcane"]
  },
  "Assam": {
    "dominant_soil_orders": ["Inceptisols", "Entisols"],
    "typical_ph_range": [4.5, 6.5],
    "ph_note": "Strongly to moderately acidic. Lime application common.",
    "typical_nitrogen": "medium",
    "typical_phosphorus": "low",
    "typical_potassium": "medium",
    "common_deficiencies": ["phosphorus", "zinc", "boron", "molybdenum"],
    "problem_areas": ["P fixation in acidic soils", "Al/Mn toxicity in very acidic plots"],
    "major_crops": ["rice", "tea", "jute", "mustard"]
  },
  "Bihar": {
    "dominant_soil_orders": ["Inceptisols", "Entisols"],
    "typical_ph_range": [6.5, 8.5],
    "ph_note": "Alluvial soils, neutral to slightly alkaline. Acidic in Jharkhand border areas.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low_to_medium",
    "typical_potassium": "medium_to_high",
    "common_deficiencies": ["nitrogen", "zinc", "iron (in alkaline soils)"],
    "problem_areas": ["Nitrogen leaching in sandy entisols", "Zinc deficiency in rice-wheat belt"],
    "major_crops": ["rice", "wheat", "maize", "vegetables", "lentil"]
  },
  "Gujarat": {
    "dominant_soil_orders": ["Vertisols", "Aridisols", "Entisols"],
    "typical_ph_range": [7.0, 9.0],
    "ph_note": "Black soils alkaline. Coastal soils saline in some areas.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "medium",
    "typical_potassium": "high",
    "common_deficiencies": ["nitrogen", "sulfur", "boron", "iron"],
    "problem_areas": ["Micronutrient deficiencies in calcareous soils", "Salinity in coastal belts"],
    "major_crops": ["cotton", "groundnut", "wheat", "tobacco", "sugarcane"]
  },
  "Haryana": {
    "dominant_soil_orders": ["Inceptisols", "Aridisols", "Entisols"],
    "typical_ph_range": [7.5, 9.5],
    "ph_note": "Alkaline to strongly alkaline. Sodic soils common in low-lying areas.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "medium",
    "typical_potassium": "high",
    "common_deficiencies": ["nitrogen", "zinc", "iron"],
    "problem_areas": ["Waterlogging in lower areas", "Sodicity (ESP > 15) in patches"],
    "major_crops": ["wheat", "rice", "sugarcane", "mustard", "cotton"]
  },
  "Karnataka": {
    "dominant_soil_orders": ["Alfisols", "Vertisols", "Inceptisols"],
    "typical_ph_range": [5.5, 8.0],
    "ph_note": "Red soils acidic to neutral. Black soils neutral to alkaline.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low",
    "typical_potassium": "medium",
    "common_deficiencies": ["nitrogen", "phosphorus", "zinc", "boron", "sulfur"],
    "problem_areas": ["P fixation in red soils", "Fe toxicity in lowland rice"],
    "major_crops": ["sugarcane", "cotton", "groundnut", "rice", "ragi", "coffee"]
  },
  "Kerala": {
    "dominant_soil_orders": ["Ultisols", "Inceptisols", "Entisols"],
    "typical_ph_range": [4.5, 6.5],
    "ph_note": "Strongly acidic laterite soils dominant.",
    "typical_nitrogen": "low_to_medium",
    "typical_phosphorus": "low",
    "typical_potassium": "low_to_medium",
    "common_deficiencies": ["phosphorus", "potassium", "boron", "magnesium"],
    "problem_areas": ["Very high P fixation in laterite soils", "Aluminum toxicity in acidic zones"],
    "major_crops": ["coconut", "rubber", "pepper", "cashew", "banana", "rice"]
  },
  "Madhya Pradesh": {
    "dominant_soil_orders": ["Vertisols", "Alfisols", "Inceptisols"],
    "typical_ph_range": [6.5, 8.5],
    "ph_note": "Black soils neutral-alkaline. Red soils neutral.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low_to_medium",
    "typical_potassium": "high",
    "common_deficiencies": ["nitrogen", "sulfur", "zinc", "boron"],
    "problem_areas": ["N and S deficiency in soybean belt"],
    "major_crops": ["soybean", "wheat", "rice", "pulses", "cotton"]
  },
  "Maharashtra": {
    "dominant_soil_orders": ["Vertisols", "Alfisols"],
    "typical_ph_range": [6.5, 8.5],
    "ph_note": "Black cotton soils neutral-alkaline. Red soils slightly acidic to neutral.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low_to_medium",
    "typical_potassium": "high",
    "common_deficiencies": ["nitrogen", "sulfur", "zinc", "iron", "boron"],
    "problem_areas": ["Micronutrient deficiencies increasing in intensive farming areas"],
    "major_crops": ["sugarcane", "cotton", "soybean", "onion", "grapes", "oranges"]
  },
  "Odisha": {
    "dominant_soil_orders": ["Inceptisols", "Alfisols", "Entisols"],
    "typical_ph_range": [5.0, 7.0],
    "ph_note": "Acidic to neutral. Coastal alluvials neutral to slightly alkaline.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low",
    "typical_potassium": "medium",
    "common_deficiencies": ["nitrogen", "phosphorus", "zinc", "boron"],
    "problem_areas": ["Fe toxicity in lowland rice", "High P fixation in laterite uplands"],
    "major_crops": ["rice", "groundnut", "pulses", "sugarcane"]
  },
  "Punjab": {
    "dominant_soil_orders": ["Inceptisols", "Entisols", "Aridisols"],
    "typical_ph_range": [7.5, 8.5],
    "ph_note": "Alkaline alluvials. Some areas have salinity issues.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "medium_to_high",
    "typical_potassium": "high",
    "common_deficiencies": ["nitrogen", "zinc", "iron"],
    "problem_areas": ["High P buildup from overfertilization", "Water table depletion"],
    "major_crops": ["wheat", "rice", "maize", "cotton", "potato"]
  },
  "Rajasthan": {
    "dominant_soil_orders": ["Aridisols", "Entisols", "Vertisols"],
    "typical_ph_range": [7.5, 9.5],
    "ph_note": "Alkaline to strongly alkaline. Sandy arid soils dominant.",
    "typical_nitrogen": "very_low",
    "typical_phosphorus": "low",
    "typical_potassium": "medium_to_high",
    "common_deficiencies": ["nitrogen", "phosphorus", "zinc", "iron"],
    "problem_areas": ["Very low OM in sandy arid soils", "Salinity in canal command areas"],
    "major_crops": ["mustard", "wheat", "bajra", "gram", "cumin"]
  },
  "Tamil Nadu": {
    "dominant_soil_orders": ["Alfisols", "Inceptisols", "Vertisols", "Entisols"],
    "typical_ph_range": [5.5, 8.5],
    "ph_note": "Red soils acidic. Alluvial-deltaic neutral to alkaline. Black soils alkaline.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low",
    "typical_potassium": "medium",
    "common_deficiencies": ["nitrogen", "zinc", "sulfur", "boron", "iron"],
    "problem_areas": ["Micronutrient deficiency in intensively farmed areas"],
    "major_crops": ["rice", "sugarcane", "groundnut", "cotton", "banana", "vegetables"]
  },
  "Telangana": {
    "dominant_soil_orders": ["Alfisols", "Vertisols"],
    "typical_ph_range": [6.0, 8.0],
    "ph_note": "Red soils slightly acidic to neutral. Black soils neutral to alkaline.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low_to_medium",
    "typical_potassium": "medium",
    "common_deficiencies": ["nitrogen", "zinc", "boron", "sulfur"],
    "problem_areas": ["Boron deficiency in cotton growing areas"],
    "major_crops": ["cotton", "rice", "maize", "chili", "turmeric", "soybean"]
  },
  "Uttar Pradesh": {
    "dominant_soil_orders": ["Inceptisols", "Entisols"],
    "typical_ph_range": [7.0, 8.5],
    "ph_note": "Alluvial soils, neutral to alkaline. Slightly acidic in Bundelkhand.",
    "typical_nitrogen": "low",
    "typical_phosphorus": "low_to_medium",
    "typical_potassium": "medium_to_high",
    "common_deficiencies": ["nitrogen", "zinc", "sulfur"],
    "problem_areas": ["Zinc deficiency in rice-wheat belt", "Nitrogen leaching in sandy soils"],
    "major_crops": ["wheat", "rice", "sugarcane", "potato", "pulses", "mustard"]
  },
  "West Bengal": {
    "dominant_soil_orders": ["Inceptisols", "Entisols", "Histosols (Sundarbans)"],
    "typical_ph_range": [5.0, 7.5],
    "ph_note": "Terai and hilly soils acidic. Alluvial plains neutral to slightly acidic.",
    "typical_nitrogen": "low_to_medium",
    "typical_phosphorus": "low",
    "typical_potassium": "medium",
    "common_deficiencies": ["nitrogen", "zinc", "boron", "sulfur"],
    "problem_areas": ["Fe toxicity in lowland kharif rice", "Boron deficiency in mustard"],
    "major_crops": ["rice", "jute", "potato", "vegetables", "tea", "mustard"]
  }
}
```

Add remaining states following the same schema.

---

## File 3: `data/crop_nutrient_requirements.json`
ICAR-published nutrient requirements per crop. Used to generate the prescription.

```json
{
  "rice": {
    "season": ["kharif", "boro"],
    "npk_recommendation_kg_per_ha": {
      "general": {"N": 80, "P2O5": 40, "K2O": 40},
      "high_yield": {"N": 120, "P2O5": 60, "K2O": 60},
      "by_state": {
        "West Bengal": {"N": 80, "P2O5": 40, "K2O": 40},
        "Punjab": {"N": 120, "P2O5": 60, "K2O": 40},
        "Tamil Nadu": {"N": 100, "P2O5": 50, "K2O": 50},
        "Andhra Pradesh": {"N": 100, "P2O5": 60, "K2O": 40}
      }
    },
    "split_application": "Apply 50% N + full P + full K as basal. 25% N at tillering. 25% N at panicle initiation.",
    "common_fertilizers": ["Urea (46% N)", "DAP (18% N, 46% P2O5)", "MOP (60% K2O)", "NPK 10-26-26"],
    "deficiency_corrections": {
      "zinc": "Apply 25 kg ZnSO4/ha as basal before transplanting",
      "iron": "Foliar spray 0.5% FeSO4 at 15 and 30 days after transplanting",
      "boron": "Apply 10 kg borax/ha as basal"
    }
  },
  "wheat": {
    "season": ["rabi"],
    "npk_recommendation_kg_per_ha": {
      "general": {"N": 100, "P2O5": 50, "K2O": 40},
      "high_yield": {"N": 150, "P2O5": 60, "K2O": 40},
      "by_state": {
        "Punjab": {"N": 150, "P2O5": 60, "K2O": 40},
        "Haryana": {"N": 150, "P2O5": 60, "K2O": 40},
        "Uttar Pradesh": {"N": 120, "P2O5": 60, "K2O": 40},
        "Bihar": {"N": 100, "P2O5": 60, "K2O": 30}
      }
    },
    "split_application": "Apply full P + full K + 50% N as basal. 25% N at first irrigation (CRI stage). 25% N at flowering.",
    "common_fertilizers": ["Urea", "DAP", "MOP", "SSP (16% P2O5)"],
    "deficiency_corrections": {
      "zinc": "Apply 25 kg ZnSO4/ha as basal",
      "sulfur": "Apply 40 kg SSP or 10 kg elemental sulfur/ha"
    }
  },
  "cotton": {
    "season": ["kharif"],
    "npk_recommendation_kg_per_ha": {
      "general": {"N": 100, "P2O5": 50, "K2O": 50},
      "hybrid": {"N": 150, "P2O5": 75, "K2O": 75}
    },
    "split_application": "Apply full P + K + 1/3 N at sowing. 1/3 N at first square. 1/3 N at boll development.",
    "common_fertilizers": ["Urea", "DAP", "MOP"],
    "deficiency_corrections": {
      "boron": "Foliar spray 0.2% boric acid at squaring and boll development",
      "zinc": "Apply 25 kg ZnSO4/ha as basal"
    }
  },
  "maize": {
    "season": ["kharif", "rabi"],
    "npk_recommendation_kg_per_ha": {
      "general": {"N": 120, "P2O5": 60, "K2O": 40},
      "hybrid": {"N": 180, "P2O5": 80, "K2O": 60}
    },
    "split_application": "Apply full P + K + 1/3 N at sowing. 1/3 N at knee-high stage. 1/3 N at tasseling.",
    "deficiency_corrections": {
      "zinc": "Apply 25 kg ZnSO4/ha as basal",
      "sulfur": "Apply SSP as P source (provides both P and S)"
    }
  },
  "groundnut": {
    "season": ["kharif", "rabi"],
    "npk_recommendation_kg_per_ha": {
      "general": {"N": 20, "P2O5": 40, "K2O": 40},
      "note": "Low N as it fixes atmospheric nitrogen. High P for pod development."
    },
    "split_application": "Apply all P + K + N as basal at sowing. No split needed.",
    "deficiency_corrections": {
      "calcium": "Apply 400 kg gypsum/ha at pegging stage",
      "boron": "Foliar spray 0.2% borax at pegging and pod fill",
      "iron": "Spray 0.5% FeSO4 for iron chlorosis in calcareous soils"
    }
  },
  "sugarcane": {
    "season": ["annual"],
    "npk_recommendation_kg_per_ha": {
      "plant_crop": {"N": 250, "P2O5": 100, "K2O": 125},
      "ratoon": {"N": 250, "P2O5": 60, "K2O": 125}
    },
    "split_application": "Apply full P + K at planting. N in 3 splits: at planting, 45 days, 90 days.",
    "deficiency_corrections": {
      "zinc": "Apply 25 kg ZnSO4/ha",
      "iron": "Foliar spray 1% FeSO4",
      "sulfur": "Apply 40 kg SSP"
    }
  },
  "soybean": {
    "season": ["kharif"],
    "npk_recommendation_kg_per_ha": {
      "general": {"N": 30, "P2O5": 60, "K2O": 40}
    },
    "split_application": "Apply all as basal. Seed treatment with Rhizobium inoculant.",
    "deficiency_corrections": {
      "sulfur": "Apply 20 kg S/ha as elemental sulfur or SSP",
      "boron": "Spray 0.2% borax at flowering"
    }
  }
}
```

Add: potato, tomato, onion, mustard, pulses (tur, moong, chana), banana, tea, coffee.

---

## File 4: `prompts/system_prompt.txt`
Extract the system prompt from AGENT 02 into this standalone file.
The FastAPI backend loads this at startup.
Keep it as a plain .txt file — no JSON encoding needed.

---

## Python build script: `data/build_corpus.py`

This script validates all data files for completeness and consistency before deployment.

```python
import json, sys

def validate_regional_profiles():
    with open("data/regional_soil_profiles.json") as f:
        profiles = json.load(f)
    
    required_states = [
        "Andhra Pradesh", "Assam", "Bihar", "Gujarat", "Haryana",
        "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra",
        "Odisha", "Punjab", "Rajasthan", "Tamil Nadu", "Telangana",
        "Uttar Pradesh", "West Bengal"
        # add remaining
    ]
    
    required_fields = [
        "dominant_soil_orders", "typical_ph_range", "typical_nitrogen",
        "typical_phosphorus", "typical_potassium", "common_deficiencies", "major_crops"
    ]
    
    errors = []
    for state in required_states:
        if state not in profiles:
            errors.append(f"MISSING STATE: {state}")
            continue
        for field in required_fields:
            if field not in profiles[state]:
                errors.append(f"MISSING FIELD '{field}' in {state}")
    
    return errors

def validate_crop_data():
    with open("data/crop_nutrient_requirements.json") as f:
        crops = json.load(f)
    
    required_crops = [
        "rice", "wheat", "cotton", "maize", "groundnut",
        "sugarcane", "soybean", "potato", "mustard", "onion"
    ]
    
    errors = []
    for crop in required_crops:
        if crop not in crops:
            errors.append(f"MISSING CROP: {crop}")
    
    return errors

if __name__ == "__main__":
    all_errors = []
    all_errors.extend(validate_regional_profiles())
    all_errors.extend(validate_crop_data())
    
    if all_errors:
        print("DATA VALIDATION FAILED:")
        for e in all_errors:
            print(f"  - {e}")
        sys.exit(1)
    else:
        print("All data files valid.")
        sys.exit(0)
```

Run this in CI before every deployment: `python data/build_corpus.py`

---

## Deliverables checklist
- [ ] `munsell_soil_reference.json` — min 20 entries, all major Indian soil types covered
- [ ] `regional_soil_profiles.json` — all 28 states + Delhi, Puducherry
- [ ] `crop_nutrient_requirements.json` — min 12 crops with state-specific doses
- [ ] `system_prompt.txt` — finalized, matches Agent 02 spec exactly
- [ ] `build_corpus.py` — runs clean with zero errors
- [ ] All JSON files valid (run `python -m json.tool filename.json` on each)
- [ ] Regional pH ranges cross-checked against at least one ICAR publication
- [ ] Crop NPK doses verified against ICAR Fertilizer Recommendations book (2017 edition)
