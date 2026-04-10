import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: MridaColors.primary),
            onPressed: () {},
          ),
          title: Text(
            'MRIDA',
            style: GoogleFonts.sora(
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              fontSize: 24,
              color: MridaColors.primary,
            ),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: MridaColors.surfaceContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Text(
                    'ALL FIELDS',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: MridaColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.filter_list, size: 16, color: MridaColors.primary),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
          const SizedBox(height: 16),
          Text(
            'Scan History',
            style: GoogleFonts.sora(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -2.0,
              color: MridaColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Archival records of soil health and crop scans.',
            style: theme.textTheme.bodyMedium?.copyWith(color: MridaColors.onSurfaceVariant.withOpacity(0.7)),
          ),
          const SizedBox(height: 48),
          
          _buildGroupSection('NORTH PLOT', [
            _buildScanRow(context, 'A', 'Surface Nutrient Density', 'Wheat • Winter Season', 'Oct 24', const Color(0xFF3C6658)),
            _buildScanRow(context, 'B', 'Microbial Activity Index', 'Soybean • Monsoon', 'Sep 12', const Color(0xFF79A694)),
          ]),
          
          const SizedBox(height: 48),
          
          _buildGroupSection('EASTERN RIDGE', [
            _buildScanRow(context, 'A', 'Topsoil pH Balance', 'Corn • Summer Crop', 'Aug 29', const Color(0xFF3C6658)),
            _buildScanRow(context, 'C', 'Moisture Retainment Level', 'Fallow • Preparation', 'Aug 05', const Color(0xFFA3D0BE)),
          ]),
          
          const SizedBox(height: 48),
          
          // Seasonal Benchmark Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: MridaColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Opacity(
                    opacity: 0.1,
                    child: const Icon(Icons.grass, size: 160, color: MridaColors.primary),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEASONAL BENCHMARK',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: MridaColors.primary.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Overall Farm Health is up 12.4%',
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: MridaColors.primary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('VIEW REPORT', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSection(String title, List<Widget> children) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: MridaColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: MridaColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Divider(color: MridaColors.outlineVariant.withOpacity(0.15))),
          ],
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _buildScanRow(BuildContext context, String grade, String title, String subtitle, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: InkWell(
        onTap: () => context.go('/field/1'), // Mocked ID
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                grade,
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MridaColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      letterSpacing: 1.0,
                      color: MridaColors.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MridaColors.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.chevron_right, size: 20, color: MridaColors.outlineVariant.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
