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
      slivers: [
        // Consistently spaced top padding
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        
        // Main Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Greeting with Profile Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaste, Rajan',
                        style: theme.textTheme.headlineLarge,
                      ),
                      Text(
                        'Thursday, 24 October',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: MridaColors.primary,
                    child: const Text('RK', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
                  
                  // Hero Card (Bento)
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D7A5F),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D7A5F).withValues(alpha: 0.15),
                          offset: const Offset(0, 20),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'B',
                              style: GoogleFonts.sora(
                                fontSize: 64, // Reduced slightly to avoid cramped feel
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'North Plot',
                                    style: GoogleFonts.sora(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '3 days ago',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.72,
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    child: Text(
                                      '72% CONFIDENCE',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/scan/camera'),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('SCAN SOIL'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/map'),
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('MY FIELDS'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: MridaColors.primary.withOpacity(0.1), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Recent Scans Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECENT SCANS',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        'SEE ALL',
                        style: theme.textTheme.labelMedium?.copyWith(color: MridaColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildScanCard('West Orchard', 'Wheat', 'Oct 21', 'A', const Color(0xFF1D7A5F)),
                        const SizedBox(width: 16),
                        _buildScanCard('South Plateau', 'Cotton', 'Oct 19', 'B', const Color(0xFF8A8A42)),
                        const SizedBox(width: 16),
                        _buildScanCard('East Valley', 'Corn', 'Oct 15', 'C', const Color(0xFFD97706)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Secondary Insights
                  Row(
                    children: [
                      Expanded(child: _buildInsightCard(Icons.wb_sunny_outlined, '28°C', 'IDEAL SOWING')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInsightCard(Icons.opacity_outlined, '12%', 'SOIL MOISTURE')),
                    ],
                  ),
                  const SizedBox(height: 120), // Padding for nav
                ]),
              ),
            ),
          ],
        );
      }

  Widget _buildScanCard(String title, String crop, String date, String grade, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              grade,
              style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('$crop • $date', style: GoogleFonts.inter(fontSize: 12, color: MridaColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MridaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MridaColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: MridaColors.primary)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: MridaColors.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
