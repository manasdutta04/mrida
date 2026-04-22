import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/scan_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/weather_provider.dart';
import '../../models/scan_result.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scansAsync = ref.watch(scansStreamProvider);
    final statsAsync = ref.watch(statsProvider);
    final weatherAsync = ref.watch(weatherProvider);
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium Hero Section
        SliverToBoxAdapter(
          child: Container(
            height: 440,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: const DecorationImage(
                image: AssetImage('assets/demo/hero_field.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: MridaColors.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'PRECISION MONITORING',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'BEYOND THE\nSURFACE',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.check, size: 14, color: MridaColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Soil Vitals: Optimal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dynamic Stats Row
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: statsAsync.when(
              data: (stats) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('SCANS', (stats['scans'] ?? 0).toString()),
                  _buildStatItem('FIELDS', (stats['fields'] ?? 0).toString()),
                  _buildStatItem('CROPS', (stats['crops'] ?? 0).toString()),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Quick Actions - "The Bento Row"
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildActionTile(
                    context,
                    title: 'SCAN NOW',
                    subtitle: 'AI Soil Analysis',
                    icon: Icons.camera_alt_outlined,
                    color: MridaColors.primary,
                    isDark: true,
                    onTap: () => context.go('/scan/camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildActionTile(
                    context,
                    title: 'MANDI',
                    subtitle: 'Crop Prices',
                    icon: Icons.store_outlined,
                    color: Colors.white,
                    isDark: false,
                    onTap: () => context.go('/mandi'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),

        // Recent Activity Header
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RECENT SCANS',
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  'SEE ALL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MridaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // horizontal scan list
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: scansAsync.when(
              data: (scans) {
                if (scans.isEmpty) {
                  return Center(
                    child: Text(
                      'No scans yet. Start by scanning your soil!',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                final recentScans = scans.take(5).toList();
                final fields = ref.watch(fieldsStreamProvider).value ?? [];
                final fieldMap = {for (var f in fields) f.fieldId: f.name};

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: recentScans.length,
                  itemBuilder: (context, index) {
                    final scan = recentScans[index];
                    final fieldName = fieldMap[scan.fieldId] ?? 
                                     (scan.fieldId.isNotEmpty ? scan.fieldId.toUpperCase() : 'UNKNOWN FIELD');
                    
                    return _buildModernScanCard(
                      context,
                      fieldName,
                      DateFormat('MMM dd').format(scan.scannedAt),
                      'Grade ${scan.grade.name.toUpperCase()}',
                      _getColorForGrade(scan.grade.name),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),

        // Insights Section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENVIRONMENTAL INSIGHTS',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 24),
                weatherAsync.when(
                  data: (weather) => Row(
                    children: [
                      Expanded(
                        child: _buildInsightTile(
                          weather != null ? '${weather.temperature.toStringAsFixed(1)}°C' : '--°C',
                          weather?.condition.toUpperCase() ?? 'WEATHER',
                          weather?.icon ?? Icons.wb_sunny_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInsightTile(
                          weather != null ? '${weather.humidity.toStringAsFixed(0)}%' : '--%',
                          'HUMIDITY',
                          Icons.opacity_outlined,
                        ),
                      ),
                    ],
                  ),
                  loading: () => Row(
                    children: [
                      Expanded(child: _buildInsightTile('...', 'FETCHING', Icons.refresh)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInsightTile('...', 'FETCHING', Icons.refresh)),
                    ],
                  ),
                  error: (e, __) => Row(
                    children: [
                      Expanded(child: _buildInsightTile('N/A', 'ERROR', Icons.error_outline)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInsightTile('N/A', 'ERROR', Icons.error_outline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? null : Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: isDark ? Colors.white : MridaColors.primary, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : MridaColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : MridaColors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernScanCard(BuildContext context, String title, String date, String grade, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$date • $grade',
                  style: TextStyle(color: MridaColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: MridaColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: MridaColors.primary,
          ),
        ),
      ],
    );
  }

  Color _getColorForGrade(String grade) {
    switch (grade.toUpperCase()) {
      case 'A': return MridaColors.gradeA;
      case 'B': return MridaColors.gradeB;
      case 'C': return MridaColors.gradeC;
      case 'D': return MridaColors.gradeD;
      default: return MridaColors.primary;
    }
  }

  Widget _buildInsightTile(String value, String label, IconData icon) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: MridaColors.primary.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: MridaColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
