import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherman/config/constants.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/models/weather.dart';

/// Air Quality API service using Open-Meteo
class AirQualityService {
  final http.Client _client;

  AirQualityService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch air quality data for a location
  Future<AirQuality> fetchAirQuality(LocationModel location) async {
    final url = Uri.parse(AppConstants.airQualityBaseUrl).replace(
      queryParameters: {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current': AppConstants.airQualityParams,
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw AirQualityServiceException('Request timed out'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (json.containsKey('error')) {
          throw AirQualityServiceException(json['reason'] as String? ?? 'Unknown error');
        }
        
        return AirQuality.fromJson(json);
      } else {
        throw AirQualityServiceException('Failed to fetch air quality: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AirQualityServiceException) rethrow;
      throw AirQualityServiceException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for air quality service errors
class AirQualityServiceException implements Exception {
  final String message;
  
  AirQualityServiceException(this.message);
  
  @override
  String toString() => message;
}
