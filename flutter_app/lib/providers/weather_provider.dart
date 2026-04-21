import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_provider.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

/// Provider for weather data based on current location
final weatherProvider = FutureProvider<WeatherModel?>((ref) async {
  final locationAsync = ref.watch(locationProvider);
  
  return locationAsync.when(
    data: (location) async {
      if (location == null) return null;
      final service = ref.watch(weatherServiceProvider);
      return await service.getWeather(location.latitude, location.longitude);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
