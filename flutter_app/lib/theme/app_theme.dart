import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MridaColors {
  // Brand Tones - Terra-Digital Archive
  static const primary = Color(0xFF00241A);
  static const primaryContainer = Color(0xFF0D3B2E);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF79A694);

  // Surface Hierarchy
  static const surface = Color(0xFFFBF9F6);
  static const surfaceVariant = Color(0xFFE4E2DF);
  static const surfaceContainerLow = Color(0xFFF5F3F0);
  static const surfaceContainer = Color(0xFFEFEEEB);
  static const surfaceContainerHigh = Color(0xFFEAE8E5);
  static const surfaceContainerHighest = Color(0xFFE4E2DF);
  static const surfaceDim = Color(0xFFDBDAD7);
  static const surfaceBright = Color(0xFFFBF9F6);

  // Text & UI
  static const onSurface = Color(0xFF1B1C1A);
  static const onSurfaceVariant = Color(0xFF414845);
  static const outline = Color(0xFF717974);
  static const outlineVariant = Color(0xFFC0C8C3);
  static const surfaceTint = Color(0xFF3C6658);

  // Secondary Tones
  static const secondary = Color(0xFF5E5E5B);
  static const secondaryContainer = Color(0xFFE1DFDB);
  static const onSecondaryContainer = Color(0xFF63635F);

  // Tertiary & Functional
  static const tertiary = Color(0xFF281C1C);
  static const tertiaryContainer = Color(0xFF3E3131);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);

  // Legacy/Functional Restored
  static const confHigh = Color(0xFF1D7A5F);
  static const confMedium = Color(0xFF8A8A42);
  static const confLow = Color(0xFFD97706);
  static const warning = Color(0xFFF57F17);

  // Grade Colors (Functional)
  static const gradeA = Color(0xFF1D7A5F);
  static const gradeB = Color(0xFF8A8A42);
  static const gradeC = Color(0xFFD97706);
  static const gradeD = Color(0xFFD32F2F);

  // Custom Effects
  static const editorialShadow = [
    BoxShadow(
      color: Color.fromRGBO(27, 28, 26, 0.06),
      offset: Offset(0, 20),
      blurRadius: 40,
    ),
  ];
}

class AppTheme {
  static TextTheme buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: MridaColors.onSurface,
        letterSpacing: -0.02,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: MridaColors.onSurface,
        letterSpacing: -0.01,
      ),
      headlineLarge: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: MridaColors.onSurface,
      ),
      headlineMedium: GoogleFonts.epilogue(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: MridaColors.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: MridaColors.onSurface,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: MridaColors.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: MridaColors.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: MridaColors.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: MridaColors.onSurfaceVariant,
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
          onPrimary: MridaColors.onPrimary,
          primaryContainer: MridaColors.primaryContainer,
          onPrimaryContainer: MridaColors.onPrimaryContainer,
          surface: MridaColors.surface,
          onSurface: MridaColors.onSurface,
          surfaceContainerHighest: MridaColors.surfaceVariant,
          onSurfaceVariant: MridaColors.onSurfaceVariant,
          outline: MridaColors.outline,
          outlineVariant: MridaColors.outlineVariant,
          error: MridaColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MridaColors.primary,
            foregroundColor: MridaColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: const StadiumBorder(),
            elevation: 0,
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MridaColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          labelStyle: GoogleFonts.inter(
            color: MridaColors.onSecondaryContainer,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: MridaColors.onSecondaryContainer.withValues(alpha: 0.5),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: buildTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: MridaColors.primary,
          brightness: Brightness.dark,
          primary: MridaColors.primary,
        ),
      );
}
