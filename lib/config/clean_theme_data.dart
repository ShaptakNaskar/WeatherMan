import 'package:flutter/material.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/config/theme.dart';

/// Wraps the existing AppTheme (clean/glassmorphic) static class into AppThemeData interface
class CleanThemeData extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.clean;

  @override
  Color get accentColor => AppTheme.primaryBlue;
  @override
  Color get accentColorSecondary => AppTheme.accentBlue;
  @override
  Color get backgroundColor => const Color(0xFF1A2A3A);
  @override
  Color get cardColor => Colors.white.withValues(alpha: 0.12);
  @override
  Color get cardBorderColor => AppTheme.glassBorder;
  @override
  Color get textPrimary => AppTheme.textPrimary;
  @override
  Color get textSecondary => AppTheme.textSecondary;
  @override
  Color get textTertiary => AppTheme.textTertiary;
  @override
  Color get dangerColor => const Color(0xFFFF5252);
  @override
  Color get warningColor => const Color(0xFFFFB74D);
  @override
  Color get successColor => const Color(0xFF69F0AE);
  @override
  Color get infoColor => AppTheme.accentBlue;

  @override
  double get cardBorderRadius => 16;
  @override
  double get cardBorderWidth => 1;
  @override
  double get cardBlurSigma => 10;
  @override
  Color get cardGlowColor => Colors.transparent;

  @override
  String? get fontFamily => 'Roboto';
  @override
  bool get useMonospace => false;

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) =>
      AppTheme.getWeatherGradient(weatherCode, isDay);

  @override
  ThemeData get themeData => AppTheme.darkTheme;
}
