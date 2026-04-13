import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class FieldDetailScreen extends StatelessWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: CustomScrollView(
        slivers: [
          // Cinematic Detail Header
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
                              fieldId.toUpperCase(),
                              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'CORE REPORT',
                              style: theme.textTheme.displayLarge?.copyWith(fontSize: 40, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'A',
                            style: theme.textTheme.displayLarge?.copyWith(fontSize: 48, color: MridaColors.primary),
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
                          Text('92%', style: theme.textTheme.displayMedium?.copyWith(color: Colors.white)),
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
                    Expanded(child: _BentoInfoTile(label: 'COLOR', value: 'Dark Brown', icon: Icons.palette_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _BentoInfoTile(label: 'TEXTURE', value: 'Loamy', icon: Icons.grain)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _BentoInfoTile(label: 'MOISTURE', value: '12%', icon: Icons.water_drop_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _BentoInfoTile(label: 'ORGANIC', value: 'High', icon: Icons.eco_outlined)),
                  ],
                ),
                const SizedBox(height: 48),

                // NPK Status
                Text('NUTRIENT LEVELS', style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                _NPKStatusRow(label: 'NITROGEN', value: 0.25, status: 'LOW', color: MridaColors.gradeD),
                _NPKStatusRow(label: 'PHOSPHORUS', value: 0.85, status: 'HIGH', color: MridaColors.gradeA),
                _NPKStatusRow(label: 'POTASSIUM', value: 0.55, status: 'MEDIUM', color: MridaColors.confMedium),
                
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
                      Text('6.2 – 7.0', style: theme.textTheme.displayLarge?.copyWith(color: MridaColors.primary)),
                      Text('SLIGHTLY ACIDIC', style: const TextStyle(fontWeight: FontWeight.w900, color: MridaColors.onSurfaceVariant, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
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
