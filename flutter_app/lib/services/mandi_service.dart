import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mandi_price.dart';

class MandiService {
  final Dio _dio = Dio();
  final Box _cacheBox = Hive.box('mandi_cache');
  final String _apiKey = '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';
  final String _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';

  Future<List<MandiPrice>> fetchPrices({String? state, String? commodity}) async {
    final cacheKey = 'prices_${state ?? 'any'}_${commodity ?? 'any'}';
    final cachedData = _cacheBox.get(cacheKey);

    if (cachedData != null) {
      final lastFetched = DateTime.parse(cachedData['timestamp'] as String);
      if (DateTime.now().difference(lastFetched).inHours < 24) {
        final List<dynamic> list = jsonDecode(cachedData['data'] as String);
        return list.map((e) => MandiPrice.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    try {
      final queryParams = {
        'api-key': _apiKey,
        'format': 'json',
        'limit': 250,
      };

      if (state != null && state.isNotEmpty) {
        queryParams['filters[State]'] = state;
      }
      if (commodity != null && commodity.isNotEmpty) {
        queryParams['filters[Commodity]'] = commodity;
      }

      final response = await _dio.get(
        'https://api.data.gov.in/resource/$_resourceId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        List<dynamic> records = response.data['records'] ?? [];
        
        // Fallback: If state-specific query returns nothing, try fetching national latest
        if (records.isEmpty && (state != null || commodity != null)) {
          final fallbackParams = {
            'api-key': _apiKey,
            'format': 'json',
            'limit': 100,
          };
          if (commodity != null) fallbackParams['filters[Commodity]'] = commodity;
          
          final fallbackResponse = await _dio.get(
            'https://api.data.gov.in/resource/$_resourceId',
            queryParameters: fallbackParams,
          );
          if (fallbackResponse.statusCode == 200) {
            records = fallbackResponse.data['records'] ?? [];
          }
        }

        final prices = records.map((e) => MandiPrice.fromJson(e as Map<String, dynamic>)).toList();
        
        // Filter out very old records (older than 30 days) to keep it "Real"
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final recentPrices = prices.where((p) => p.reportedDate.isAfter(thirtyDaysAgo)).toList();

        // Sort by modal price descending
        recentPrices.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));

        // Cache response
        await _cacheBox.put(cacheKey, {
          'timestamp': DateTime.now().toIso8601String(),
          'data': jsonEncode(records),
        });

        return recentPrices;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load prices',
        );
      }
    } catch (e) {
      // If network fails, try to return expired cache if available
      if (cachedData != null) {
        final List<dynamic> list = jsonDecode(cachedData['data'] as String);
        return list.map((e) => MandiPrice.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }
}
