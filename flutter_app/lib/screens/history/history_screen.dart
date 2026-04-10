import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/grade_widget.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for grouping scans by field
    final historyData = {
      'North Plot': [
        _ScanHistoryItem(
          grade: 'B',
          crop: 'Wheat',
          season: 'Rabi',
          date: '24 Oct 2024',
        ),
        _ScanHistoryItem(
          grade: 'A',
          crop: 'Soybean',
          season: 'Kharif',
          date: '12 Sep 2024',
        ),
      ],
      'East Ridge': [
        _ScanHistoryItem(
          grade: 'C',
          crop: 'Mustard',
          season: 'Rabi',
          date: '05 Aug 2024',
        ),
      ],
    };

    if (historyData.isEmpty) {
      return Scaffold(
        backgroundColor: MridaColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 64,
                color: MridaColors.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No scans yet. Tap + to begin.',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  color: MridaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      itemCount: historyData.keys.length,
      itemBuilder: (context, index) {
          final fieldName = historyData.keys.elementAt(index);
          final scans = historyData[fieldName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  fieldName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: MridaColors.onSurfaceVariant,
                  ),
                ),
              ),
              ...scans.map((scan) => _buildScanRow(context, scan)),
              const SizedBox(height: 8),
              Divider(color: MridaColors.outlineVariant.withValues(alpha: 0.3)),
            ],
          );
        },
      );
    }

  Widget _buildScanRow(BuildContext context, _ScanHistoryItem scan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () => context.push('/scan/result'), // Navigates to result screen with demo data
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            GradeWidget(grade: scan.grade, size: 44),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.crop,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MridaColors.onSurface,
                    ),
                  ),
                  Text(
                    '${scan.season} Season',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: MridaColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  scan.date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: MridaColors.onSurfaceVariant,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: MridaColors.outlineVariant,
                ),
              ],
            ),
          ],
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
