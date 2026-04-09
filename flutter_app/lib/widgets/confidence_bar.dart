import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final color = confidence >= 0.75
        ? MridaColors.confHigh
        : confidence >= 0.60
            ? MridaColors.confMedium
            : MridaColors.confLow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confidence: ${(confidence * 100).round()}%'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: confidence, color: color, minHeight: 8),
      ],
    );
  }
}
