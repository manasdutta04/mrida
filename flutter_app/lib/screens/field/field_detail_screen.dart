import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/field_provider.dart';
import '../../providers/scan_provider.dart';
import '../../models/field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/scan_result.dart';

class FieldDetailScreen extends ConsumerWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fieldsAsync = ref.watch(fieldsStreamProvider);
    final latestScanAsync = ref.watch(latestScanForFieldProvider(fieldId));

    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: CustomScrollView(
        slivers: [
          fieldsAsync.when(
            data: (fields) {
              final field = fields.firstWhere(
                (f) => f.fieldId == fieldId, 
                orElse: () => Field(fieldId: '', userId: '', name: 'NOT FOUND', location: const GeoPoint(0, 0), areaAcres: 0, crops: [])
              );
              return latestScanAsync.when(
                data: (scan) => SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Cinematic Header Info
                      _buildFieldHero(context, theme, field, scan),
                      const SizedBox(height: 16),
                      
                      if (scan == null) ...[
                        const SizedBox(height: 48),
                        Center(child: Text('NO SCANS RECORDED YET', style: theme.textTheme.labelLarge)),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => context.go('/scan/camera?fieldId=$fieldId'),
                            child: const Text('START FIRST SCAN'),
                          ),
                        ),
                      ] else ...[
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
                                  Text('ACCURACY', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white60)),
                                  const SizedBox(height: 8),
                                  Text('${(scan.confidenceScore * 100).toInt()}%', style: theme.textTheme.displayMedium?.copyWith(color: Colors.white)),
                                ],
                              ),
                              const Icon(Icons.verified, color: Colors.white, size: 40),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bento Grid: Detected Signals
                        Text('SIGNALS DETECTED', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _BentoInfoTile(label: 'COLOR', value: scan.signals.colorDescription, icon: Icons.palette_outlined)),
                            const SizedBox(width: 12),
                            Expanded(child: _BentoInfoTile(label: 'TEXTURE', value: scan.signals.textureObservation, icon: Icons.grain)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _BentoInfoTile(label: 'MOISTURE', value: scan.signals.moistureLevel, icon: Icons.water_drop_outlined)),
                            const SizedBox(width: 12),
                            Expanded(child: _BentoInfoTile(label: 'ORGANIC', value: scan.signals.organicMatterHint, icon: Icons.eco_outlined)),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // NPK Status
                        Text('NUTRIENT LEVELS', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 16),
                        _NPKStatusRow(
                          label: 'NITROGEN', 
                          value: _getNPKValue(scan.npk.nitrogen), 
                          status: scan.npk.nitrogen, 
                          color: _getNPKColor(scan.npk.nitrogen)
                        ),
                        _NPKStatusRow(
                          label: 'PHOSPHORUS', 
                          value: _getNPKValue(scan.npk.phosphorus), 
                          status: scan.npk.phosphorus, 
                          color: _getNPKColor(scan.npk.phosphorus)
                        ),
                        _NPKStatusRow(
                          label: 'POTASSIUM', 
                          value: _getNPKValue(scan.npk.potassium), 
                          status: scan.npk.potassium, 
                          color: _getNPKColor(scan.npk.potassium)
                        ),
                        
                        const SizedBox(height: 48),

                        // pH Layout
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: [
                              Text('PH BALANCE', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 16),
                              Text('${scan.ph.min} – ${scan.ph.max}', style: theme.textTheme.displayLarge?.copyWith(color: MridaColors.primary)),
                              Text(scan.ph.interpretation.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: MridaColors.onSurfaceVariant, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (e, __) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, __) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHero(BuildContext context, ThemeData theme, Field field, ScanResult? latestScan) {
    return Container(
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
              Colors.black.withValues(alpha: 0.9),
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CORE REPORT',
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 40, color: Colors.white),
                    ),
                  ],
                ),
                if (latestScan != null)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      latestScan.grade.name.toUpperCase(),
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 48, color: MridaColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  double _getNPKValue(String status) {
    switch (status.toUpperCase()) {
      case 'LOW': return 0.25;
      case 'MEDIUM': return 0.55;
      case 'HIGH': return 0.85;
      default: return 0.5;
    }
  }

  Color _getNPKColor(String status) {
    switch (status.toUpperCase()) {
      case 'LOW': return MridaColors.gradeD;
      case 'MEDIUM': return MridaColors.confMedium;
      case 'HIGH': return MridaColors.gradeA;
      default: return MridaColors.primary;
    }
  }
}

class _BentoInfoTile extends StatelessWidget {
  const _BentoInfoTile({required this.label, required this.value, required this.icon});
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

class _NPKStatusRow extends StatelessWidget {
  const _NPKStatusRow({required this.label, required this.value, required this.status, required this.color});
  final String label;
  final double value;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
              Text(status, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
