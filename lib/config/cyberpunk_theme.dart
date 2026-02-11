import 'package:flutter/material.dart';

/// Cyberpunk 2077-inspired theme configuration
/// Neon cyan + hot magenta + warning yellow on dark backgrounds
class CyberpunkTheme {
  // === PRIMARY NEON PALETTE ===
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFFF2E97);
  static const Color neonYellow = Color(0xFFFFD700);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonRed = Color(0xFFFF0040);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonBlue = Color(0xFF2979FF);

  // === BACKGROUND COLORS ===
  static const Color bgDarkest = Color(0xFF05080F);
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgMid = Color(0xFF111827);
  static const Color bgPanel = Color(0xFF0D1117);

  // === GLASS/PANEL COLORS ===
  static const Color glassCyan = Color(0x1A00F0FF);
  static const Color glassMagenta = Color(0x1AFF2E97);
  static const Color glassBorder = Color(0x4000F0FF);
  static const Color glassBorderWarn = Color(0x40FFD700);
  static const Color glassBorderDanger = Color(0x60FF0040);

  // === TEXT COLORS ===
  static const Color textPrimary = Color(0xFFE0F7FA);
  static const Color textSecondary = Color(0xAA00F0FF);
  static const Color textTertiary = Color(0x6600F0FF);
  static const Color textWarning = Color(0xFFFFD700);
  static const Color textDanger = Color(0xFFFF0040);

  // === NEON GLOW SHADOWS ===
  static List<Shadow> neonCyanGlow = [
    const Shadow(color: Color(0x8000F0FF), blurRadius: 12, offset: Offset(0, 0)),
    const Shadow(color: Color(0x4000F0FF), blurRadius: 24, offset: Offset(0, 0)),
  ];

  static List<Shadow> neonMagentaGlow = [
    const Shadow(color: Color(0x80FF2E97), blurRadius: 12, offset: Offset(0, 0)),
    const Shadow(color: Color(0x40FF2E97), blurRadius: 24, offset: Offset(0, 0)),
  ];

  static List<Shadow> neonYellowGlow = [
    const Shadow(color: Color(0x80FFD700), blurRadius: 12, offset: Offset(0, 0)),
    const Shadow(color: Color(0x40FFD700), blurRadius: 24, offset: Offset(0, 0)),
  ];

  static List<Shadow> neonRedGlow = [
    const Shadow(color: Color(0x80FF0040), blurRadius: 12, offset: Offset(0, 0)),
    const Shadow(color: Color(0x40FF0040), blurRadius: 24, offset: Offset(0, 0)),
  ];

  static List<Shadow> subtleCyanGlow = [
    const Shadow(color: Color(0x4000F0FF), blurRadius: 6, offset: Offset(0, 0)),
  ];

  // === HUD TEXT STYLE (MONOSPACE) ===
  static const String monoFont = 'monospace';

  // === WEATHER GRADIENTS (CYBERPUNK EDITION) ===
  static LinearGradient getWeatherGradient(int code, bool isDay) {
    // Clear sky
    if (code == 0 || code == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1628), Color(0xFF0E1F3D), Color(0xFF132D52), Color(0xFF0A1628)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF050810), Color(0xFF0A0E1A), Color(0xFF0F1527), Color(0xFF050810)],
            );
    }
    // Partly cloudy
    if (code == 2 || code == 3) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1321), Color(0xFF141E33), Color(0xFF1A2744), Color(0xFF0D1321)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070A14), Color(0xFF0C1020), Color(0xFF10152B), Color(0xFF070A14)],
            );
    }
    // Fog
    if (code == 45 || code == 48) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF101520), Color(0xFF181F2E), Color(0xFF202838), Color(0xFF101520)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF090C15), Color(0xFF0F131E), Color(0xFF141A25), Color(0xFF090C15)],
            );
    }
    // Rain/Drizzle
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF080C18), Color(0xFF0C1225), Color(0xFF101832), Color(0xFF080C18)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF04060E), Color(0xFF070A18), Color(0xFF0A0E22), Color(0xFF04060E)],
            );
    }
    // Snow
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1220), Color(0xFF141A2C), Color(0xFF1A2238), Color(0xFF0E1220)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF080A16), Color(0xFF0C1020), Color(0xFF10162A), Color(0xFF080A16)],
            );
    }
    // Thunderstorm
    if (code >= 95 && code <= 99) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0818), Color(0xFF120E24), Color(0xFF1A1430), Color(0xFF0A0818)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF06050F), Color(0xFF0D0A1A), Color(0xFF140F25), Color(0xFF06050F)],
            );
    }
    // Default
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A1628), Color(0xFF0E1F3D), Color(0xFF132D52), Color(0xFF0A1628)],
    );
  }

  /// Full ThemeData for the cyberpunk app
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: neonCyan,
      onPrimary: bgDarkest,
      secondary: neonMagenta,
      onSecondary: bgDarkest,
      error: neonRed,
      onError: textPrimary,
      surface: bgDark,
      onSurface: textPrimary,
      surfaceContainerHighest: bgMid,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neonCyan,
        letterSpacing: 2,
        shadows: subtleCyanGlow,
      ),
      iconTheme: const IconThemeData(color: neonCyan),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w200,
        color: textPrimary,
        letterSpacing: -1.5,
        shadows: neonCyanGlow,
      ),
      displayMedium: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: textPrimary,
        letterSpacing: -0.5,
        shadows: neonCyanGlow,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: neonCyan,
        letterSpacing: 2,
        shadows: neonCyanGlow,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        shadows: subtleCyanGlow,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 1,
        shadows: subtleCyanGlow,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        shadows: subtleCyanGlow,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        shadows: subtleCyanGlow,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        shadows: subtleCyanGlow,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: neonCyan,
        letterSpacing: 1.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 1,
      ),
    ),
  );
}
