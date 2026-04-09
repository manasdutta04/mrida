import 'package:flutter/material.dart';

class FieldDetailScreen extends StatelessWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Field $fieldId')));
  }
}
