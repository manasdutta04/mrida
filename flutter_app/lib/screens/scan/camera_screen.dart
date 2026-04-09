import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Soil')),
      body: Stack(
        children: [
          Container(color: Colors.black12),
          const Center(child: Text('Place phone 30cm above soil, in open shade')),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(onPressed: () => context.go('/scan/loading'), child: const Text('Gallery pick')),
                  ElevatedButton(onPressed: () => context.go('/scan/loading'), child: const Text('Use this photo')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
