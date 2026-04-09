import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum WarningLevel { medium, low }

class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.message, required this.level});
  final String message;
  final WarningLevel level;

  @override
  Widget build(BuildContext context) {
    final bg = level == WarningLevel.medium ? MridaColors.warning : MridaColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(Icons.warning_amber_rounded, color: bg), const SizedBox(width: 8), Expanded(child: Text(message))]),
    );
  }
}
