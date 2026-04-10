import os
import sys
from pathlib import Path

# Load env manually if needed (simple parsing for verification)
env_path = Path(__file__).parent / ".env"
if env_path.exists():
    for line in env_path.read_text().splitlines():
        if "=" in line and not line.startswith("#"):
            key, val = line.split("=", 1)
            os.environ[key.strip()] = val.strip()

def verify_gemini():
    print("--- 1. Testing Gemini API ---")
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("[FAIL] GEMINI_API_KEY not found in environment.")
        return False
    
    try:
        import google.generativeai as genai
        genai.configure(api_key=api_key)
        # Attempt to list models as a lightweight connectivity check
        models = [m.name for m in genai.list_models()]
        if any("gemini" in m for m in models):
            print("[OK] Gemini API connection successful.")
            return True
        else:
            print("[?] Gemini API connected but no Gemini models found.")
            return False
    except Exception as e:
        print(f"[FAIL] Gemini API Error: {e}")
        return False

def verify_firebase():
    print("\n--- 2. Testing Firebase Service Account ---")
    project_id = os.environ.get("FIREBASE_PROJECT_ID")
    sa_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    
    if not project_id:
        print("[FAIL] FIREBASE_PROJECT_ID not found.")
        return False
    if not sa_path:
        print("[FAIL] GOOGLE_APPLICATION_CREDENTIALS not found.")
        return False
    
    # Check if file exists
    full_path = Path(__file__).parent / sa_path
    if not full_path.exists():
        print(f"[FAIL] Service account file not found at: {full_path}")
        return False
    
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
        
        if not firebase_admin._apps:
            cred = credentials.Certificate(str(full_path))
            firebase_admin.initialize_app(cred, {'projectId': project_id})
        
        # Test Firestore connection (lightweight)
        db = firestore.client()
        # Just getting the collection reference is enough to check auth
        db.collection("health_check").limit(1).get()
        print("[OK] Firebase Admin initialization and Firestore access successful.")
        return True
    except Exception as e:
        print(f"[FAIL] Firebase Error: {e}")
        return False

if __name__ == "__main__":
    g_ok = verify_gemini()
    f_ok = verify_firebase()
    
    if g_ok and f_ok:
        print("\nEnvironment is READY for backend operations!")
        sys.exit(0)
    else:
        print("\nEnvironment check FAILED. Please check the errors above.")
        sys.exit(1)
