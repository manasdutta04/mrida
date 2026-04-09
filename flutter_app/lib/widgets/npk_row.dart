import 'package:flutter/material.dart';

class NPKRow extends StatelessWidget {
  const NPKRow({super.key, required this.nutrient, required this.level, required this.range});
  final String nutrient;
  final String level;
  final String range;

  @override
  Widget build(BuildContext context) {
    double value = 0.3;
    if (level.toLowerCase().contains('medium')) value = 0.6;
    if (level.toLowerCase().contains('high')) value = 0.9;
    return Row(
      children: [
        SizedBox(width: 24, child: Text(nutrient)),
        Expanded(child: Text('$level ($range)')),
        SizedBox(width: 120, child: LinearProgressIndicator(value: value)),
      ],
    );
  }
}
