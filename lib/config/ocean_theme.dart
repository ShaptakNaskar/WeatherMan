import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Ocean theme — deep sea blues and teals on dark background
class OceanTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.ocean;

  @override
  Color get accentColor => const Color(0xFFFFC987);
  @override
  Color get accentColorSecondary => const Color(0xFF74D6FF);
  @override
  Color get backgroundColor => const Color(0xFF07131D);
  @override
  Color get cardColor => const Color(0x99132534);
  @override
  Color get cardBorderColor => const Color(0x66FFD6A1);
  @override
  Color get textPrimary => const Color(0xFFEAFBFF);
  @override
  Color get textSecondary => const Color(0xCCB7DEEA);
  @override
  Color get textTertiary => const Color(0x998CB1BF);
  @override
  Color get dangerColor => const Color(0xFFFF5252);
  @override
  Color get warningColor => const Color(0xFFFFC987);
  @override
  Color get successColor => const Color(0xFF84F3C3);
  @override
  Color get infoColor => const Color(0xFF8EDFFF);

  @override
  double get cardBorderRadius => 20;
  @override
  double get cardBorderWidth => 1.2;
  @override
  double get cardBlurSigma => 18;
  @override
  Color get cardGlowColor => const Color(0x22FFC987);

  @override
  String? get fontFamily => 'Outfit';
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get subtleGlow => [
    const Shadow(color: Color(0x40FFC987), blurRadius: 8, offset: Offset.zero),
  ];

  @override
  List<Shadow> get accentGlow => [
    const Shadow(color: Color(0x55FFC987), blurRadius: 14, offset: Offset.zero),
  ];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF153C55),
                Color(0xFF1A4E6D),
                Color(0xFF22617E),
                Color(0xFF143F5A),
              ],
              stops: [0.0, 0.32, 0.7, 1.0],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF061320),
                Color(0xFF0B1A2B),
                Color(0xFF10283D),
                Color(0xFF07131F),
              ],
              stops: [0.0, 0.38, 0.78, 1.0],
            );
    }
    if (weatherCode == 2 || weatherCode == 3) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF173A50),
          Color(0xFF1A455E),
          Color(0xFF1F5270),
          Color(0xFF16384D),
        ],
      );
    }
    if (weatherCode == 45 || weatherCode == 48) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF294352),
          Color(0xFF244151),
          Color(0xFF1F3948),
          Color(0xFF17313F),
        ],
      );
    }
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A2537),
          Color(0xFF0D1E2C),
          Color(0xFF112235),
          Color(0xFF091624),
        ],
      );
    }
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3A5366),
          Color(0xFF2F475A),
          Color(0xFF243D51),
          Color(0xFF1C3346),
        ],
      );
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF081325),
          Color(0xFF0D1A31),
          Color(0xFF11233F),
          Color(0xFF091626),
        ],
      );
    }
    return isDay
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF153C55),
              Color(0xFF1A4E6D),
              Color(0xFF22617E),
              Color(0xFF143F5A),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF061320),
              Color(0xFF0B1A2B),
              Color(0xFF10283D),
              Color(0xFF07131F),
            ],
          );
  }

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.outfitTextTheme(
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
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );
}
