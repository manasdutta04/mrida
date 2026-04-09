import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MridaColors {
  static const primary = Color(0xFF1D7A5F);
  static const primaryLight = Color(0xFF4CAF85);
  static const primarySurface = Color(0xFFE8F5EE);
  static const gradeA = Color(0xFF2E7D32);
  static const gradeB = Color(0xFF689F38);
  static const gradeC = Color(0xFFF57F17);
  static const gradeD = Color(0xFFC62828);
  static const confHigh = Color(0xFF2E7D32);
  static const confMedium = Color(0xFFF57F17);
  static const confLow = Color(0xFFC62828);
  static const surface = Color(0xFFFAF9F6);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8E5DF);
  static const textPrimary = Color(0xFF1A1A18);
  static const textSecondary = Color(0xFF6B6860);
  static const warning = Color(0xFFF57F17);
  static const error = Color(0xFFC62828);
}

class AppTheme {
  static TextTheme buildTextTheme() {
    return GoogleFonts.soraTextTheme().copyWith(
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: MridaColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: MridaColors.textPrimary),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: MridaColors.textSecondary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        textTheme: buildTextTheme(),
        scaffoldBackgroundColor: MridaColors.surface,
        colorScheme: ColorScheme.fromSeed(seedColor: MridaColors.primary),
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
