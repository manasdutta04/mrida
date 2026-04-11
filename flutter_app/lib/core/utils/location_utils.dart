import 'package:geolocator/geolocator.dart';

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationException implements Exception {
  const LocationException({
    required this.type,
    required this.message,
  });

  final LocationErrorType type;
  final String message;

  @override
  String toString() => message;
}

class LocationUtils {
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        type: LocationErrorType.serviceDisabled,
        message: 'Location service is disabled. Please enable GPS.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        type: LocationErrorType.permissionDenied,
        message: 'Location permission denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        type: LocationErrorType.permissionDeniedForever,
        message: 'Location permission permanently denied. Open app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
