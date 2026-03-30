import 'package:flutter/material.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Sunset theme — warm amber/coral tones on a dark background
class SunsetTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.sunset;

  @override
  Color get accentColor => const Color(0xFFFF8A50); // warm orange
  @override
  Color get accentColorSecondary => const Color(0xFFFF6B8A); // coral
  @override
  Color get backgroundColor => const Color(0xFF1A1018);
  @override
  Color get cardColor => const Color(0xFF2A1C25);
  @override
  Color get cardBorderColor => const Color(0x40FF8A50);
  @override
  Color get textPrimary => const Color(0xFFF5EDE8);
  @override
  Color get textSecondary => const Color(0xFFCCB8AA);
  @override
  Color get textTertiary => const Color(0xFF998880);
  @override
  Color get dangerColor => const Color(0xFFFF5252);
  @override
  Color get warningColor => const Color(0xFFFFCA28);
  @override
  Color get successColor => const Color(0xFF66BB6A);
  @override
  Color get infoColor => const Color(0xFF42A5F5);

  @override
  double get cardBorderRadius => 14;
  @override
  double get cardBorderWidth => 1;
  @override
  double get cardBlurSigma => 6;
  @override
  Color get cardGlowColor => const Color(0x18FF8A50);

  @override
  String? get fontFamily => null;
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get subtleGlow => [
        const Shadow(color: Color(0x30FF8A50), blurRadius: 6, offset: Offset.zero),
      ];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5A3040), Color(0xFF3A2030), Color(0xFF1A1018)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A1820), Color(0xFF1E1018), Color(0xFF120A10)],
            );
    }
    if (weatherCode == 2 || weatherCode == 3) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF402838), Color(0xFF2C1C28), Color(0xFF1A1018)],
      );
    }
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF302030), Color(0xFF201520), Color(0xFF150C15)],
      );
    }
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF382838), Color(0xFF2A1C2A), Color(0xFF1A1018)],
      );
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2A1520), Color(0xFF1A0C15), Color(0xFF10080C)],
      );
    }
    // Default / fog
    return isDay
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A3040), Color(0xFF3A2030), Color(0xFF1A1018)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1820), Color(0xFF1E1018), Color(0xFF120A10)],
          );
  }

  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
          primary: accentColor,
          secondary: accentColorSecondary,
          error: dangerColor,
          surface: cardColor,
          onSurface: textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: textPrimary, letterSpacing: -1.5),
          displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300, color: textPrimary, letterSpacing: -0.5),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
        ),
      );
}
