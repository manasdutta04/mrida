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
        slivers: [
          // Collapsing app bar with grade
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: MridaColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 48),
                    // Grade badge
                    GradeWidget(grade: grade, size: 80),
                    const SizedBox(height: 12),
                    Text(
                      r?.fieldId ?? 'North Plot',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MridaColors.onSurface,
                      ),
                    ),
                    Text(
                      _formatDate(r?.scannedAt),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: MridaColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Confidence bar
                ConfidenceBar(confidence: confidence),
                const SizedBox(height: 16),

                // Warning banner
                if (confidence < 0.75) ...[
                  WarningBanner(
                    message: confidence < 0.60
                        ? (r?.warningNote ?? 'Low confidence. Consider retaking in natural daylight with better lighting.')
                        : 'Moderate confidence. Results may vary from lab tests. Consider soil testing for precise values.',
                    level: confidence < 0.60 ? WarningLevel.low : WarningLevel.medium,
                  ),
                  const SizedBox(height: 24),
                ],

                // ─── What we detected ───
                _SectionCard(
                  title: 'What we detected',
                  child: Column(
                    children: [
                      _DetectedRow(
                        icon: Icons.palette_outlined,
                        label: 'Color',
                        value: r?.signals.colorDescription ?? 'Dark brown (10YR 3/2)',
                      ),
                      _DetectedRow(
                        icon: Icons.grain,
                        label: 'Texture',
                        value: r?.signals.textureObservation ?? 'Fine granular',
                      ),
                      _DetectedRow(
                        icon: Icons.water_drop_outlined,
                        label: 'Moisture',
                        value: r?.signals.moistureLevel ?? 'Moist',
                      ),
                      _DetectedRow(
                        icon: Icons.eco_outlined,
                        label: 'Organic Matter',
                        value: r?.signals.organicMatterHint ?? 'Medium',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── NPK Status ───
                _SectionCard(
                  title: 'NPK Status',
                  child: Column(
                    children: [
                      NPKRow(
                        nutrient: 'N',
                        level: r?.npk.nitrogen ?? 'Low',
                        range: r?.npk.nitrogenRaw ?? '< 140 kg/ha',
                      ),
                      NPKRow(
                        nutrient: 'P',
                        level: r?.npk.phosphorus ?? 'Medium',
                        range: r?.npk.phosphorusRaw ?? '25–50 kg/ha',
                      ),
                      NPKRow(
                        nutrient: 'K',
                        level: r?.npk.potassium ?? 'High',
                        range: r?.npk.potassiumRaw ?? '> 280 kg/ha',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── pH Range ───
                _SectionCard(
                  title: 'pH Range',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${r?.ph.min ?? 6.2} – ${r?.ph.max ?? 7.0}',
                            style: GoogleFonts.sora(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: MridaColors.primary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: MridaColors.confMedium.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              _phLabel(r?.ph.min ?? 6.2),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: MridaColors.confMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // pH scale visualization
                      _PHScaleBar(min: r?.ph.min ?? 6.2, max: r?.ph.max ?? 7.0),
                      const SizedBox(height: 12),
                      Text(
                        r?.ph.interpretation ?? 'Slightly acidic — suitable for most kharif crops',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: MridaColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Deficiencies ───
                if ((r?.deficiencies ?? ['nitrogen', 'zinc']).isNotEmpty)
                  _SectionCard(
                    title: 'Likely Deficiencies',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (r?.deficiencies ?? ['nitrogen', 'zinc']).map((d) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: MridaColors.gradeD.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: MridaColors.gradeD.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            d[0].toUpperCase() + d.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MridaColors.gradeD,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                // ─── Prescription ───
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MridaColors.gradeA.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_pharmacy_outlined, color: MridaColors.gradeA, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Fertilizer Prescription',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: MridaColors.gradeA,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        r?.prescriptionText ??
                            'Apply 120 kg/ha Urea in 3 splits: 50% basal, 25% at tillering, 25% at panicle initiation. Apply 60 kg/ha DAP and 40 kg/ha MOP as basal. Correct zinc with 25 kg/ha ZnSO4.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: MridaColors.onSurface,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      VoiceButton(
                        text: r?.prescriptionAudio ??
                            'Apply Urea in 3 doses. First 50% at sowing, then 25% each at tillering and panicle. Add DAP and potash as basal.',
                        languageCode: r?.languageCode ?? 'hi-IN',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save to field button
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scan saved to field'),
                        backgroundColor: MridaColors.gradeA,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MridaColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Save to Field',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Bottom nav padding
              ]),
            ),
          ),
        ],
      ),
    );
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
