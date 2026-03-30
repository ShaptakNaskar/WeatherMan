import 'package:flutter/material.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';

/// Wraps the existing CyberpunkTheme static class into the AppThemeData interface
class CyberpunkThemeData extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.cyberpunk;

  @override
  Color get accentColor => CyberpunkTheme.neonCyan;
  @override
  Color get accentColorSecondary => CyberpunkTheme.neonMagenta;
  @override
  Color get backgroundColor => CyberpunkTheme.bgDarkest;
  @override
  Color get cardColor => CyberpunkTheme.bgPanel;
  @override
  Color get cardBorderColor => CyberpunkTheme.glassBorder;
  @override
  Color get textPrimary => CyberpunkTheme.textPrimary;
  @override
  Color get textSecondary => CyberpunkTheme.textSecondary;
  @override
  Color get textTertiary => CyberpunkTheme.textTertiary;
  @override
  Color get dangerColor => CyberpunkTheme.neonRed;
  @override
  Color get warningColor => CyberpunkTheme.neonYellow;
  @override
  Color get successColor => CyberpunkTheme.neonGreen;
  @override
  Color get infoColor => CyberpunkTheme.neonBlue;

  @override
  double get cardBorderRadius => 4;
  @override
  double get cardBorderWidth => 1;
  @override
  double get cardBlurSigma => 2;
  @override
  Color get cardGlowColor => CyberpunkTheme.neonCyan.withValues(alpha: 0.2);

  @override
  String? get fontFamily => 'Roboto';
  @override
  bool get useMonospace => true;

  @override
  List<Shadow> get accentGlow => CyberpunkTheme.neonCyanGlow;
  @override
  List<Shadow> get subtleGlow => CyberpunkTheme.subtleCyanGlow;
  @override
  List<Shadow> get textShadows => const [];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) =>
      CyberpunkTheme.getWeatherGradient(weatherCode, isDay);

  @override
  ThemeData get themeData => CyberpunkTheme.darkTheme;
}
