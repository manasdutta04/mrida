"""
Test script for MRIDA /scan endpoint.

Usage:
    1. Start the backend: uvicorn backend.main:app --reload --port 8080
    2. Run: python backend/test_scan.py

Requires a test image in backend/test_images/ directory.
If no real soil image exists, creates a synthetic placeholder.
"""

import base64
import json
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("ERROR: 'requests' package required. Install with: pip install requests")
    sys.exit(1)

BASE_URL = "http://localhost:8080"
TEST_IMAGES_DIR = Path(__file__).parent / "test_images"


def create_placeholder_image() -> Path:
    """Create a synthetic soil-colored test image if none exists."""
    try:
        from PIL import Image
    except ImportError:
        print("ERROR: Pillow required to generate placeholder. pip install Pillow")
        sys.exit(1)

    placeholder = TEST_IMAGES_DIR / "test_soil_placeholder.jpg"
    if placeholder.exists():
        return placeholder

    # Create a brown/dark soil-colored image (200x200)
    img = Image.new("RGB", (200, 200), color=(101, 67, 33))  # dark brown soil color
    # Add some variation to simulate soil texture
    import random
    random.seed(42)
    pixels = img.load()
    for x in range(200):
        for y in range(200):
            r_offset = random.randint(-15, 15)
            g_offset = random.randint(-10, 10)
            b_offset = random.randint(-8, 8)
            pixels[x, y] = (
                max(0, min(255, 101 + r_offset)),
                max(0, min(255, 67 + g_offset)),
                max(0, min(255, 33 + b_offset)),
            )

    img.save(placeholder, "JPEG", quality=90)
    print(f"Created placeholder test image: {placeholder}")
    return placeholder


def get_test_image() -> Path:
    """Find a test image or create a placeholder."""
    # Look for any existing image
    for ext in ("*.jpg", "*.jpeg", "*.png"):
        images = list(TEST_IMAGES_DIR.glob(ext))
        if images:
            return images[0]

    # No image found, create placeholder
    return create_placeholder_image()


def test_health() -> bool:
    """Test GET /health endpoint."""
    print("=" * 60)
    print("TEST: GET /health")
    print("=" * 60)
    try:
        resp = requests.get(f"{BASE_URL}/health", timeout=5)
        data = resp.json()
        print(f"Status: {resp.status_code}")
        print(f"Response: {json.dumps(data, indent=2)}")

        assert resp.status_code == 200, f"Expected 200, got {resp.status_code}"
        assert data["status"] == "ok", f"Expected 'ok', got {data['status']}"
        assert data["model"] == "gemini-2.5-flash", f"Expected 'gemini-2.5-flash', got {data['model']}"

        print("✅ /health PASSED\n")
        return True
    except requests.ConnectionError:
        print("❌ FAILED: Cannot connect to backend. Is it running on port 8080?")
        print("   Start with: uvicorn backend.main:app --reload --port 8080")
        return False
    except Exception as e:
        print(f"❌ FAILED: {e}")
        return False


def test_scan() -> bool:
    """Test POST /scan endpoint."""
    print("=" * 60)
    print("TEST: POST /scan")
    print("=" * 60)

    image_path = get_test_image()
    print(f"Using test image: {image_path}")

    with open(image_path, "rb") as f:
        image_b64 = base64.b64encode(f.read()).decode("utf-8")

    payload = {
        "image_base64": image_b64,
        "user_id": "test-user-001",
        "field_id": "test-field-001",
        "state": "Maharashtra",
        "district": "Pune",
        "season": "kharif",
        "crop": "soybean",
        "language": "en",
        "latitude": 18.5204,
        "longitude": 73.8567,
    }

    try:
        print("Sending scan request (this may take 15-30 seconds)...")
        resp = requests.post(
            f"{BASE_URL}/scan",
            json=payload,
            timeout=120,
        )

        if resp.status_code == 422:
            detail = resp.json().get("detail", {})
            if isinstance(detail, dict) and detail.get("error") == "low_confidence":
                print(f"Status: 422 (Low Confidence)")
                print(f"Confidence: {detail.get('confidence')}")
                print(f"Message: {detail.get('message')}")
                print("⚠️  /scan returned low_confidence (expected for placeholder images)")
                return True

        data = resp.json()
        print(f"Status: {resp.status_code}")
        print(f"\nFull Response:")
        print(json.dumps(data, indent=2, ensure_ascii=False))

        if resp.status_code == 200:
            print(f"\n--- Summary ---")
            print(f"Grade: {data.get('grade')}")
            print(f"Confidence: {data.get('confidence')}")
            print(f"Soil Order: {data.get('soil_order')}")
            print(f"NPK: N={data['npk'].get('nitrogen')}, P={data['npk'].get('phosphorus')}, K={data['npk'].get('potassium')}")
            print(f"pH: {data['ph'].get('min')} - {data['ph'].get('max')}")
            print(f"Deficiencies: {data.get('deficiencies')}")
            print(f"Prescription: {data['prescription'].get('text', '')[:120]}...")
            print(f"Warning: {data.get('warning_note')}")
            print("✅ /scan PASSED\n")
            return True
        else:
            print(f"❌ FAILED: Unexpected status {resp.status_code}")
            return False

    except requests.ConnectionError:
        print("❌ FAILED: Cannot connect to backend.")
        return False
    except Exception as e:
        print(f"❌ FAILED: {e}")
        return False


if __name__ == "__main__":
    print("\n🌱 MRIDA Backend Test Suite\n")

    health_ok = test_health()
    if not health_ok:
        print("\n💀 Backend not running. Aborting scan test.")
        sys.exit(1)

    scan_ok = test_scan()

    print("=" * 60)
    if health_ok and scan_ok:
        print("🎉 All tests passed!")
    else:
        print("❌ Some tests failed.")
        sys.exit(1)
