/// Scan mode determines whether to call Gemini directly or via the backend.
enum ScanMode {
  /// Phase 1: POST directly to Gemini API. No backend required.
  direct,

  /// Phase 2: POST to Cloud Run backend URL.
  backend,
}

class ApiConstants {
  ApiConstants._();

  /// Toggle between direct Gemini API and Cloud Run backend.
  /// Change to [ScanMode.backend] when Cloud Run is deployed.
  static const ScanMode scanMode = ScanMode.direct;

  /// Gemini API key — injected via --dart-define=GEMINI_API_KEY=...
  /// Get a free key at https://aistudio.google.com
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Gemini direct API endpoint (Phase 1)
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Cloud Run backend URL (Phase 2 — placeholder until deployed)
  static const String backendUrl = 'https://YOUR_CLOUD_RUN_URL';

  /// Backend scan endpoint
  static const String scanEndpoint = '$backendUrl/scan';
}
