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

  /// Helper to get env variable with priority: 
  /// 1. --dart-define (baked in build)
  /// 2. .env file (local dev)
  /// 3. Default value
  static String _getEnv(String key, {String defaultValue = ''}) {
    const baked = String.fromEnvironment;
    // We must use the string literal 'KEY' inside the method for it to work with fromEnvironment
    // but dart-define is handled at compile time. 
    // This helper logic is slightly limited by Dart's const requirement for fromEnvironment.
    // So we'll implement it directly for each getter.
    return defaultValue;
  }

  /// Gemini API key
  static String get geminiApiKey {
    const baked = String.fromEnvironment('GEMINI_API_KEY');
    if (baked.isNotEmpty) return baked;
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  /// Backend URL (Phase 2)
  static String get backendUrl {
    const baked = String.fromEnvironment('BACKEND_URL');
    if (baked.isNotEmpty) return baked;
    return dotenv.env['BACKEND_URL'] ?? 'https://mrida.onrender.com';
  }

  /// Scan Mode
  static ScanMode get scanMode {
    const baked = String.fromEnvironment('SCAN_MODE');
    final val = baked.isNotEmpty ? baked : (dotenv.env['SCAN_MODE'] ?? 'direct');
    return val.toLowerCase() == 'backend' ? ScanMode.backend : ScanMode.direct;
  }

  /// Gemini direct API endpoint (Phase 1)
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

  /// Backend scan endpoint
  static String get scanEndpoint => '$backendUrl/scan';

  /// Free weather API (no key required)
  static const String openMeteoEndpoint = 'https://api.open-meteo.com/v1/forecast';
}
