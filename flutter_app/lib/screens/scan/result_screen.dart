import 'package:flutter/material.dart';

import '../../models/scan_result.dart';
import '../../widgets/confidence_bar.dart';
import '../../widgets/grade_widget.dart';
import '../../widgets/npk_row.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/warning_banner.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.result});

  final ScanResult? result;

  @override
  Widget build(BuildContext context) {
    final confidence = result?.confidenceScore ?? 0.78;
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [GradeWidget(grade: (result?.grade.name ?? 'B').toUpperCase(), size: 80), const SizedBox(width: 16), Expanded(child: ConfidenceBar(confidence: confidence))]),
          if (confidence < 0.60) ...[
            const SizedBox(height: 12),
            WarningBanner(
              message: result?.warningNote ?? 'Low confidence. Retake in natural daylight.',
              level: confidence < 0.40 ? WarningLevel.low : WarningLevel.medium,
            ),
          ],
          const SizedBox(height: 16),
          const Text('NPK Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          NPKRow(nutrient: 'N', level: result?.npk.nitrogen ?? 'Medium', range: result?.npk.nitrogenRaw ?? 'medium'),
          NPKRow(nutrient: 'P', level: result?.npk.phosphorus ?? 'Medium', range: result?.npk.phosphorusRaw ?? 'medium'),
          NPKRow(nutrient: 'K', level: result?.npk.potassium ?? 'High', range: result?.npk.potassiumRaw ?? 'high'),
          const SizedBox(height: 16),
          Text('pH: ${result?.ph.min ?? 6.2} - ${result?.ph.max ?? 7.0}'),
          const SizedBox(height: 8),
          Text(result?.prescriptionText ?? 'Apply balanced NPK based on crop stage and split nitrogen in two doses.'),
          const SizedBox(height: 12),
          VoiceButton(text: result?.prescriptionAudio ?? 'Use split dose fertilizer.', languageCode: 'hi-IN'),
        ],
      ),
    );
  }
}
