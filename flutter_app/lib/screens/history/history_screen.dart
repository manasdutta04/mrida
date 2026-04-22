import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/scan_provider.dart';
import '../../providers/field_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_result.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fieldsAsync = ref.watch(fieldsStreamProvider);
    final scansAsync = ref.watch(scansStreamProvider);

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
          fieldsAsync.when(
            data: (fields) => scansAsync.when(
              data: (scans) {
                if (scans.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No scans found. Take your first scan to see history.')),
                  );
                }

                // Map field names for quick lookup
                final fieldNames = {for (var f in fields) f.fieldId: f.name};

                // Group scans by fieldId
                final groupedScans = <String, List<ScanResult>>{};
                for (var scan in scans) {
                  groupedScans.putIfAbsent(scan.fieldId, () => []).add(scan);
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final fieldId = groupedScans.keys.elementAt(index);
                      final fieldName = fieldNames[fieldId] ?? 'Unknown Field';
                      final scansInField = groupedScans[fieldId] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                            child: Text(
                              fieldName.toUpperCase(),
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                          ...scansInField.map((scan) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildActionRow(context, scan, theme),
                          )),
                        ],
                      );
                    },
                    childCount: groupedScans.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, __) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            ),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, __) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, ScanResult scan, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => context.push('/scan/result', extra: scan),
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
                    scan.grade.name.toUpperCase(),
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
                        'GRADE ${scan.grade.name.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(scan.scannedAt),
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
