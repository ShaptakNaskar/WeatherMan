import 'package:flutter/material.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Ocean theme — deep sea blues and teals on dark background
class OceanTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.ocean;

  @override
  Color get accentColor => const Color(0xFF00BFA5); // teal
  @override
  Color get accentColorSecondary => const Color(0xFF40C4FF); // light blue
  @override
  Color get backgroundColor => const Color(0xFF0A1520);
  @override
  Color get cardColor => const Color(0xFF122030);
  @override
  Color get cardBorderColor => const Color(0x4000BFA5);
  @override
  Color get textPrimary => const Color(0xFFE8F5F8);
  @override
  Color get textSecondary => const Color(0xFFAAC8D5);
  @override
  Color get textTertiary => const Color(0xFF708898);
  @override
  Color get dangerColor => const Color(0xFFFF5252);
  @override
  Color get warningColor => const Color(0xFFFFCA28);
  @override
  Color get successColor => const Color(0xFF69F0AE);
  @override
  Color get infoColor => const Color(0xFF40C4FF);

  @override
  double get cardBorderRadius => 12;
  @override
  double get cardBorderWidth => 1;
  @override
  double get cardBlurSigma => 8;
  @override
  Color get cardGlowColor => const Color(0x1800BFA5);

  @override
  String? get fontFamily => null;
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get subtleGlow => [
        const Shadow(color: Color(0x3000BFA5), blurRadius: 6, offset: Offset.zero),
      ];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A3A4A), Color(0xFF122830), Color(0xFF0A1520)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1E28), Color(0xFF0A1520), Color(0xFF060E15)],
            );
    }
    if (weatherCode == 2 || weatherCode == 3) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF183040), Color(0xFF10202C), Color(0xFF0A1520)],
      );
    }
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF102030), Color(0xFF0C1822), Color(0xFF080E18)],
      );
    }
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A2838), Color(0xFF121E2A), Color(0xFF0A1520)],
      );
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0C1828), Color(0xFF08101C), Color(0xFF040810)],
      );
    }
    return isDay
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A3A4A), Color(0xFF122830), Color(0xFF0A1520)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1E28), Color(0xFF0A1520), Color(0xFF060E15)],
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
