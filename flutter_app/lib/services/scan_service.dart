import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants/api_constants.dart';
import '../models/scan_result.dart';

class ScanService {
  ScanService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  Future<ScanResult> analyzeSoil({
    required File imageFile,
    required String fieldId,
    required String state,
    required String district,
    required String season,
    required String crop,
    required String language,
    required Position location,
  }) async {
    final b64 = base64Encode(await imageFile.readAsBytes());
    try {
      final response = await _dio.post(
        ApiConstants.scanEndpoint,
        data: {
          'image_base64': b64,
          'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'demo-user',
          'field_id': fieldId,
          'state': state,
          'district': district,
          'season': season,
          'crop': crop,
          'language': language,
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return ScanResult.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Low confidence. Retake in better lighting.');
      }
      rethrow;
    }
  }
}
