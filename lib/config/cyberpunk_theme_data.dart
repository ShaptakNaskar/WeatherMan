import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/config/cyberpunk_theme.dart';

/// Wraps the existing CyberpunkTheme static class into the AppThemeData interface
class CyberpunkThemeData extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.cyberpunk;

  @override
  Color get accentColor => const Color(0xFF00F7FF);
  @override
  Color get accentColorSecondary => const Color(0xFFFF3CB4);
  @override
  Color get backgroundColor => const Color(0xFF04070E);
  @override
  Color get cardColor => const Color(0x99101824);
  @override
  Color get cardBorderColor => const Color(0x7700E8FF);
  @override
  Color get textPrimary => CyberpunkTheme.textPrimary;
  @override
  Color get textSecondary => const Color(0xCC8AEEFF);
  @override
  Color get textTertiary => const Color(0x9986A4C0);
  @override
  Color get dangerColor => CyberpunkTheme.neonRed;
  @override
  Color get warningColor => const Color(0xFFFFD85A);
  @override
  Color get successColor => CyberpunkTheme.neonGreen;
  @override
  Color get infoColor => const Color(0xFF5FA0FF);

  @override
  double get cardBorderRadius => 10;
  @override
  double get cardBorderWidth => 1.25;
  @override
  double get cardBlurSigma => 8;
  @override
  Color get cardGlowColor => const Color(0x2600F7FF);

  @override
  String? get fontFamily => 'Oxanium';
  @override
  bool get useMonospace => true;

  @override
  List<Shadow> get accentGlow => const [
    Shadow(color: Color(0xA000F7FF), blurRadius: 16, offset: Offset.zero),
    Shadow(color: Color(0x4D00F7FF), blurRadius: 30, offset: Offset.zero),
  ];
  @override
  List<Shadow> get subtleGlow => const [
    Shadow(color: Color(0x6600F7FF), blurRadius: 8, offset: Offset.zero),
  ];
  @override
  List<Shadow> get textShadows => const [];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF071020),
                Color(0xFF10223F),
                Color(0xFF1A2F57),
                Color(0xFF0B1225),
              ],
              stops: [0.0, 0.42, 0.78, 1.0],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF02030A),
                Color(0xFF070B1A),
                Color(0xFF0E1330),
                Color(0xFF050915),
              ],
              stops: [0.0, 0.38, 0.78, 1.0],
            );
    }

    if (weatherCode == 2 || weatherCode == 3) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF080F1E),
                Color(0xFF121D34),
                Color(0xFF1F2D4A),
                Color(0xFF111A2E),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF03050D),
                Color(0xFF090E1E),
                Color(0xFF111832),
                Color(0xFF060A14),
              ],
            );
    }

    if (weatherCode == 45 || weatherCode == 48) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF080A15),
          Color(0xFF101628),
          Color(0xFF171F2F),
          Color(0xFF0A101E),
        ],
      );
    }

    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF04070F),
          Color(0xFF0B1021),
          Color(0xFF151E3A),
          Color(0xFF0A1225),
        ],
      );
    }

    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A0F20),
          Color(0xFF111B34),
          Color(0xFF1A2748),
          Color(0xFF101A31),
        ],
      );
    }

    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF080311),
          Color(0xFF130822),
          Color(0xFF1C0E2E),
          Color(0xFF0A071A),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF071020),
        Color(0xFF10223F),
        Color(0xFF1A2F57),
        Color(0xFF0B1225),
      ],
    );
  }

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.oxaniumTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
      surface: const Color(0xFF0A0F1C),
      onSurface: textPrimary,
      error: dangerColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.oxanium(
        color: accentColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(color: accentColor),
    ),
  );
}
