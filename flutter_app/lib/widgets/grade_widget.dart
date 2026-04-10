import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Displays the soil grade letter (A/B/C/D) as a color-coded circle.
/// Default [size] is 80px for result screens, use 44px for list items.
class GradeWidget extends StatelessWidget {
  const GradeWidget({super.key, required this.grade, this.size = 80});
  final String grade;
  final double size;

  Color get _color {
    switch (grade.toUpperCase()) {
      case 'A':
        return MridaColors.gradeA;
      case 'B':
        return MridaColors.gradeB;
      case 'C':
        return MridaColors.gradeC;
      default:
        return MridaColors.gradeD;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.3),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        grade.toUpperCase(),
        style: GoogleFonts.sora(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
