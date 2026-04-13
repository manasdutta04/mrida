import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    title: 'MAPS',
                    subtitle: 'View Fields',
                    icon: Icons.map_outlined,
                    color: Colors.white,
                    isDark: false,
                    onTap: () => context.go('/map'),
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
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildModernScanCard('North Plot', 'Oct 24', 'Grade A', MridaColors.gradeA),
                _buildModernScanCard('West Hill', 'Oct 21', 'Grade B', MridaColors.gradeB),
                _buildModernScanCard('South Rim', 'Oct 19', 'Grade A', MridaColors.gradeA),
              ],
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
                Row(
                  children: [
                    Expanded(child: _buildInsightTile('28°C', 'SUNNY', Icons.wb_sunny_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInsightTile('12%', 'MOISTURE', Icons.opacity_outlined)),
                  ],
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

  Widget _buildModernScanCard(String title, String date, String grade, Color color) {
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
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
