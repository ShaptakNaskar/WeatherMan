import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/models/location.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/unit_converter.dart';

/// Storage service for local persistence
class StorageService {
  static const String _savedLocationsKey = 'saved_locations';
  static const String _weatherCachePrefix = 'weather_cache_';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _lastLocationKey = 'last_location';
  static const String _advancedViewKey = 'advanced_view_enabled';
  static const String _lastMorningPushKey = 'last_morning_push';
  static const String _lastEveningPushKey = 'last_evening_push';
  static const String _lastTrendHashKey = 'last_trend_hash';
  static const String _persistentNotifKey = 'persistent_notification_enabled';
  static const String _morningBriefingKey = 'morning_briefing_enabled';
  static const String _eveningOutlookKey = 'evening_outlook_enabled';
  static const String _severeAlertsKey = 'severe_alerts_enabled';
  static const String _trendInsightsKey = 'trend_insights_enabled';
  static const String _notifPromptedKey = 'notif_prompted';
  static const String _batteryPromptedKey = 'battery_prompted';
  static const String _lastSevereHashKey = 'last_severe_hash';
  static const String _themeKey = 'app_theme';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- Saved Locations ---

  /// Get list of saved locations
  Future<List<LocationModel>> getSavedLocations() async {
    final p = await prefs;
    final json = p.getString(_savedLocationsKey);
    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save locations list
  Future<void> saveLocations(List<LocationModel> locations) async {
    final p = await prefs;
    final json = jsonEncode(locations.map((l) => l.toJson()).toList());
    await p.setString(_savedLocationsKey, json);
  }

  /// Add a location to saved list
  Future<void> addLocation(LocationModel location) async {
    final locations = await getSavedLocations();

    // Check if already exists
    if (locations.any((l) => l == location)) return;

    locations.add(location);
    await saveLocations(locations);
  }

  /// Remove a location from saved list
  Future<void> removeLocation(LocationModel location) async {
    final locations = await getSavedLocations();
    locations.removeWhere((l) => l == location);
    await saveLocations(locations);
  }

  /// Reorder locations
  Future<void> reorderLocations(int oldIndex, int newIndex) async {
    final locations = await getSavedLocations();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = locations.removeAt(oldIndex);
    locations.insert(newIndex, item);
    await saveLocations(locations);
  }

  // --- Weather Cache ---

  /// Get cached weather data for a location
  Future<WeatherData?> getCachedWeather(LocationModel location) async {
    final p = await prefs;
    final key = _getCacheKey(location);
    final json = p.getString(key);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return WeatherData.fromCache(data);
    } catch (_) {
      return null;
    }
  }

  /// Cache weather data
  Future<void> cacheWeather(WeatherData weather) async {
    final p = await prefs;
    final key = _getCacheKey(weather.location);
    final json = jsonEncode(weather.toJson());
    await p.setString(key, json);
  }

  /// Clear weather cache for a location
  Future<void> clearWeatherCache(LocationModel location) async {
    final p = await prefs;
    final key = _getCacheKey(location);
    await p.remove(key);
  }

  String _getCacheKey(LocationModel location) {
    return '$_weatherCachePrefix${location.latitude}_${location.longitude}';
  }

  // --- Settings ---

  /// Get temperature unit preference
  Future<TemperatureUnit> getTemperatureUnit() async {
    final p = await prefs;
    final value = p.getString(_temperatureUnitKey);
    if (value == 'fahrenheit') return TemperatureUnit.fahrenheit;
    return TemperatureUnit.celsius;
  }

  /// Save temperature unit preference
  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    final p = await prefs;
    await p.setString(
      _temperatureUnitKey,
      unit == TemperatureUnit.fahrenheit ? 'fahrenheit' : 'celsius',
    );
  }

  /// Get advanced view enabled setting
  Future<bool> getAdvancedViewEnabled() async {
    final p = await prefs;
    return p.getBool(_advancedViewKey) ?? false;
  }

  /// Save advanced view enabled setting
  Future<void> setAdvancedViewEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_advancedViewKey, enabled);
  }

  /// Get last viewed location
  Future<LocationModel?> getLastLocation() async {
    final p = await prefs;
    final json = p.getString(_lastLocationKey);
    if (json == null) return null;

    try {
      return LocationModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Save last viewed location
  Future<void> setLastLocation(LocationModel location) async {
    final p = await prefs;
    await p.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  // --- Persistent notification toggle ---
  Future<bool> getPersistentNotificationEnabled() async {
    final p = await prefs;
    return p.getBool(_persistentNotifKey) ?? false;
  }

  Future<void> setPersistentNotificationEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_persistentNotifKey, enabled);
  }

  // --- Notification toggles ---
  Future<bool> getMorningBriefingEnabled() async {
    final p = await prefs;
    return p.getBool(_morningBriefingKey) ?? true;
  }

  Future<void> setMorningBriefingEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_morningBriefingKey, enabled);
  }

  Future<bool> getEveningOutlookEnabled() async {
    final p = await prefs;
    return p.getBool(_eveningOutlookKey) ?? true;
  }

  Future<void> setEveningOutlookEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_eveningOutlookKey, enabled);
  }

  Future<bool> getSevereAlertsEnabled() async {
    final p = await prefs;
    return p.getBool(_severeAlertsKey) ?? true;
  }

  Future<void> setSevereAlertsEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_severeAlertsKey, enabled);
  }

  Future<bool> getTrendInsightsEnabled() async {
    final p = await prefs;
    return p.getBool(_trendInsightsKey) ?? true;
  }

  Future<void> setTrendInsightsEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_trendInsightsKey, enabled);
  }

  Future<String?> getLastSevereHash() async {
    final p = await prefs;
    return p.getString(_lastSevereHashKey);
  }

  Future<void> setLastSevereHash(String hash) async {
    final p = await prefs;
    await p.setString(_lastSevereHashKey, hash);
  }

  // --- First-run prompts ---
  Future<bool> getNotificationPrompted() async {
    final p = await prefs;
    return p.getBool(_notifPromptedKey) ?? false;
  }

  Future<void> setNotificationPrompted() async {
    final p = await prefs;
    await p.setBool(_notifPromptedKey, true);
  }

  Future<bool> getBatteryPrompted() async {
    final p = await prefs;
    return p.getBool(_batteryPromptedKey) ?? false;
  }

  Future<void> setBatteryPrompted() async {
    final p = await prefs;
    await p.setBool(_batteryPromptedKey, true);
  }

  // --- Notification bookkeeping ---

  Future<DateTime?> getLastMorningPush() async {
    return _getDate(_lastMorningPushKey);
  }

  Future<void> setLastMorningPush(DateTime time) async {
    await _setDate(_lastMorningPushKey, time);
  }

  Future<DateTime?> getLastEveningPush() async {
    return _getDate(_lastEveningPushKey);
  }

  Future<void> setLastEveningPush(DateTime time) async {
    await _setDate(_lastEveningPushKey, time);
  }

  Future<String?> getLastTrendHash() async {
    final p = await prefs;
    return p.getString(_lastTrendHashKey);
  }

  Future<void> setLastTrendHash(String hash) async {
    final p = await prefs;
    await p.setString(_lastTrendHashKey, hash);
  }

  Future<DateTime?> _getDate(String key) async {
    final p = await prefs;
    final value = p.getString(key);
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _setDate(String key, DateTime value) async {
    final p = await prefs;
    await p.setString(key, value.toIso8601String());
  }

  // --- Theme ---
  Future<AppThemeType> getTheme() async {
    final p = await prefs;
    final value = p.getString(_themeKey);
    if (value == 'pastelDark') {
      return AppThemeType.pastel;
    }
    for (final t in AppThemeType.values) {
      if (t.name == value) return t;
    }
    return AppThemeType.clean;
  }

  Future<void> setTheme(AppThemeType theme) async {
    final p = await prefs;
    await p.setString(_themeKey, theme.name);
  }

  // --- Onboarding ---
  Future<bool> getOnboardingComplete() async {
    final p = await prefs;
    return p.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final p = await prefs;
    await p.setBool(_onboardingCompleteKey, true);
  }
}
