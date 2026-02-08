import 'package:flutter/material.dart';
import 'package:weatherman/utils/unit_converter.dart';
import 'package:weatherman/services/storage_service.dart';

/// Settings provider for user preferences
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  bool _advancedViewEnabled = false;
  bool _isLoading = true;

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  TemperatureUnit get temperatureUnit => _temperatureUnit;
  bool get advancedViewEnabled => _advancedViewEnabled;
  bool get isLoading => _isLoading;
  bool get useCelsius => _temperatureUnit == TemperatureUnit.celsius;

  /// Initialize settings from storage
  Future<void> init() async {
    _temperatureUnit = await _storageService.getTemperatureUnit();
    _advancedViewEnabled = await _storageService.getAdvancedViewEnabled();
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

  /// Format temperature using current unit
  String formatTemp(double celsius, {bool showUnit = true}) {
    return UnitConverter.formatTemperature(celsius, _temperatureUnit, showUnit: showUnit);
  }

  /// Format temperature short (just number and degree)
  String formatTempShort(double celsius) {
    return UnitConverter.formatTemperatureShort(celsius, _temperatureUnit);
  }
}
