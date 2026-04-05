import 'package:flutter/material.dart';
import 'package:weatherman/utils/trend_analyzer.dart';

/// Enum for available app themes
enum AppThemeType { clean, cyberpunk, pastel, sunset, ocean }

/// Abstract interface that all app themes implement.
/// Provides colors, gradients, card builders, and text styles
/// so widgets can be theme-agnostic.
abstract class AppThemeData {
  AppThemeType get type;

  // ── Core colors ──
  Color get accentColor;
  Color get accentColorSecondary;
  Color get backgroundColor;
  Color get cardColor;
  Color get cardBorderColor;
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get dangerColor;
  Color get warningColor;
  Color get successColor;
  Color get infoColor;

  // ── Glass/Panel ──
  double get cardBorderRadius;
  double get cardBorderWidth;
  double get cardBlurSigma;
  Color get cardGlowColor;

  // ── Typography ──
  String? get fontFamily;
  bool get useMonospace; // for HUD-style text

  // ── Gradients ──
  LinearGradient getWeatherGradient(int weatherCode, bool isDay);

  // ── ThemeData for MaterialApp ──
  ThemeData get themeData;

  // ── Severity colors ──
  Color severityColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.severe:
        return dangerColor;
      case InsightSeverity.warning:
        return warningColor;
      case InsightSeverity.info:
        return accentColor;
    }
  }

  // ── Contrast helpers ──
  bool get prefersWarmAccentsOnDark {
    if (themeData.brightness != Brightness.dark) return false;
    return accentColor.computeLuminance() > 0.55;
  }

  Color get primaryUiAccent {
    if (!prefersWarmAccentsOnDark) return accentColor;
    return warningColor;
  }

  Color get secondaryUiAccent {
    if (!prefersWarmAccentsOnDark) return accentColorSecondary;
    return accentColorSecondary.withValues(alpha: 0.9);
  }

  // ── Helpers ──
  List<Shadow> get accentGlow => [
    Shadow(
      color: accentColor.withValues(alpha: 0.4),
      blurRadius: 6,
      offset: Offset.zero,
    ),
  ];

  List<Shadow> get subtleGlow => [
    Shadow(
      color: accentColor.withValues(alpha: 0.2),
      blurRadius: 4,
      offset: Offset.zero,
    ),
  ];

  // ── Text shadows for readability on variable backgrounds ──
  List<Shadow> get textShadows => const [
    Shadow(color: Color(0x80000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
}
