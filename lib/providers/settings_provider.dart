import 'package:flutter/material.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/services/storage_service.dart';

/// Settings provider for user preferences
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  bool _advancedViewEnabled = false;
  bool _isLoading = true;
  bool _persistentNotificationEnabled = false;
  bool _morningBriefingEnabled = true;
  bool _eveningOutlookEnabled = true;
  bool _severeAlertsEnabled = true;
  bool _trendInsightsEnabled = true;

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  TemperatureUnit get temperatureUnit => _temperatureUnit;
  bool get advancedViewEnabled => _advancedViewEnabled;
  bool get isLoading => _isLoading;
  bool get useCelsius => _temperatureUnit == TemperatureUnit.celsius;
  bool get persistentNotificationEnabled => _persistentNotificationEnabled;
  bool get morningBriefingEnabled => _morningBriefingEnabled;
  bool get eveningOutlookEnabled => _eveningOutlookEnabled;
  bool get severeAlertsEnabled => _severeAlertsEnabled;
  bool get trendInsightsEnabled => _trendInsightsEnabled;

  /// Initialize settings from storage
  Future<void> init() async {
    _temperatureUnit = await _storageService.getTemperatureUnit();
    _advancedViewEnabled = await _storageService.getAdvancedViewEnabled();
    _persistentNotificationEnabled = await _storageService.getPersistentNotificationEnabled();
    _morningBriefingEnabled = await _storageService.getMorningBriefingEnabled();
    _eveningOutlookEnabled = await _storageService.getEveningOutlookEnabled();
    _severeAlertsEnabled = await _storageService.getSevereAlertsEnabled();
    _trendInsightsEnabled = await _storageService.getTrendInsightsEnabled();
    _isLoading = false;
    notifyListeners();
  }

  /// Set temperature unit
  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    if (_temperatureUnit == unit) return;
    _temperatureUnit = unit;
    notifyListeners();
    await _storageService.setTemperatureUnit(unit);
  }

  /// Toggle temperature unit
  Future<void> toggleTemperatureUnit() async {
    final newUnit = _temperatureUnit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    await setTemperatureUnit(newUnit);
  }

  /// Set advanced view enabled
  Future<void> setAdvancedViewEnabled(bool enabled) async {
    if (_advancedViewEnabled == enabled) return;
    _advancedViewEnabled = enabled;
    notifyListeners();
    await _storageService.setAdvancedViewEnabled(enabled);
  }

  /// Toggle advanced view
  Future<void> toggleAdvancedView() async {
    await setAdvancedViewEnabled(!_advancedViewEnabled);
  }

  Future<void> setPersistentNotificationEnabled(bool enabled) async {
    if (_persistentNotificationEnabled == enabled) return;
    _persistentNotificationEnabled = enabled;
    notifyListeners();
    await _storageService.setPersistentNotificationEnabled(enabled);
  }

  Future<void> setMorningBriefingEnabled(bool enabled) async {
    if (_morningBriefingEnabled == enabled) return;
    _morningBriefingEnabled = enabled;
    notifyListeners();
    await _storageService.setMorningBriefingEnabled(enabled);
  }

  Future<void> setEveningOutlookEnabled(bool enabled) async {
    if (_eveningOutlookEnabled == enabled) return;
    _eveningOutlookEnabled = enabled;
    notifyListeners();
    await _storageService.setEveningOutlookEnabled(enabled);
  }

  Future<void> setSevereAlertsEnabled(bool enabled) async {
    if (_severeAlertsEnabled == enabled) return;
    _severeAlertsEnabled = enabled;
    notifyListeners();
    await _storageService.setSevereAlertsEnabled(enabled);
  }

  Future<void> setTrendInsightsEnabled(bool enabled) async {
    if (_trendInsightsEnabled == enabled) return;
    _trendInsightsEnabled = enabled;
    notifyListeners();
    await _storageService.setTrendInsightsEnabled(enabled);
  }

  /// Format temperature using current unit
  String formatTemp(double celsius, {bool showUnit = true}) {
    return UnitConverter.formatTemperature(celsius, _temperatureUnit, showUnit: showUnit);
  }

  /// Format temperature short (just number and degree)
  String formatTempShort(double celsius) {
    return UnitConverter.formatTemperatureShort(celsius, _temperatureUnit);
  }
}
