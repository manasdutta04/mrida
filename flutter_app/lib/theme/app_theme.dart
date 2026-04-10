import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MridaColors {
  // Brand Colors - Terra-Digital Archive
  static const primary = Color(0xFF00241A);
  static const primaryContainer = Color(0xFF0D3B2E);
  static const onPrimary = Color(0xFFFFFFFF);
  
  static const surface = Color(0xFFFBF9F6);
  static const surfaceVariant = Color(0xFFF5F3F0);
  static const surfaceContainerHighest = Color(0xFFE4E2DF);
  
  static const textPrimary = Color(0xFF1B1C1A);
  static const textSecondary = Color(0xFF414845);
  
  // Grade Colors (Functional)
  static const gradeA = Color(0xFF2E7D32);
  static const gradeB = Color(0xFF689F38);
  static const gradeC = Color(0xFFF57F17);
  static const gradeD = Color(0xFFC62828);
  
  static const border = Color(0xFFC0C8C3);
  static const error = Color(0xFFBA1A1A);
}

class AppTheme {
  static TextTheme buildTextTheme() {
    return GoogleFonts.soraTextTheme().copyWith(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: MridaColors.textPrimary,
        letterSpacing: -0.02,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: MridaColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MridaColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: MridaColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: MridaColors.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: MridaColors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        textTheme: buildTextTheme(),
        scaffoldBackgroundColor: MridaColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MridaColors.primary,
          primary: MridaColors.primary,
          surface: MridaColors.surface,
          onPrimary: MridaColors.onPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MridaColors.primary,
            foregroundColor: MridaColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: buildTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: MridaColors.primary,
          brightness: Brightness.dark,
        ),
      );
}
