import 'package:flutter/material.dart';
import 'package:weatherman/config/constants.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/services/weather_service.dart';
import 'package:weatherman/services/storage_service.dart';

/// Weather data state
enum WeatherState { initial, loading, loaded, error }

/// Weather provider for fetching and caching weather data
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  final Map<String, WeatherData> _weatherCache = {};
  WeatherState _state = WeatherState.initial;
  String? _error;
  bool _isRefreshing = false;

  WeatherProvider({
    required WeatherService weatherService,
    required StorageService storageService,
  })  : _weatherService = weatherService,
        _storageService = storageService;

  WeatherState get state => _state;
  String? get error => _error;
  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _state == WeatherState.loading;

  /// Get weather for a location (from cache or fetch)
  WeatherData? getWeather(LocationModel location) {
    return _weatherCache[_getKey(location)];
  }

  /// Check if we have cached data for a location
  bool hasData(LocationModel location) {
    return _weatherCache.containsKey(_getKey(location));
  }

  /// Fetch weather for a location
  Future<void> fetchWeather(LocationModel location, {bool forceRefresh = false}) async {
    final key = _getKey(location);

    // Check memory cache first
    if (!forceRefresh && _weatherCache.containsKey(key)) {
      final cached = _weatherCache[key]!;
      final age = DateTime.now().difference(cached.fetchedAt);
      if (age < AppConstants.cacheDuration) {
        _state = WeatherState.loaded;
        notifyListeners();
        return;
      }
    }

    // Check disk cache
    if (!forceRefresh) {
      final diskCache = await _storageService.getCachedWeather(location);
      if (diskCache != null) {
        final age = DateTime.now().difference(diskCache.fetchedAt);
        if (age < AppConstants.cacheDuration) {
          _weatherCache[key] = diskCache;
          _state = WeatherState.loaded;
          notifyListeners();
          return;
        }
      }
    }

    // Fetch from API
    if (_state == WeatherState.loaded) {
      _isRefreshing = true;
    } else {
      _state = WeatherState.loading;
    }
    _error = null;
    notifyListeners();

    try {
      final weather = await _weatherService.fetchWeather(location);
      _weatherCache[key] = weather;
      await _storageService.cacheWeather(weather);
      _state = WeatherState.loaded;
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      // If we have cached data, use it even if stale
      if (_weatherCache.containsKey(key)) {
        _isRefreshing = false;
        notifyListeners();
        return;
      }

      // Try disk cache as fallback
      final diskCache = await _storageService.getCachedWeather(location);
      if (diskCache != null) {
        _weatherCache[key] = diskCache;
        _state = WeatherState.loaded;
        _isRefreshing = false;
        notifyListeners();
        return;
      }

      _error = e.toString();
      _state = WeatherState.error;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Refresh weather for a location
  Future<void> refreshWeather(LocationModel location) async {
    await fetchWeather(location, forceRefresh: true);
  }

  /// Search for locations
  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      return await _weatherService.searchLocations(query);
    } catch (e) {
      return [];
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    if (_state == WeatherState.error) {
      _state = WeatherState.initial;
    }
    notifyListeners();
  }

  String _getKey(LocationModel location) {
    return '${location.latitude}_${location.longitude}';
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }
}
