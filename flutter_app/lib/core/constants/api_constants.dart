import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Gemini API key — injected via --dart-define=GEMINI_API_KEY=... or from .env
  /// Get a free key at https://aistudio.google.com
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Gemini direct API endpoint (Phase 1)
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

  /// Cloud Run backend URL (Phase 2 — placeholder until deployed)
  static const String backendUrl = 'https://YOUR_CLOUD_RUN_URL';

  /// Backend scan endpoint
  static const String scanEndpoint = '$backendUrl/scan';

  /// Free weather API (no key required)
  static const String openMeteoEndpoint = 'https://api.open-meteo.com/v1/forecast';
}
