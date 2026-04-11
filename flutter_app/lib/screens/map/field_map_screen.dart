import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/utils/location_utils.dart';
import '../../theme/app_theme.dart';
import '../../widgets/grade_widget.dart';

class FieldMapScreen extends StatefulWidget {
  const FieldMapScreen({super.key});

  @override
  State<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends State<FieldMapScreen> {
  static final LatLngBounds _indiaBounds = LatLngBounds(
    const LatLng(6.0, 68.0), // South-West India extent
    const LatLng(37.6, 97.5),  // North-East India extent
  );
  static const double _minZoom = 4.8;
  static const double _maxZoom = 16.0;
  final MapController _mapController = MapController();
  LatLng? _currentUserLocation;
  bool _isFetchingLocation = false;

  void _zoomBy(double delta) {
    final currentCamera = _mapController.camera;
    final nextZoom = (currentCamera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(currentCamera.center, nextZoom);
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Icon(icon, color: MridaColors.primary),
        ),
      ),
    );
  }

  Future<void> _showCurrentUserLocation() async {
    if (_isFetchingLocation) {
      return;
    }

    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationUtils.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }

      setState(() => _currentUserLocation = userLocation);

      final currentZoom = _mapController.camera.zoom;
      final targetZoom = currentZoom < 11 ? 11.0 : currentZoom;
      _mapController.move(userLocation, targetZoom.clamp(_minZoom, _maxZoom));
    } on LocationException catch (e) {
      if (!mounted) {
        return;
      }

      final snackBar = SnackBar(
        content: Text(e.message),
        action: e.type == LocationErrorType.permissionDeniedForever
            ? SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  LocationUtils.openAppSettings();
                },
              )
            : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on Exception {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to fetch current location. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: _indiaBounds,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              cameraConstraint: CameraConstraint.contain(
                bounds: _indiaBounds,
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.tap,
              ),
              onTap: (_, __) => _showCurrentUserLocation(),
            ),
            children: [
              TileLayer(
                // No-label tiles reduce geopolitical/country-label clutter for an India-focused map.
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.mrida.app',
                retinaMode: RetinaMode.isHighDensity,
              ),
              MarkerLayer(
                markers: _buildMarkers(context),
              ),
            ],
          ),
          Positioned(
            right: 16,
            top: 16,
            child: SafeArea(
              child: Column(
                children: [
                  _buildZoomButton(
                    icon: Icons.add,
                    onPressed: () => _zoomBy(1),
                  ),
                  const SizedBox(height: 10),
                  _buildZoomButton(
                    icon: Icons.remove,
                    onPressed: () => _zoomBy(-1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/field/add'),
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

    final markers = fieldLocations.map((field) {
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

    if (_currentUserLocation != null) {
      markers.add(
        Marker(
          point: _currentUserLocation!,
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MridaColors.primary.withValues(alpha: 0.18),
              border: Border.all(color: MridaColors.primary, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.my_location,
                color: MridaColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
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
}
