import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/scan_flow_provider.dart';
import '../../services/scan_service.dart';
import '../../theme/app_theme.dart';

/// Shown during AI analysis. Cycles through progressive messages
/// with a pulsing animated green circle.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});
  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  static const _messages = [
    'Reading soil color...',
    'Analyzing texture and structure...',
    'Checking regional soil data...',
    'Building your prescription...',
  ];

  int _messageIndex = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  bool _analysisStarted = false;

  @override
  void initState() {
    super.initState();

    // Message cycling + Navigation trigger
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      if (_messageIndex < _messages.length - 1) {
        setState(() => _messageIndex++);
      }
    });

    // ... existing pulse/rotate controllers ...
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  Future<void> _analyze() async {
    if (_analysisStarted) return;
    _analysisStarted = true;
    final request = ref.read(scanFlowRequestProvider);
    if (request == null) {
      if (!mounted) return;
      context.go('/scan/camera');
      return;
    }
    try {
      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition();
      } catch (_) {
        pos = Position(
          longitude: 0,
          latitude: 0,
          timestamp: DateTime.now(),
          accuracy: 100,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      final result = await ScanService().analyzeSoil(
        imageFile: request.imageFile,
        fieldId: request.fieldId,
        state: request.state,
        district: request.district,
        season: request.season,
        crop: request.crop,
        language: request.language,
        location: pos,
      );
      ref.read(scanFlowRequestProvider.notifier).state = null;
      if (!mounted) return;
      context.go('/scan/result', extra: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
      context.go('/scan/camera');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_analysisStarted) {
      Future.microtask(_analyze);
    }
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated pulsing ring
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _rotateController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring
                        Transform.rotate(
                          angle: _rotateController.value * 2 * math.pi,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: MridaColors.gradeA.withValues(alpha: 0.15),
                                width: 3,
                              ),
                            ),
                            child: CustomPaint(
                              painter: _ArcPainter(
                                color: MridaColors.gradeA,
                                progress: _rotateController.value,
                              ),
                            ),
                          ),
                        ),
                        // Inner filled circle
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MridaColors.gradeA.withValues(alpha: 0.08),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: MridaColors.gradeA,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Cycling message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _messages[_messageIndex],
                key: ValueKey(_messageIndex),
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MridaColors.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'This usually takes 5–10 seconds',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: MridaColors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 48),

            // Progress dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (i) {
                final isActive = i <= _messageIndex;
                return Container(
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? MridaColors.gradeA
                        : MridaColors.gradeA.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a rotating arc segment.
class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.color, required this.progress});
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.6, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
