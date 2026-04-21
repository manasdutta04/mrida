import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationDetails {
  final double latitude;
  final double longitude;
  final String state;
  final String district;

  LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.district,
  });

  @override
  String toString() => '$district, $state ($latitude, $longitude)';
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Gets the current position and reverse geocodes it to State & District.
  Future<LocationDetails?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    try {
      // Reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationDetails(
          latitude: position.latitude,
          longitude: position.longitude,
          // In India: administrativeArea is State, subAdministrativeArea is usually District
          state: place.administrativeArea ?? '',
          district: place.subAdministrativeArea ?? place.locality ?? '',
        );
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
    }

    // Return only coordinates if geocoding fails
    return LocationDetails(
      latitude: position.latitude,
      longitude: position.longitude,
      state: '',
      district: '',
    );
  }
}
