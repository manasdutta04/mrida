import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/field_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/scan_result.dart';
import '../../theme/app_theme.dart';
import '../../widgets/voice_button.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full scrollable result screen — the most critical screen in the app.
/// Shows grade, confidence, detected signals, NPK, pH, deficiencies,
/// prescription with voice output, and save button.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, this.result});
  final ScanResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
                  image: AssetImage('assets/demo/field_hero.png'),
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
                              r?.fieldId.toUpperCase() ?? 'NEW SCAN',
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
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Confidence Bento Tile
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MridaColors.primary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI CONFIDENCE',
                            style: theme.textTheme.labelLarge?.copyWith(fontSize: 8, letterSpacing: 2.0, color: Colors.white60),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(confidence * 100).toInt()}%',
                            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      const Icon(Icons.verified, color: Colors.white, size: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // NPK Performance Bento Card
                _NPKPerformanceCard(result: r, mapFn: _mapNPKToValue),
                const SizedBox(height: 32),

                // Detected Signals Bento Grid
                Text('SIGNALS DETECTED', style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _SignalBentoTile(label: 'COLOR', value: r?.signals.colorDescription ?? '-', icon: Icons.palette_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _SignalBentoTile(label: 'TEXTURE', value: r?.signals.textureObservation ?? '-', icon: Icons.grain_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _SignalBentoTile(label: 'MOISTURE', value: r?.signals.moistureLevel ?? '-', icon: Icons.water_drop_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _SignalBentoTile(label: 'ORGANIC', value: r?.signals.organicMatterHint ?? '-', icon: Icons.eco_outlined)),
                  ],
                ),
                const SizedBox(height: 48),

                // Prescription Section
                Text('PRESCRIPTION', style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: MridaColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: MridaColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ACTION PLAN', style: theme.textTheme.labelLarge),
                          VoiceButton(
                            text: r?.prescriptionText ?? 'No prescription available.',
                            languageCode: r?.languageCode ?? 'en',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        r?.prescriptionText ?? 'Apply Nitrogen (46-0-0) at 120kg/ha. Soil showing significant nitrogen deficiency but stable pH levels.',
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: ElevatedButton(
          onPressed: r == null 
            ? null 
            : () async {
                try {
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saving analysis...'), duration: Duration(seconds: 1)),
                  );
                  
                  await ref.read(firestoreServiceProvider).saveScanResult(r);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analysis saved successfully!')),
                    );
                    context.go('/home');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
          child: const Text('SAVE TO FIELD'),
        ),
      ),
    );
  }

  double _mapNPKToValue(String level) {
    switch (level.toUpperCase()) {
      case 'HIGH':
        return 0.9;
      case 'MEDIUM':
      case 'MED':
        return 0.6;
      case 'LOW':
        return 0.3;
      default:
        return 0.5;
    }
  }
}

class _NPKPerformanceCard extends StatelessWidget {
  const _NPKPerformanceCard({this.result, required this.mapFn});
  final ScanResult? result;
  final double Function(String) mapFn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _NPKRow(
            label: 'NITROGEN',
            value: mapFn(result?.npk.nitrogen ?? 'LOW'),
            status: result?.npk.nitrogen ?? 'LOW',
            color: MridaColors.gradeD,
          ),
          const SizedBox(height: 24),
          _NPKRow(
            label: 'PHOSPHORUS',
            value: mapFn(result?.npk.phosphorus ?? 'HIGH'),
            status: result?.npk.phosphorus ?? 'HIGH',
            color: MridaColors.gradeA,
          ),
          const SizedBox(height: 24),
          _NPKRow(
            label: 'POTASSIUM',
            value: mapFn(result?.npk.potassium ?? 'MEDIUM'),
            status: result?.npk.potassium ?? 'MEDIUM',
            color: MridaColors.confMedium,
          ),
        ],
      ),
    );
  }
}

class _NPKRow extends StatelessWidget {
  const _NPKRow({
    required this.label,
    required this.value,
    required this.color,
    required this.status,
  });
  final String label;
  final double value;
  final Color color;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
            Text(status.toUpperCase(), 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: color)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SignalBentoTile extends StatelessWidget {
  const _SignalBentoTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}
