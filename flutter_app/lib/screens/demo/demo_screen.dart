import 'package:flutter/material.dart';
class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo')),
      body: PageView(
        children: const [
          _DemoCard(grade: 'A', note: 'High confidence sample'),
          _DemoCard(grade: 'B', note: 'Moderate confidence sample'),
          _DemoCard(grade: 'C', note: 'Low confidence sample'),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.grade, required this.note});
  final String grade;
  final String note;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Grade $grade', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(note),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Sign up to scan your field')),
            ],
          ),
        ),
      ),
    );
  }
}
