import 'package:flutter/material.dart';
import 'package:weatherman/config/app_theme_data.dart';

/// Pastel / Kawaii theme (light variant) — soft colors, rounded corners, playful aesthetic
class PastelTheme extends AppThemeData {
  @override
  AppThemeType get type => AppThemeType.pastel;

  // ── Pastel Palette ──
  static const Color lavender = Color(0xFFB8A9E8);
  static const Color mint = Color(0xFF98E4C9);
  static const Color peach = Color(0xFFFFC3A0);
  static const Color babyBlue = Color(0xFFA0D2F0);
  static const Color babyPink = Color(0xFFFFB7D5);
  static const Color cream = Color(0xFFFFF5E6);
  static const Color lilac = Color(0xFFD4A5E5);
  static const Color softYellow = Color(0xFFFFE7A0);
  static const Color softRed = Color(0xFFFF9B9B);
  static const Color softGreen = Color(0xFF9BEAB0);

  // ── Backgrounds ──
  static const Color bgLight = Color(0xFFFAF5FF);
  static const Color bgCard = Color(0xFFFFFFFF);

  @override
  Color get accentColor => const Color(0xFF7B5EAE); // deeper purple for contrast
  @override
  Color get accentColorSecondary => const Color(0xFFE07BAD); // deeper pink
  @override
  Color get backgroundColor => bgLight;
  @override
  Color get cardColor => bgCard;
  @override
  Color get cardBorderColor => lavender.withValues(alpha: 0.4);
  @override
  Color get textPrimary => const Color(0xFF2D1F4E); // much darker for readability
  @override
  Color get textSecondary => const Color(0xFF5A4680); // darker secondary
  @override
  Color get textTertiary => const Color(0xFF8878A8);
  @override
  Color get dangerColor => const Color(0xFFE05D5D);
  @override
  Color get warningColor => const Color(0xFFD4A030);
  @override
  Color get successColor => const Color(0xFF4EAF68);
  @override
  Color get infoColor => const Color(0xFF5A9BD5);

  @override
  double get cardBorderRadius => 20;
  @override
  double get cardBorderWidth => 1.5;
  @override
  double get cardBlurSigma => 10;
  @override
  Color get cardGlowColor => lavender.withValues(alpha: 0.15);

  @override
  String? get fontFamily => 'Nunito';
  @override
  bool get useMonospace => false;

  @override
  List<Shadow> get accentGlow => [];
  @override
  List<Shadow> get subtleGlow => [];
  @override
  List<Shadow> get textShadows => const [
        Shadow(
          color: Color(0x30000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ];

  @override
  LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    // Clear sky
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF88B8E0), Color(0xFFB8D4F0), Color(0xFFE8E0F5)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5B4B85), Color(0xFF8878B0), Color(0xFFBBADD8)],
            );
    }
    // Partly cloudy
    if (weatherCode == 2 || weatherCode == 3) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9AADCC), Color(0xFFBEC8DD), Color(0xFFDDD8E8)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5A5080), Color(0xFF7F75A5), Color(0xFFADA0CC)],
            );
    }
    // Fog
    if (weatherCode == 45 || weatherCode == 48) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFA8A0C0), Color(0xFFC8C0D8), Color(0xFFE5DDF0)],
      );
    }
    // Rain/Drizzle
    if ((weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82)) {
      return isDay
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7890B0), Color(0xFF9AACC5), Color(0xFFC5BED5)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF484070), Color(0xFF6A6090), Color(0xFF9888B8)],
            );
    }
    // Snow
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB0A8CC), Color(0xFFD0C8E0), Color(0xFFEBE5F5)],
      );
    }
    // Thunderstorm
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF605088), Color(0xFF8070A8), Color(0xFFAA98CC)],
      );
    }
    // Default
    return isDay
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF88B8E0), Color(0xFFB8D4F0), Color(0xFFE8E0F5)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B4B85), Color(0xFF8878B0), Color(0xFFBBADD8)],
          );
  }

  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: lavender,
          brightness: Brightness.light,
          primary: accentColor,
          secondary: accentColorSecondary,
          error: dangerColor,
          surface: bgCard,
          onSurface: textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Nunito',
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        textTheme: _buildTextTheme(),
      );

  TextTheme _buildTextTheme() => TextTheme(
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
  String? get fontFamily => 'Nunito';
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
        fontFamily: 'Nunito',
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
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Nunito',
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
