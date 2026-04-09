import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradeWidget extends StatelessWidget {
  const GradeWidget({super.key, required this.grade, this.size = 80});
  final String grade;
  final double size;

  Color _color() {
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
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _color(),
      child: Text(
        grade.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: size, fontWeight: FontWeight.bold),
      ),
    );
  }
}
