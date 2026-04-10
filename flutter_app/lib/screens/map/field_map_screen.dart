import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_theme.dart';

/// Field map screen using OpenStreetMap (no API key, no billing).
class FieldMapScreen extends StatelessWidget {
  const FieldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text(
            'Field Map',
            style: GoogleFonts.sora(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: MridaColors.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location, color: MridaColors.primary),
              onPressed: () {
                // Future: center on user's GPS location
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(20.5937, 78.9629), // Center of India
              initialZoom: 4.5,
            ),
            children: [
              // OpenStreetMap tile layer — free, no key required
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mrida.app',
              ),

              // Field markers — colored by soil grade
              CircleLayer(
                circles: _buildFieldMarkers(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Demo field markers with grade-based color coding.
  /// In production, these come from Firestore field documents.
  List<CircleMarker> _buildFieldMarkers() {
    return [
      // Grade A — healthy (green)
      CircleMarker(
        point: const LatLng(18.5204, 73.8567), // Pune
        radius: 12,
        color: const Color(0xFF2E7D32).withOpacity(0.7),
        borderColor: const Color(0xFF2E7D32),
        borderStrokeWidth: 2,
      ),
      // Grade B — moderate (olive)
      CircleMarker(
        point: const LatLng(19.076, 72.8777), // Mumbai
        radius: 12,
        color: const Color(0xFF827717).withOpacity(0.7),
        borderColor: const Color(0xFF827717),
        borderStrokeWidth: 2,
      ),
      // Grade C — needs attention (amber)
      CircleMarker(
        point: const LatLng(26.9124, 75.7873), // Jaipur
        radius: 12,
        color: const Color(0xFFF57F17).withOpacity(0.7),
        borderColor: const Color(0xFFF57F17),
        borderStrokeWidth: 2,
      ),
      // Grade D — critical (red)
      CircleMarker(
        point: const LatLng(22.5726, 88.3639), // Kolkata
        radius: 12,
        color: const Color(0xFFC62828).withOpacity(0.7),
        borderColor: const Color(0xFFC62828),
        borderStrokeWidth: 2,
      ),
    ];
  }
}
