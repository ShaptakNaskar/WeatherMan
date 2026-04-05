import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Wraps the existing AppTheme (clean/glassmorphic) static class into AppThemeData interface
class CleanThemeData extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.clean;

  @override
  Color get accentColor => const Color(0xFFFFC97A);
  @override
  Color get accentColorSecondary => const Color(0xFF98DEFF);
  @override
  Color get backgroundColor => const Color(0xFF0B1323);
  @override
  Color get cardColor => const Color(0x3DE6F1FF);
  @override
  Color get cardBorderColor => const Color(0x7AE7CE9A);
  @override
  Color get textPrimary => const Color(0xFFF3F9FF);
  @override
  Color get textSecondary => const Color(0xCCE6EEF7);
  @override
  Color get textTertiary => const Color(0x99C6D4E6);
  @override
  Color get dangerColor => const Color(0xFFFF5252);
  @override
  Color get warningColor => const Color(0xFFFFC97A);
  @override
  Color get successColor => const Color(0xFF69F0AE);
  @override
  Color get infoColor => const Color(0xFF8FD6FF);

  @override
  double get cardBorderRadius => 22;
  @override
  double get cardBorderWidth => 1.2;
  @override
  double get cardBlurSigma => 22;
  @override
  Color get cardGlowColor => const Color(0x1A9AD8FF);

  @override
  String? get fontFamily => 'Urbanist';
  @override
  bool get useMonospace => false;

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF172C49),
                Color(0xFF21466A),
                Color(0xFF2B5F88),
                Color(0xFF234A6E),
              ],
              stops: [0.0, 0.32, 0.7, 1.0],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF091121),
                Color(0xFF132447),
                Color(0xFF203966),
                Color(0xFF12243E),
              ],
              stops: [0.0, 0.4, 0.78, 1.0],
            );
    }

    if (weatherCode == 2 || weatherCode == 3) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF263B57),
                Color(0xFF2C4A69),
                Color(0xFF385C7D),
                Color(0xFF2D4B68),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1222),
                Color(0xFF182942),
                Color(0xFF2A3A56),
                Color(0xFF1A263B),
              ],
            );
    }

    if (weatherCode == 45 || weatherCode == 48) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF334150),
                Color(0xFF3A4D5F),
                Color(0xFF495D6F),
                Color(0xFF3E5162),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF11182A),
                Color(0xFF25334A),
                Color(0xFF344357),
                Color(0xFF1F2A3B),
              ],
            );
    }

    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A314C),
                Color(0xFF21405F),
                Color(0xFF285176),
                Color(0xFF204262),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF060D19),
                Color(0xFF132338),
                Color(0xFF223853),
                Color(0xFF142538),
              ],
            );
    }

    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3B4C60),
                Color(0xFF495B72),
                Color(0xFF5D7188),
                Color(0xFF49607A),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D172A),
                Color(0xFF1A2B46),
                Color(0xFF2B3E5A),
                Color(0xFF1B2A3E),
              ],
            );
    }

    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF070A16),
          Color(0xFF14223A),
          Color(0xFF243B63),
          Color(0xFF111C30),
        ],
      );
    }

    return isDay
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF172C49),
              Color(0xFF21466A),
              Color(0xFF2B5F88),
              Color(0xFF234A6E),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF091121),
              Color(0xFF132447),
              Color(0xFF203966),
              Color(0xFF12243E),
            ],
          );
  }

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.urbanistTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w200),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ).apply(bodyColor: textPrimary, displayColor: textPrimary),
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
      primary: accentColor,
      secondary: accentColorSecondary,
      surface: const Color(0xFF0E1A2D),
      onSurface: textPrimary,
      error: dangerColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.urbanist(
        color: textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );
}
