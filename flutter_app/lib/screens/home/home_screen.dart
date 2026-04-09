import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Namaste')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Last scan'),
              subtitle: const Text('Grade B · 2 days ago'),
              trailing: ElevatedButton(onPressed: () => context.go('/history'), child: const Text('Open')),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => context.go('/scan/camera'), child: const Text('Scan new soil')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => context.go('/map'), child: const Text('My fields')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
