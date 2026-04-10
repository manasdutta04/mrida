import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../widgets/grade_widget.dart';

class FieldMapScreen extends StatelessWidget {
  const FieldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(20.5937, 78.9629),
              initialZoom: 4.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mrida.app',
              ),
              MarkerLayer(
                markers: _buildMarkers(context),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Field creation form coming soon')),
          );
        },
        backgroundColor: MridaColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Field',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    // Demo markers
    final fieldLocations = [
      {'name': 'North Plot', 'lat': 18.5204, 'lng': 73.8567, 'grade': 'A', 'date': '24 Oct 2024'},
      {'name': 'East Ridge', 'lat': 19.076, 'lng': 72.8777, 'grade': 'B', 'date': '12 Sep 2024'},
      {'name': 'West Orchard', 'lat': 26.9124, 'lng': 75.7873, 'grade': 'C', 'date': '05 Aug 2024'},
    ];

    return fieldLocations.map((field) {
      final grade = field['grade'] as String;
      final color = _getGradeColor(grade);

      return Marker(
        point: LatLng(field['lat'] as double, field['lng'] as double),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showFieldDetails(context, field),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showFieldDetails(BuildContext context, Map<String, dynamic> field) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MridaColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  GradeWidget(grade: field['grade'] as String, size: 44),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field['name'] as String,
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MridaColors.onSurface,
                          ),
                        ),
                        Text(
                          'Last scan: ${field['date']}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: MridaColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Usually context.go('/scan/result')
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MridaColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'View Report',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A': return MridaColors.gradeA;
      case 'B': return MridaColors.gradeB;
      case 'C': return MridaColors.gradeC;
      default: return MridaColors.gradeD;
    }
  }
}
