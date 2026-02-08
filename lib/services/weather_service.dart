import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherman/config/constants.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/models/weather.dart';

/// Weather API service using Open-Meteo
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch weather data for a location
  Future<WeatherData> fetchWeather(LocationModel location) async {
    final url = Uri.parse(AppConstants.weatherBaseUrl).replace(
      queryParameters: {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current': AppConstants.currentParams,
        'hourly': AppConstants.hourlyParams,
        'daily': AppConstants.dailyParams,
        'timezone': 'auto',
        'forecast_days': '10',
      },
    );

    try {
      final response = await _client.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw WeatherServiceException('Request timed out'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (json.containsKey('error')) {
          throw WeatherServiceException(json['reason'] as String? ?? 'Unknown error');
        }
        
        return WeatherData.fromJson(json, location);
      } else {
        throw WeatherServiceException('Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      if (e is WeatherServiceException) rethrow;
      throw WeatherServiceException('Network error: $e');
    }
  }

  /// Search for cities by name
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(AppConstants.geocodingBaseUrl).replace(
      queryParameters: {
        'name': query,
        'count': '10',
        'language': 'en',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw WeatherServiceException('Search timed out'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (json.containsKey('error')) {
          throw WeatherServiceException(json['reason'] as String? ?? 'Unknown error');
        }

        final results = json['results'] as List<dynamic>?;
        if (results == null) return [];

        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw WeatherServiceException('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is WeatherServiceException) rethrow;
      throw WeatherServiceException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for weather service errors
class WeatherServiceException implements Exception {
  final String message;
  
  WeatherServiceException(this.message);
  
  @override
  String toString() => message;
}
