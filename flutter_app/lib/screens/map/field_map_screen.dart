import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FieldMapScreen extends StatelessWidget {
  const FieldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Map')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 4),
      ),
    );
  }
}
