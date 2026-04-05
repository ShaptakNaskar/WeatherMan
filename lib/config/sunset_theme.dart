import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Sunset theme — warm amber/coral tones on a dark background
class SunsetTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.sunset;

  @override
  Color get accentColor => const Color(0xFFFFA05F);
  @override
  Color get accentColorSecondary => const Color(0xFFFF6E9F);
  @override
  Color get backgroundColor => const Color(0xFF140B12);
  @override
  Color get cardColor => const Color(0x992A1722);
  @override
  Color get cardBorderColor => const Color(0x66FFAE70);
  @override
  Color get textPrimary => const Color(0xFFFFF3EA);
  @override
  Color get textSecondary => const Color(0xCCF4D3BE);
  @override
  Color get textTertiary => const Color(0x99D5AE98);
  @override
  Color get dangerColor => const Color(0xFFFF6262);
  @override
  Color get warningColor => const Color(0xFFFFD166);
  @override
  Color get successColor => const Color(0xFF7FCB73);
  @override
  Color get infoColor => const Color(0xFF7FB5FF);

  @override
  double get cardBorderRadius => 20;
  @override
  double get cardBorderWidth => 1.2;
  @override
  double get cardBlurSigma => 18;
  @override
  Color get cardGlowColor => const Color(0x22FFA05F);

  @override
  String? get fontFamily => 'Sora';
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get subtleGlow => [
    const Shadow(color: Color(0x40FFA05F), blurRadius: 8, offset: Offset.zero),
  ];

  @override
  List<Shadow> get accentGlow => [
    const Shadow(color: Color(0x55FFA05F), blurRadius: 14, offset: Offset.zero),
  ];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFA964),
                Color(0xFFFF7F79),
                Color(0xFFB54A6A),
                Color(0xFF4B2236),
              ],
              stops: [0.0, 0.26, 0.62, 1.0],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A1120),
                Color(0xFF3D1731),
                Color(0xFF241328),
                Color(0xFF120A14),
              ],
              stops: [0.0, 0.36, 0.72, 1.0],
            );
    }
    if (weatherCode == 2 || weatherCode == 3) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6A3646),
          Color(0xFF4D2A3A),
          Color(0xFF311D2B),
          Color(0xFF1A1018),
        ],
      );
    }
    if (weatherCode == 45 || weatherCode == 48) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6B4251),
          Color(0xFF4F313F),
          Color(0xFF362432),
          Color(0xFF211723),
        ],
      );
    }
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4A2A3B),
          Color(0xFF341E2C),
          Color(0xFF241523),
          Color(0xFF160D17),
        ],
      );
    }
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6A5A63),
          Color(0xFF4D3D49),
          Color(0xFF342732),
          Color(0xFF211820),
        ],
      );
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF311326),
          Color(0xFF270F1D),
          Color(0xFF1B0B16),
          Color(0xFF10070D),
        ],
      );
    }

    return isDay
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFA964),
              Color(0xFFFF7F79),
              Color(0xFFB54A6A),
              Color(0xFF4B2236),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A1120),
              Color(0xFF3D1731),
              Color(0xFF241328),
              Color(0xFF120A14),
            ],
          );
  }

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.soraTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300),
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
      error: dangerColor,
      surface: cardColor,
      onSurface: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.6,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );
}
