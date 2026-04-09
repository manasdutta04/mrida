# MRIDA — Claude Code Master Context

## What this project is
MRIDA (मृदा, Sanskrit for "soil") is a Flutter mobile app (iOS + Android) that diagnoses soil health from a single photograph using Gemini Vision AI. No lab. No kit. No cost. Built for the Google Solution Challenge 2026.

## Accuracy is the #1 priority
This is not a chatbot or a wrapper. The AI output (NPK estimate, pH range, deficiencies, fertilizer prescription) must be scientifically grounded. Every result must carry a confidence score. When confidence is low, the app must say so — never hallucinate a precise result. See `agents/02-ai-engine/AGENT.md` for the full accuracy strategy.

## Project structure
```
mrida/
├── CLAUDE.md                  ← you are here
├── agents/
│   ├── 01-project-setup/      ← Flutter scaffold, Firebase wiring, folder structure
│   │   └── AGENT.md
│   ├── 02-ai-engine/          ← Gemini prompt, Cloud Run backend, accuracy layer
│   │   └── AGENT.md
│   ├── 03-flutter-ui/         ← All screens, theme, design system
│   │   └── AGENT.md
│   └── 04-data-accuracy/      ← ICAR corpus, Munsell table, regional soil profiles
│       └── AGENT.md
├── backend/                   ← Cloud Run FastAPI service
├── flutter_app/               ← Flutter source
└── data/                      ← Soil reference data (ICAR, Munsell, regional profiles)
```

## Tech stack (locked — do not deviate)
- **Frontend**: Flutter 3.x, Riverpod 2.x, Go Router, Hive (offline), Material 3 custom theme
- **AI**: Gemini 2.0 Flash (vision + text), Vertex AI for RAG grounding
- **Backend**: Python FastAPI on Cloud Run (stateless, scales to zero)
- **Auth**: Firebase Auth — phone number OTP only (no email, farmers use phones)
- **DB**: Firestore (scans, fields, user profiles)
- **Storage**: Firebase Storage (compressed soil images, max 800px, JPEG 85%)
- **Maps**: Google Maps Flutter SDK
- **Voice**: flutter_tts for prescription readout

## Languages supported
Hindi (hi), Bengali (bn), Tamil (ta), Telugu (te), Marathi (mr), English (en)
Language selection at onboarding. Stored in user profile. All AI prescriptions generated in user's language.

## Firestore collections
```
users/{uid}
users/{uid}/fields/{fieldId}
users/{uid}/scans/{scanId}
```
Full schema in agents/01-project-setup/AGENT.md.

## Environment variables
All secrets via Google Secret Manager. Never hardcode API keys. Backend reads from env at runtime.
Required:
- GEMINI_API_KEY
- FIREBASE_PROJECT_ID
- ICAR_CORPUS_ID (Vertex AI RAG corpus)

## Code quality rules
- Dart: strong mode, no dynamic types, use freezed for models
- Python: type hints everywhere, pydantic models for all request/response schemas
- No TODO comments left in committed code
- Every Gemini call must have a try/catch with graceful degradation
- Offline-first: app must work without internet for viewing past scans

## Do not build
- Social features, sharing, community
- Paid tiers or subscriptions
- Anything not directly useful to a farmer in a field

## Demo mode
App must have a "Demo" button on the login screen that bypasses auth and loads 3 pre-cached scan results. This is for the hackathon presentation — judge picks up phone, hits Demo, sees results instantly.
