import 'package:flutter/material.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/config/clean_theme_data.dart';
import 'package:weatherman/config/cyberpunk_theme_data.dart';
import 'package:weatherman/config/ocean_theme.dart';
import 'package:weatherman/config/pastel_theme.dart';
import 'package:weatherman/config/sunset_theme.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:weatherman/utils/trend_analyzer.dart';

/// Provides the current app theme and allows switching between themes at runtime.
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;

  AppThemeType _currentType = AppThemeType.cyberpunk;
  late AppThemeData _currentTheme;

  static final Map<AppThemeType, AppThemeData> _themes = {
    AppThemeType.clean: CleanThemeData(),
    AppThemeType.cyberpunk: CyberpunkThemeData(),
    AppThemeType.pastel: PastelTheme(),
    AppThemeType.pastelDark: PastelDarkTheme(),
    AppThemeType.sunset: SunsetTheme(),
    AppThemeType.ocean: OceanTheme(),
  };

  ThemeProvider({required StorageService storageService})
      : _storageService = storageService {
    _currentTheme = _themes[_currentType]!;
  }

  AppThemeType get currentType => _currentType;
  AppThemeData get current => _currentTheme;
  ThemeData get themeData => _currentTheme.themeData;

  bool get isCyberpunk => _currentType == AppThemeType.cyberpunk;
  bool get isPastel => _currentType == AppThemeType.pastel || _currentType == AppThemeType.pastelDark;
  bool get isClean => _currentType == AppThemeType.clean;
  bool get isDark => _currentTheme.themeData.brightness == Brightness.dark;

  /// Text style for themed insight/advice messages
  InsightTextStyle get textStyle => switch (_currentType) {
        AppThemeType.cyberpunk => InsightTextStyle.cyber,
        AppThemeType.pastel || AppThemeType.pastelDark => InsightTextStyle.kawaii,
        _ => InsightTextStyle.neutral,
      };

  /// Initialize from persisted preference
  Future<void> init() async {
    final saved = await _storageService.getTheme();
    _currentType = saved;
    _currentTheme = _themes[_currentType]!;
    notifyListeners();
  }

  /// Switch to a different theme
  Future<void> setTheme(AppThemeType type) async {
    if (_currentType == type) return;
    _currentType = type;
    _currentTheme = _themes[type]!;
    notifyListeners();
    await _storageService.setTheme(type);
  }

  /// Cycle to next theme
  Future<void> cycleTheme() async {
    final types = AppThemeType.values;
    final nextIndex = (types.indexOf(_currentType) + 1) % types.length;
    await setTheme(types[nextIndex]);
  }
}
