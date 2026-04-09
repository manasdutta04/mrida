# Agent 03 — Flutter UI & Design System
# Scope: Every screen, the custom theme, and navigation flow.
# Prerequisite: Agent 01 must be complete. Agent 02 backend URL must be in api_constants.dart.

---

## Design philosophy
This app is used by farmers in bright sunlight, often with dirty hands, sometimes on cheap Android phones.

Design rules that follow from this:
- Large tap targets — minimum 56px height for any interactive element
- High contrast — WCAG AA minimum, preferably AAA for critical info
- Earthy, grounded palette — not startup blue. Soil greens, warm ambers, clean whites.
- One action per screen — no cognitive overload
- Text hierarchy is aggressive — grade "A" or "B" must be readable at arm's length
- Voice output for every prescription — assume user may not read well
- Loading states are friendly and explain what's happening ("Analyzing your soil...")

---

## Color palette (define in app_theme.dart)

```dart
class MridaColors {
  // Primary — soil teal/green
  static const primary = Color(0xFF1D7A5F);       // deep green
  static const primaryLight = Color(0xFF4CAF85);   // lighter for chips
  static const primarySurface = Color(0xFFE8F5EE); // bg for green-tinted cards

  // Grade colors
  static const gradeA = Color(0xFF2E7D32);  // dark green
  static const gradeB = Color(0xFF689F38);  // olive green
  static const gradeC = Color(0xFFF57F17);  // amber
  static const gradeD = Color(0xFFC62828);  // red

  // Confidence
  static const confHigh = Color(0xFF2E7D32);    // green
  static const confMedium = Color(0xFFF57F17);  // amber
  static const confLow = Color(0xFFC62828);     // red

  // Neutrals
  static const surface = Color(0xFFFAF9F6);    // warm white, not pure white
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E5DF);
  static const textPrimary = Color(0xFF1A1A18);
  static const textSecondary = Color(0xFF6B6860);
  static const textHint = Color(0xFFA8A59E);

  // Semantic
  static const warning = Color(0xFFF57F17);
  static const error = Color(0xFFC62828);
  static const info = Color(0xFF1565C0);
}
```

## Typography

```dart
// Use Google Fonts: Sora for headings, Inter for body
// Sora is slightly geometric, earthy-feeling. Not the typical startup font.
import 'package:google_fonts/google_fonts.dart';

TextTheme buildTextTheme() {
  return GoogleFonts.soraTextTheme().copyWith(
    // Override body with Inter
    bodyLarge: GoogleFonts.inter(fontSize: 16, color: MridaColors.textPrimary),
    bodyMedium: GoogleFonts.inter(fontSize: 14, color: MridaColors.textPrimary),
    bodySmall: GoogleFonts.inter(fontSize: 12, color: MridaColors.textSecondary),
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
  );
}
```

---

## Screen specifications

### 1. SplashScreen
- Full screen, MRIDA wordmark centered, mृदा subtitle below in Devanagari
- Checks auth state: if signed in → /home, else → /login
- Duration: 1.5s max, then navigate regardless

### 2. PhoneEntryScreen
- Single phone number input with country code (+91 prefilled)
- Large "Send OTP" button — full width
- "Try Demo" text link at bottom (navigates to /demo, no auth)
- Validation: must be 10 digits after +91
- Show loading state during Firebase call

### 3. OTPScreen
- 6-box OTP input (use `pin_code_fields` package or custom Row of TextFields)
- Auto-submit when all 6 digits entered
- Countdown timer for resend (60 seconds)
- "Resend OTP" button appears after timer expires
- Back button → PhoneEntryScreen (do not pop OTP state)

### 4. HomeScreen
- Top: "Namaste, [first name]" greeting, current date
- Hero card: last scan result — grade badge (huge, A/B/C/D), field name, days ago
- Two primary CTAs: "Scan new soil" and "My fields"
- Bottom: 3 recent scans as small cards (grade + field name + date)
- Bottom nav: Home | Scan | History | Map

### 5. CameraScreen — this is the core UX moment
- Camera preview fills screen
- Overlay: thin targeting frame (not a full overlay, just 4 corner brackets)
- Instruction text: "Place phone 30cm above soil, in open shade" (in user's language)
- Two buttons: Camera shutter | Gallery pick
- After capture: show preview with "Use this photo" / "Retake" options
- No analysis yet — just capture and confirm

### 6. LoadingScreen (shown during AI analysis)
- Shown after photo confirmed, while Cloud Run call is in progress
- Animated: subtle pulsing soil graphic (SVG or Lottie)
- Progressive messages that cycle every 2s:
  - "Reading soil color..."
  - "Analyzing texture and structure..."
  - "Checking regional soil data..."
  - "Building your prescription..."
- Estimated time: 3–8 seconds
- On error: show friendly error with retry button

### 7. ResultScreen — most important screen
Layout (scrollable):

```
┌─────────────────────────────────┐
│  Soil Grade            [A]      │  ← huge grade badge, color-coded
│  [Field name] · [Date]          │
│  Confidence: ██████░░ 78%       │  ← progress bar, color-coded
│  [Warning banner if < 0.60]     │
├─────────────────────────────────┤
│  What we detected               │
│  Color: Dark brown (10YR 3/2)   │
│  Texture: Fine granular         │
│  Moisture: Moist                │
│  Organic matter: Medium         │
├─────────────────────────────────┤
│  NPK Status                     │
│  N [Low  ] ████░░░░             │
│  P [Med  ] ██████░░             │
│  K [High ] ████████             │
├─────────────────────────────────┤
│  pH Range: 6.2 – 7.0            │
│  Slightly acidic, good for rice │
├─────────────────────────────────┤
│  ⚠ Likely deficiencies          │
│  • Nitrogen  • Zinc             │
├─────────────────────────────────┤
│  Fertilizer Prescription        │
│  [Full text in user's language] │
│  [🔊 Listen] button             │
├─────────────────────────────────┤
│  [Save to field] [Share]        │
└─────────────────────────────────┘
```

Critical: The grade badge must be visible at a glance. Use 80px font for the letter.
TTS button calls `flutter_tts` with `prescription_audio_short`.

### 8. HistoryScreen
- List of past scans, grouped by field
- Each item: grade badge (small, 32px) + field name + date + confidence dot
- Tap → ResultScreen with cached data (Hive)
- Filter by field (dropdown)
- Pull to refresh from Firestore

### 9. FieldMapScreen
- Google Map with markers for each field
- Marker color = last scan grade (green/yellow/red)
- Tap marker → field detail bottom sheet
- FAB: "Add new field" → opens field creation form

### 10. DemoScreen
- No auth. Preloaded with 3 scan results from `assets/demo/`
- Carousel of 3 demo result cards
- "Sign up to scan your own field" CTA at bottom
- Same ResultScreen layout, clearly labeled "Demo result"

---

## Reusable components to build

### GradeWidget
```dart
// Displays the soil grade letter, large, color-coded
class GradeWidget extends StatelessWidget {
  final String grade; // 'A', 'B', 'C', 'D'
  final double size;  // default 80.0 for result screen, 32.0 for list
  // Background circle with grade color, white letter inside
}
```

### ConfidenceBar
```dart
// Horizontal progress bar with percentage label
// Color changes: green (>0.75), amber (0.60–0.75), red (<0.60)
class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0.0–1.0
}
```

### NPKRow
```dart
// Single row showing N, P, or K level
// Label | Level text | Colored bar
class NPKRow extends StatelessWidget {
  final String nutrient;   // 'N', 'P', 'K'
  final String level;      // 'Low', 'Medium', 'High'
  final String range;      // e.g. '< 140 kg/ha'
}
```

### WarningBanner
```dart
// Amber or red banner shown when confidence is low
// Icon + warning text
class WarningBanner extends StatelessWidget {
  final String message;
  final WarningLevel level; // medium | low
}
```

### VoiceButton
```dart
// Plays TTS for prescription text
// State: idle → playing → done
// Uses flutter_tts
class VoiceButton extends StatelessWidget {
  final String text;
  final String languageCode; // e.g. 'hi-IN', 'bn-IN'
}
```

---

## Navigation flow (implement in GoRouter)

```
Splash
  ↓ (auth check)
  ├→ /home (authenticated)
  └→ /login
       └→ /login/otp
             └→ /home

/home
  ├→ /scan/camera
  │     └→ /scan/loading
  │           ├→ /scan/result (success)
  │           └→ /scan/error (failure)
  ├→ /history
  ├→ /map
  └→ /demo (no auth, from login screen)
```

---

## Flutter scan service (calls Cloud Run)

```dart
class ScanService {
  final Dio _dio;
  
  Future<ScanResult> analyzeSoil({
    required File imageFile,
    required String fieldId,
    required String state,
    required String district,
    required String season,
    required String crop,
    required String language,
    required Position location,
  }) async {
    // 1. Compress image
    final compressed = await ImageUtils.compressForUpload(imageFile);
    final b64 = base64Encode(await compressed.readAsBytes());
    
    // 2. Call backend
    final response = await _dio.post(
      ApiConstants.scanEndpoint,
      data: {
        'image_base64': b64,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'field_id': fieldId,
        'state': state,
        'district': district,
        'season': season,
        'crop': crop,
        'language': language,
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    
    return ScanResult.fromJson(response.data);
  }
}
```

---

## Deliverables checklist
- [ ] app_theme.dart complete — all colors, typography, component themes
- [ ] All 10 screens scaffolded (no placeholder text, real layouts)
- [ ] GradeWidget renders correctly at 32px and 80px sizes
- [ ] ConfidenceBar color changes correctly at thresholds
- [ ] NPKRow displays all three nutrients
- [ ] VoiceButton plays TTS in Hindi correctly
- [ ] WarningBanner shows in amber and red variants
- [ ] CameraScreen captures and previews photo
- [ ] LoadingScreen cycles through messages
- [ ] ResultScreen is complete and matches spec layout
- [ ] DemoScreen loads from assets, no network call
- [ ] HistoryScreen fetches from Hive (offline) and Firestore (online)
- [ ] GoRouter auth guard works — unauthenticated user cannot reach /home
- [ ] App renders correctly on Pixel 4 (Android) and iPhone 12 (iOS) simulators
- [ ] All text in 6 supported languages (use ARB files with flutter_localizations)
