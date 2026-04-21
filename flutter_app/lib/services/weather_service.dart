import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';

class WeatherModel {
  final double temperature;
  final double humidity;
  final String condition;
  final IconData icon;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.icon,
  });

  factory WeatherModel.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'];
    final temp = (current['temperature_2m'] as num).toDouble();
    final hum = (current['relative_humidity_2m'] as num).toDouble();
    final code = current['weather_code'] as int;

    return WeatherModel(
      temperature: temp,
      humidity: hum,
      condition: _mapCodeToCondition(code),
      icon: _mapCodeToIcon(code),
    );
  }

  static String _mapCodeToCondition(int code) {
    if (code == 0) return 'Sunny';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  static IconData _mapCodeToIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.wb_cloudy_outlined;
    if (code <= 48) return Icons.cloud_outlined;
    if (code <= 67) return Icons.umbrella_outlined;
    if (code <= 99) return Icons.thunderstorm_outlined;
    return Icons.wb_sunny_outlined;
  }
}

class WeatherService {
  final Dio _dio = Dio();

  Future<WeatherModel?> getWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        ApiConstants.openMeteoEndpoint,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,weather_code',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromOpenMeteo(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
    return null;
  }
}
