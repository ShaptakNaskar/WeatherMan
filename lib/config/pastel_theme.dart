import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Catppuccin Latte theme — soothing pastel light theme with harmonious colors
/// Based on the official Catppuccin Latte palette: https://catppuccin.com/palette
/// NOTE: Currently disabled - uncomment AppThemeType.pastel in app_theme_data.dart to enable
class CatppuccinLatteTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.pastelDark; // Temporarily use pastelDark since pastel is commented out

  // ══════════════════════════════════════════════════════════════════════════
  // Catppuccin Latte Palette (Official)
  // ══════════════════════════════════════════════════════════════════════════

  // ── Base Colors ──
  static const Color base = Color(0xFFEFF1F5); // Main background
  static const Color mantle = Color(0xFFE6E9EF); // Secondary background
  static const Color crust = Color(0xFFDCE0E8); // Tertiary background

  // ── Surface Colors ──
  static const Color surface0 = Color(0xFFCCD0DA); // Cards, panels
  static const Color surface1 = Color(0xFFBCC0CC); // Elevated surfaces
  static const Color surface2 = Color(0xFFACB0BE); // Higher elevation

  // ── Overlay Colors ──
  static const Color overlay0 = Color(0xFF9CA0B0);
  static const Color overlay1 = Color(0xFF8C8FA1);
  static const Color overlay2 = Color(0xFF7C7F93);

  // ── Text Colors ──
  static const Color text = Color(0xFF4C4F69); // Primary text
  static const Color subtext1 = Color(0xFF5C5F77); // Secondary text
  static const Color subtext0 = Color(0xFF6C6F85); // Tertiary text

  // ── Accent Colors ──
  static const Color rosewater = Color(0xFFDC8A78);
  static const Color flamingo = Color(0xFFDD7878);
  static const Color pink = Color(0xFFEA76CB);
  static const Color mauve = Color(0xFF8839EF);
  static const Color red = Color(0xFFD20F39);
  static const Color maroon = Color(0xFFE64553);
  static const Color peach = Color(0xFFFE640B);
  static const Color yellow = Color(0xFFDF8E1D);
  static const Color green = Color(0xFF40A02B);
  static const Color teal = Color(0xFF179299);
  static const Color sky = Color(0xFF04A5E5);
  static const Color sapphire = Color(0xFF209FB5);
  static const Color blue = Color(0xFF1E66F5);
  static const Color lavender = Color(0xFF7287FD);

  // ══════════════════════════════════════════════════════════════════════════
  // Theme Implementation
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Color get accentColor => lavender;
  @override
  Color get accentColorSecondary => mauve;
  @override
  Color get backgroundColor => base;
  @override
  Color get cardColor => mantle; // Cards slightly darker than background for depth
  @override
  Color get cardBorderColor => surface0;
  @override
  Color get textPrimary => text;
  @override
  Color get textSecondary => subtext1;
  @override
  Color get textTertiary => subtext0;
  @override
  Color get dangerColor => red;
  @override
  Color get warningColor => yellow;
  @override
  Color get successColor => green;
  @override
  Color get infoColor => blue;

  @override
  double get cardBorderRadius => 16;
  @override
  double get cardBorderWidth => 1;
  @override
  double get cardBlurSigma => 8;
  @override
  Color get cardGlowColor => lavender.withValues(alpha: 0.1);

  @override
  String? get fontFamily => 'Quicksand';
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get accentGlow => [];
  @override
  List<Shadow> get subtleGlow => const [
    Shadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  @override
  List<Shadow> get textShadows => const []; // Light theme doesn't need text shadows

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    // LIGHT-ONLY THEME: Catppuccin Latte always uses light gradients
    // regardless of time of day. The isDay parameter is intentionally ignored.
    // All backgrounds remain light and airy even at night.

    // Clear sky - soft sky blue tint
    if (weatherCode == 0 || weatherCode == 1) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          sky.withValues(alpha: 0.25),
          sapphire.withValues(alpha: 0.12),
          base,
        ],
      );
    }
    // Partly cloudy - subtle gray overlay
    if (weatherCode == 2 || weatherCode == 3) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          surface1.withValues(alpha: 0.5),
          surface0.withValues(alpha: 0.3),
          base,
        ],
      );
    }
    // Fog - misty gray
    if (weatherCode == 45 || weatherCode == 48) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          overlay0.withValues(alpha: 0.4),
          surface1.withValues(alpha: 0.3),
          base,
        ],
      );
    }
    // Rain/Drizzle - cool blue tint
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          sapphire.withValues(alpha: 0.2),
          blue.withValues(alpha: 0.1),
          base,
        ],
      );
    }
    // Snow - crisp white/gray
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          surface1.withValues(alpha: 0.5),
          surface0.withValues(alpha: 0.3),
          base,
        ],
      );
    }
    // Thunderstorm - dramatic but still light
    if (weatherCode >= 95 && weatherCode <= 99) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          overlay1.withValues(alpha: 0.5),
          surface1.withValues(alpha: 0.35),
          base,
        ],
      );
    }
    // Default - clear sky
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        sky.withValues(alpha: 0.25),
        sapphire.withValues(alpha: 0.12),
        base,
      ],
    );
  }

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.quicksandTextTheme(_buildTextTheme()),
    colorScheme: ColorScheme.light(
      primary: lavender,
      secondary: mauve,
      tertiary: pink,
      error: red,
      surface: mantle,
      onSurface: text,
      onPrimary: base,
      onSecondary: base,
      outline: surface1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      iconTheme: const IconThemeData(color: text),
    ),
    cardTheme: CardThemeData(
      color: mantle,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: surface0, width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(color: surface0, thickness: 1),
    iconTheme: const IconThemeData(color: subtext0),
  );

  TextTheme _buildTextTheme() => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      color: text,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      color: text,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: text,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: text,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: text,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: subtext1,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: subtext0,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: subtext1,
    ),
  );
}

/// Pastel dark mode — dreamy night aesthetic with muted pastels on dark
class PastelDarkTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.pastelDark;

  @override
  Color get accentColor => const Color(0xFFCBB8F0); // soft lavender
  @override
  Color get accentColorSecondary => const Color(0xFFFFB7D5); // baby pink
  @override
  Color get backgroundColor => const Color(0xFF1A1525); // deep purple-black
  @override
  Color get cardColor => const Color(0xFF2A2235); // dark panel
  @override
  Color get cardBorderColor => const Color(0xFF4A3D65);
  @override
  Color get textPrimary => const Color(0xFFF0EAF8);
  @override
  Color get textSecondary => const Color(0xFFBBAADD);
  @override
  Color get textTertiary => const Color(0xFF887AAA);
  @override
  Color get dangerColor => const Color(0xFFFF9B9B);
  @override
  Color get warningColor => const Color(0xFFFFE7A0);
  @override
  Color get successColor => const Color(0xFF9BEAB0);
  @override
  Color get infoColor => const Color(0xFFA0D2F0);

  @override
  double get cardBorderRadius => 20;
  @override
  double get cardBorderWidth => 1;
  @override
  double get cardBlurSigma => 8;
  @override
  Color get cardGlowColor => const Color(0x20CBB8F0);

  @override
  String? get fontFamily => 'Quicksand'; // Cute kawaii font via GoogleFonts
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get accentGlow => [
    const Shadow(color: Color(0x40CBB8F0), blurRadius: 8, offset: Offset.zero),
  ];
  @override
  List<Shadow> get subtleGlow => [
    const Shadow(color: Color(0x20CBB8F0), blurRadius: 4, offset: Offset.zero),
  ];
  @override
  List<Shadow> get textShadows => const [];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A2D55), Color(0xFF2A2040), Color(0xFF1A1525)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1530), Color(0xFF161020), Color(0xFF100C18)],
            );
    }
    if (weatherCode == 2 || weatherCode == 3) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF302848), Color(0xFF252038), Color(0xFF1A1528)],
      );
    }
    if (weatherCode == 45 || weatherCode == 48) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2D2840), Color(0xFF222035), Color(0xFF1A1828)],
      );
    }
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF252045), Color(0xFF1D1835), Color(0xFF151025)],
      );
    }
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF302848), Color(0xFF252040), Color(0xFF1C1830)],
      );
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF201840), Color(0xFF181030), Color(0xFF100820)],
      );
    }
    return isDay
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A2D55), Color(0xFF2A2040), Color(0xFF1A1525)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1530), Color(0xFF161020), Color(0xFF100C18)],
          );
  }

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.quicksandTextTheme(_buildDarkTextTheme()),
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
      titleTextStyle: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );

  TextTheme _buildDarkTextTheme() => TextTheme(
    displayLarge: TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      color: textPrimary,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
  );
}
