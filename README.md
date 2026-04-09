# MRIDA (मृदा)

AI-assisted soil health analysis from a single soil photo, designed for farmers and field use.

## Why MRIDA

MRIDA is built for practical, low-friction soil diagnostics where lab tests are inaccessible or slow.  
The system prioritizes transparency and uncertainty reporting over false precision.

Core principles:
- Accuracy-first predictions grounded by regional and soil reference data
- Confidence scoring on every result
- Graceful refusal when confidence is too low
- Mobile-first UX for real farm conditions

## Repository Structure

- `flutter_app/` - Flutter mobile application (Android + iOS)
- `backend/` - FastAPI service for image preprocessing + Gemini inference
- `data/` - Soil reference datasets and corpus validation scripts
- `prompts/` - Prompt assets loaded by backend
- `agent/` - Internal execution specs used during build-out

## Tech Stack

- Frontend: Flutter, Riverpod, Go Router, Hive
- Backend: FastAPI (Python), Cloud Run
- AI: Gemini vision model + regional grounding layer
- Data: Firestore, Firebase Storage

## Getting Started

### Prerequisites

- Flutter 3.x
- Dart 3.x
- Python 3.11+
- Firebase project
- Gemini API key

### 1) Mobile app setup

```bash
cd flutter_app
flutter pub get
```

Add Firebase config files:
- Android: `flutter_app/android/app/google-services.json`
- iOS: `flutter_app/ios/Runner/GoogleService-Info.plist`

### 2) Backend setup

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Create `backend/.env` (from `.env.example`) and set:
- `GEMINI_API_KEY`
- `FIREBASE_PROJECT_ID`
- `ICAR_CORPUS_ID`
- `GOOGLE_APPLICATION_CREDENTIALS` (local only)

Run backend:

```bash
uvicorn main:app --reload --port 8080
```

### 3) Data validation

```bash
python data/build_corpus.py
```

## Quality Gates

- `flutter analyze`
- `flutter test`
- `python data/build_corpus.py`

## Open Source Governance

- License: Apache-2.0 (`LICENSE`)
- Contributions: `CONTRIBUTING.md`
- Code of Conduct: `CODE_OF_CONDUCT.md`
- Security policy: `SECURITY.md`
- Support: `SUPPORT.md`

## Disclaimer

MRIDA provides AI-assisted estimates and agronomic guidance, not certified lab diagnostics.
For high-risk or high-investment decisions, confirm with local agricultural experts or lab testing.
# mrida