import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../core/utils/location_utils.dart';
import '../../models/field.dart';
import '../../providers/field_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confidence_bar.dart';
import '../../widgets/grade_widget.dart';

class FieldMapScreen extends ConsumerStatefulWidget {
  const FieldMapScreen({super.key});

  @override
  ConsumerState<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends ConsumerState<FieldMapScreen>
    with TickerProviderStateMixin {
  static final LatLngBounds _indiaBounds = LatLngBounds(
    const LatLng(6.5, 68.0),
    const LatLng(37.5, 97.5),
  );
  static const LatLng _initialIndiaCenter = LatLng(22.5, 82.0);
  static const double _minZoom = 4.5;
  static const double _maxZoom = 16.0;
  static const double _dockClearance = 96.0;

  static const List<String> _cropOptions = [
    'rice',
    'wheat',
    'cotton',
    'maize',
    'groundnut',
    'sugarcane',
    'soybean',
    'potato',
    'mustard',
    'onion',
    'other',
  ];

  final MapController _mapController = MapController();
  late final _AnimatedMapController _animatedMapController;
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _fieldAreaController = TextEditingController();

  final Map<String, Field> _optimisticFields = <String, Field>{};
  String _selectedCrop = _cropOptions.first;
  bool _isFetchingLocation = false;
  bool _isAwaitingFieldTap = false;
  LatLng? _draftFieldLocation;

  @override
  void initState() {
    super.initState();
    _animatedMapController = _AnimatedMapController(
      mapController: _mapController,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _fieldAreaController.dispose();
    super.dispose();
  }

  Future<void> _onMapTap(LatLng latLng) async {
    if (!_isAwaitingFieldTap) {
      return;
    }

    setState(() {
      _draftFieldLocation = latLng;
      _isAwaitingFieldTap = false;
    });

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Field location pinned.')),
    );
    await _openAddFieldSheet();
  }

  Future<void> _zoomBy(double delta) {
    final current = _mapController.camera;
    final targetZoom = (current.zoom + delta).clamp(_minZoom, _maxZoom);
    return _animatedMapController.animateTo(
      center: current.center,
      zoom: targetZoom,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_isFetchingLocation) {
      return;
    }

    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationUtils.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      if (!_indiaBounds.contains(latLng)) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location outside India')),
        );
        return;
      }

      await _animatedMapController.animateTo(
        center: latLng,
        zoom: 12,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch location right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _onClusterTap(MarkerClusterNode cluster) async {
    final currentZoom = _mapController.camera.zoom;
    final targetZoom = currentZoom < 6
        ? 7.0
        : currentZoom < 10
            ? 10.0
            : (currentZoom + 1).clamp(_minZoom, _maxZoom);

    await _animatedMapController.animateTo(
      center: cluster.bounds.center,
      zoom: targetZoom,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onFieldTap(Field field) async {
    final location = LatLng(field.location.latitude, field.location.longitude);
    await _animatedMapController.animateTo(
      center: location,
      zoom: 14,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    if (!mounted) {
      return;
    }
    _showFieldSheet(field);
  }

  Future<void> _openAddFieldSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> saveField() async {
              final name = _fieldNameController.text.trim();
              final areaRaw = _fieldAreaController.text.trim();
              final area = double.tryParse(areaRaw);
              final userId = ref.read(currentUserIdProvider);

              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in again.')),
                );
                return;
              }
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Field name is required.')),
                );
                return;
              }
              if (area == null || area <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid area in acres.')),
                );
                return;
              }
              if (_draftFieldLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Tap map to pin your field location first.')),
                );
                return;
              }

              setSheetState(() {});

              final createdField =
                  await ref.read(firestoreServiceProvider).addField(
                        userId: userId,
                        name: name,
                        areaAcres: area,
                        primaryCrop: _selectedCrop,
                        location: GeoPoint(
                          _draftFieldLocation!.latitude,
                          _draftFieldLocation!.longitude,
                        ),
                      );

              if (!mounted) {
                return;
              }

              setState(() {
                _optimisticFields[createdField.fieldId] = createdField;
                _fieldNameController.clear();
                _fieldAreaController.clear();
                _selectedCrop = _cropOptions.first;
                _draftFieldLocation = null;
                _isAwaitingFieldTap = false;
              });

              Navigator.of(sheetContext).pop();
            }

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  _dockOverlayPadding(context) + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: MridaColors.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add Field',
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: MridaColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fieldNameController,
                        decoration: const InputDecoration(
                          labelText: 'Field name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fieldAreaController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Area in acres',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCrop,
                        decoration:
                            const InputDecoration(labelText: 'Primary crop'),
                        items: _cropOptions
                            .map(
                              (crop) => DropdownMenuItem<String>(
                                value: crop,
                                child: Text(crop),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _selectedCrop = value);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MridaColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tap the map to pin your field location',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: MridaColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_draftFieldLocation != null)
                              Text(
                                'Pinned at ${_draftFieldLocation!.latitude.toStringAsFixed(5)}, ${_draftFieldLocation!.longitude.toStringAsFixed(5)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: MridaColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                setState(() => _isAwaitingFieldTap = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Tap anywhere on the map to set field location'),
                                  ),
                                );
                              },
                              child: const Text('Pin on map'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveField,
                          child: const Text('Save Field'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _dockOverlayPadding(BuildContext context) {
    return _dockClearance + MediaQuery.of(context).padding.bottom;
  }

  void _showFieldSheet(Field field) {
    final grade = _gradeForField(field);
    final confidence = _confidenceForField(field);
    final crop = field.crops.isEmpty ? 'No crop set' : field.crops.first;
    final lastScan = field.lastScannedAt == null
        ? 'No scan yet'
        : '${field.lastScannedAt!.day}/${field.lastScannedAt!.month}/${field.lastScannedAt!.year}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.6,
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + _dockOverlayPadding(context),
                ),
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: GradeWidget(grade: grade, size: 44),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          field.name,
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MridaColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$crop • $lastScan',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: MridaColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConfidenceBar(confidence: confidence),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/scan/result');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text('View Report'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      context.push(
                          '/scan/camera?fieldId=${Uri.encodeComponent(field.fieldId)}');
                    },
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text('Scan this field'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Field> _mergeFields(List<Field> streamFields) {
    final merged = <String, Field>{
      for (final field in streamFields) field.fieldId: field,
      ..._optimisticFields,
    };
    return merged.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<Marker> _buildFieldMarkers(List<Field> fields) {
    return fields.map((field) {
      final grade = _gradeForField(field);
      final color = _colorForGrade(grade);
      return Marker(
        key: ValueKey<String>(field.fieldId),
        point: LatLng(field.location.latitude, field.location.longitude),
        width: 36,
        height: 48,
        alignment: Alignment.bottomCenter,
        child: _FieldPin(
          grade: grade,
          color: color,
        ),
      );
    }).toList(growable: false);
  }

  double _clusterSizeForCount(int count) {
    if (count >= 50) {
      return 60;
    }
    if (count >= 10) {
      return 50;
    }
    return 40;
  }

  String _gradeForField(Field field) {
    final score = field.lastHealthScore;
    if (score == null) {
      return 'N';
    }
    if (score >= 80) {
      return 'A';
    }
    if (score >= 60) {
      return 'B';
    }
    if (score >= 40) {
      return 'C';
    }
    return 'D';
  }

  double _confidenceForField(Field field) {
    final score = field.lastHealthScore;
    if (score == null) {
      return 0.55;
    }
    return (score / 100).clamp(0.0, 1.0);
  }

  Color _colorForGrade(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF2E7D32);
      case 'B':
        return const Color(0xFF689F38);
      case 'C':
        return const Color(0xFFF57F17);
      case 'D':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(fieldsStreamProvider);
    final mergedFields = _mergeFields(fieldsAsync.value ?? const <Field>[]);
    final markers = _buildFieldMarkers(mergedFields);
    final fieldById = {
      for (final field in mergedFields) field.fieldId: field,
    };

    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialIndiaCenter,
              initialZoom: 5.0,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              cameraConstraint:
                  CameraConstraint.containCenter(bounds: _indiaBounds),
              onTap: (_, latLng) => _onMapTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                maxZoom: 19,
                retinaMode: true,
                userAgentPackageName: 'com.mrida.app',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: markers,
                  maxClusterRadius: 48,
                  disableClusteringAtZoom: 10,
                  zoomToBoundsOnClick: false,
                  centerMarkerOnClick: false,
                  spiderfyCluster: false,
                  size: const Size(40, 40),
                  computeSize: (clusterMarkers) {
                    final size = _clusterSizeForCount(clusterMarkers.length);
                    return Size(size, size);
                  },
                  onClusterTap: _onClusterTap,
                  onMarkerTap: (marker) {
                    final key = marker.key;
                    if (key is ValueKey<String>) {
                      final tappedField = fieldById[key.value];
                      if (tappedField != null) {
                        _onFieldTap(tappedField);
                      }
                    }
                  },
                  builder: (context, clusterMarkers) {
                    final size = _clusterSizeForCount(clusterMarkers.length);
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D7A5F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        clusterMarkers.length.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
              RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: const [
                  TextSourceAttribution('© OpenStreetMap © CartoDB'),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            top: 16,
            child: SafeArea(
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.add,
                    onTap: () => _zoomBy(1.0),
                  ),
                  const SizedBox(height: 10),
                  _ZoomButton(
                    icon: Icons.remove,
                    onTap: () => _zoomBy(-1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        // Keep FABs above the persistent bottom dock/nav.
        padding: EdgeInsets.only(
          bottom: _dockOverlayPadding(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'my_location_fab',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1D7A5F),
              child: _isFetchingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'add_field_fab',
              onPressed: _openAddFieldSheet,
              backgroundColor: const Color(0xFF1D7A5F),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(
                'Add Field',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: const Color(0xFF1D7A5F)),
        ),
      ),
    );
  }
}

class _FieldPin extends StatelessWidget {
  const _FieldPin({
    required this.grade,
    required this.color,
  });

  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 48,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: const Size(36, 48),
            painter: _FieldPinPainter(color: color),
          ),
          Positioned(
            top: 5,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                grade,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldPinPainter extends CustomPainter {
  const _FieldPinPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..quadraticBezierTo(0, size.height * 0.62, 0, size.height * 0.33)
      ..arcToPoint(
        Offset(size.width, size.height * 0.33),
        radius: Radius.circular(size.width / 2),
        clockwise: false,
      )
      ..quadraticBezierTo(
        size.width,
        size.height * 0.62,
        size.width / 2,
        size.height,
      )
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.2), 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FieldPinPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _AnimatedMapController {
  _AnimatedMapController({
    required this.mapController,
    required this.vsync,
  });

  final MapController mapController;
  final TickerProvider vsync;

  Future<void> animateTo({
    required LatLng center,
    required double zoom,
    required Duration duration,
    required Curve curve,
  }) async {
    final camera = mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: center.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: center.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final controller = AnimationController(vsync: vsync, duration: duration);
    final animation = CurvedAnimation(parent: controller, curve: curve);
    final completer = Completer<void>();

    controller.addListener(() {
      mapController.move(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    await controller.forward();
    await completer.future;
  }
}
