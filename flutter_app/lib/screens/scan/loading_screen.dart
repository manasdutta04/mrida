import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/scan_result.dart';
import '../../models/soil_grade.dart';
import '../../theme/app_theme.dart';

/// Shown during AI analysis. Cycles through progressive messages
/// with a pulsing animated green circle.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
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

  @override
  void initState() {
    super.initState();

    // Message cycling + Navigation trigger
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      if (_messageIndex < _messages.length - 1) {
        setState(() => _messageIndex++);
      } else {
        timer.cancel();
        _navigateToResult();
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

  void _navigateToResult() {
    // Generate a high-quality mock result for the demo
    final mockResult = ScanResult(
      scanId: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: 'North Plot',
      userId: 'demo-user',
      imageUrl: '',
      grade: SoilGrade.a,
      npk: const NPKEstimate(
        nitrogen: 'High',
        phosphorus: 'Medium',
        potassium: 'High',
        nitrogenRaw: '185 kg/ha',
        phosphorusRaw: '42 kg/ha',
        potassiumRaw: '290 kg/ha',
      ),
      ph: const PHRange(
        min: 6.5,
        max: 7.2,
        interpretation: 'Ideal neutral range — excellent for cereal crops.',
      ),
      deficiencies: ['Zinc', 'Boron'],
      prescriptionText: 'Apply 110 kg/ha Urea in three splits. Use 50 kg/ha DAP as basal. For micronutrients, apply 20 kg/ha Zinc Sulphate due to visible deficiency signs in soil texture.',
      prescriptionAudio: 'Soil health is good. Apply Urea in three doses and use DAP at sowing. Add Zinc Sulphate to correct minor deficiencies.',
      confidenceScore: 0.88,
      signals: const SoilSignals(
        colorDescription: 'Dark Chrome Brown (7.5YR 3/2)',
        textureObservation: 'Fine granular with good crumb structure',
        crackPattern: 'No significant surface cracking',
        moistureLevel: 'Optimal field capacity',
        organicMatterHint: 'High (3.5% estimated)',
      ),
      languageCode: 'en',
      location: const GeoPoint(28.6139, 77.2090),
      scannedAt: DateTime.now(),
    );

    context.go('/scan/result', extra: mockResult);
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
