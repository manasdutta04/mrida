import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

/// Provider for current location details (coordinates, state, district)
final locationProvider = FutureProvider<LocationDetails?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.getCurrentLocation();
});
