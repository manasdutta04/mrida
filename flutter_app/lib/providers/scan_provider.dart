import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import 'field_provider.dart';
import 'user_provider.dart';

final scansStreamProvider = StreamProvider<List<ScanResult>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).watchScans(userId);
});

final latestScanForFieldProvider = StreamProvider.family<ScanResult?, String>((ref, fieldId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).watchLatestScanForField(userId, fieldId);
});

final statsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final fieldsAsync = ref.watch(fieldsStreamProvider);
  final scansAsync = ref.watch(scansStreamProvider);

  return fieldsAsync.when(
    data: (fields) => scansAsync.when(
      data: (scans) {
        final crops = fields.map((f) => f.crops).expand((e) => e).toSet();
        return AsyncValue.data({
          'scans': scans.length,
          'fields': fields.length,
          'crops': crops.length,
        });
      },
      loading: () => const AsyncValue.data({'scans': 0, 'fields': 0, 'crops': 0}),
      error: (e, st) => const AsyncValue.data({'scans': 0, 'fields': 0, 'crops': 0}),
    ),
    loading: () => const AsyncValue.data({'scans': 0, 'fields': 0, 'crops': 0}),
    error: (e, st) => const AsyncValue.data({'scans': 0, 'fields': 0, 'crops': 0}),
  );
});
