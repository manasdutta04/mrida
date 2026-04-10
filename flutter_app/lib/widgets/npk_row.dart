import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Single row showing N, P, or K level with colored bar.
class NPKRow extends StatelessWidget {
  const NPKRow({
    super.key,
    required this.nutrient,
    required this.level,
    required this.range,
  });
  final String nutrient;
  final String level;
  final String range;

  double get _value {
    final l = level.toLowerCase();
    if (l.contains('high')) return 0.85;
    if (l.contains('medium')) return 0.55;
    return 0.25;
  }

  Color get _color {
    final l = level.toLowerCase();
    if (l.contains('high')) return MridaColors.gradeA;
    if (l.contains('medium')) return MridaColors.confMedium;
    return MridaColors.gradeD;
  }

  String get _fullName {
    switch (nutrient.toUpperCase()) {
      case 'N':
        return 'Nitrogen';
      case 'P':
        return 'Phosphorus';
      case 'K':
        return 'Potassium';
      default:
        return nutrient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Nutrient label circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              nutrient.toUpperCase(),
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + level
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MridaColors.onSurface,
                  ),
                ),
                Text(
                  '$level · $range',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: MridaColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Colored bar
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: _value,
                  backgroundColor: _color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
