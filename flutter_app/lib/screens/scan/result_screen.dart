import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/scan_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confidence_bar.dart';
import '../../widgets/grade_widget.dart';
import '../../widgets/npk_row.dart';
import '../../widgets/voice_button.dart';
import '../../widgets/warning_banner.dart';

/// Full scrollable result screen — the most critical screen in the app.
/// Shows grade, confidence, detected signals, NPK, pH, deficiencies,
/// prescription with voice output, and save button.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.result});
  final ScanResult? result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final confidence = r?.confidenceScore ?? 0.78;
    final grade = r?.grade.name.toUpperCase() ?? 'B';

    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // High-Impact Hero Header
          SliverToBoxAdapter(
            child: Container(
              height: 380,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/demo/hero_field.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r?.fieldId?.toUpperCase() ?? 'NORTH PLOT',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: 3.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ANALYSIS\nCOMPLETE',
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 40,
                                height: 0.9,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Text(
                            grade,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              color: MridaColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Confidence & Warning
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CONFIDENCE',
                              style: theme.textTheme.labelLarge?.copyWith(fontSize: 8, letterSpacing: 2.0),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(confidence * 100).toInt()}%',
                              style: theme.textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: confidence < 0.75 ? MridaColors.gradeD.withValues(alpha: 0.05) : MridaColors.gradeA.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          confidence < 0.75 ? 'FOLLOW-UP RECOMMENDED' : 'PRECISION VERIFIED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: confidence < 0.75 ? MridaColors.gradeD : MridaColors.gradeA,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Bento Section: Signals
                Text(
                  'OBSERVED SIGNALS',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildBentoTile('COLOR', r?.signals.colorDescription ?? 'Brown', Icons.palette_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildBentoTile('TEXTURE', r?.signals.textureObservation ?? 'Granular', Icons.grain)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildBentoTile('MOISTURE', r?.signals.moistureLevel ?? 'Moist', Icons.water_drop_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildBentoTile('ORGANIC', r?.signals.organicMatterHint ?? 'Medium', Icons.eco_outlined)),
                  ],
                ),
                const SizedBox(height: 32),

                // NPK Performance Grid
                Text(
                  'NUTRIENT PERFORMANCE',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MridaColors.primary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      _buildNPKPerformanceRow('Nitrogen', r?.npk.nitrogen ?? 'Low', Colors.white),
                      const Divider(color: Colors.white24, height: 32),
                      _buildNPKPerformanceRow('Phosphorus', r?.npk.phosphorus ?? 'Medium', Colors.white),
                      const Divider(color: Colors.white24, height: 32),
                      _buildNPKPerformanceRow('Potassium', r?.npk.potassium ?? 'High', Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Prescription Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRESCRIPTION',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        r?.prescriptionText ?? 'Apply Urea and Potash as prescribed...',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      VoiceButton(
                        text: r?.prescriptionAudio ?? 'Audio prescription...',
                        languageCode: r?.languageCode ?? 'hi-IN',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Action Buttons
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('SAVE TO FIELD'),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: MridaColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2.0),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNPKPerformanceRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: color.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
        ),
        Text(
          value.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ],
  }

  String _formatDate(DateTime? date) {
    final d = date ?? DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _phLabel(double ph) {
    if (ph < 5.5) return 'Strongly acidic';
    if (ph < 6.5) return 'Moderately acidic';
    if (ph < 7.0) return 'Slightly acidic';
    if (ph < 7.5) return 'Neutral';
    if (ph < 8.0) return 'Slightly alkaline';
    return 'Alkaline';
  }
}

/// A titled section card used throughout the result screen.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: MridaColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// A single labeled row in the "What we detected" section.
class _DetectedRow extends StatelessWidget {
  const _DetectedRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: MridaColors.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: MridaColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: MridaColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MridaColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual pH scale bar showing the estimated range.
class _PHScaleBar extends StatelessWidget {
  const _PHScaleBar({required this.min, required this.max});
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    // pH scale: 3.0 to 10.0 mapped to bar width
    const phMin = 3.0;
    const phMax = 10.0;
    final leftFraction = ((min - phMin) / (phMax - phMin)).clamp(0.0, 1.0);
    final rightFraction = ((max - phMin) / (phMax - phMin)).clamp(0.0, 1.0);

    return SizedBox(
      height: 12,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final left = leftFraction * totalWidth;
          final width = (rightFraction - leftFraction) * totalWidth;

          return Stack(
            children: [
              // Background gradient
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC62828), // 3 - strongly acid
                      Color(0xFFF57F17), // 5 - acid
                      Color(0xFF689F38), // 6.5 - neutral
                      Color(0xFF2E7D32), // 7 - neutral
                      Color(0xFF689F38), // 8 - alkaline
                      Color(0xFFF57F17), // 9 - strongly alkaline
                      Color(0xFFC62828), // 10 - very strongly alkaline
                    ],
                  ),
                ),
              ),
              // Range indicator
              Positioned(
                left: left,
                child: Container(
                  width: width.clamp(4.0, totalWidth),
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: MridaColors.onSurface, width: 2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
