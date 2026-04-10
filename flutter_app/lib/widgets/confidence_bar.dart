import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Horizontal confidence bar with percentage label.
/// Color changes: green (≥0.75), amber (0.60–0.74), red (<0.60).
class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.confidence});
  final double confidence;

  Color get _color {
    if (confidence >= 0.75) return MridaColors.confHigh;
    if (confidence >= 0.60) return MridaColors.confMedium;
    return MridaColors.confLow;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'CONFIDENCE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: MridaColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '$pct%',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: confidence.clamp(0.0, 1.0),
              backgroundColor: _color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
        ),
      ],
    );
  }
}
