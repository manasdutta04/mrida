import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/grade_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Mock data for grouping scans by field
    final historyData = {
      'North Plot': [
        _ScanHistoryItem(grade: 'B', crop: 'Wheat', season: 'Rabi', date: '24 Oct 2024'),
        _ScanHistoryItem(grade: 'A', crop: 'Soybean', season: 'Kharif', date: '12 Sep 2024'),
      ],
      'East Ridge': [
        _ScanHistoryItem(grade: 'C', crop: 'Mustard', season: 'Rabi', date: '05 Aug 2024'),
      ],
    };

    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Text(
                'FIELD\nHISTORY',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 48, height: 0.9),
              ),
            ),
          ),

          // Sections
          for (var fieldName in historyData.keys) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Text(
                  fieldName.toUpperCase(),
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final scan = historyData[fieldName]![index];
                    return _buildActionRow(context, scan, theme);
                  },
                  childCount: historyData[fieldName]!.length,
                ),
              ),
            ),
          ],
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, _ScanHistoryItem scan, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => context.push('/scan/result'),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: MridaColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    scan.grade,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: MridaColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.crop.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                      ),
                      Text(
                        '${scan.season} • ${scan.date}',
                        style: TextStyle(color: MridaColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: MridaColors.outlineVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanHistoryItem {
  final String grade;
  final String crop;
  final String season;
  final String date;

  _ScanHistoryItem({
    required this.grade,
    required this.crop,
    required this.season,
    required this.date,
  });
}
