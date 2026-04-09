import 'dart:async';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final messages = const [
    'Reading soil color...',
    'Analyzing texture and structure...',
    'Checking regional soil data...',
    'Building your prescription...',
  ];
  int index = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() => index = (index + 1) % messages.length);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(messages[index])));
  }
}
