import 'package:flutter/material.dart';

/// App theme configuration with weather-adaptive colors
class AppTheme {
  // Primary color palette
  static const Color primaryBlue = Color(0xFF4A90D9);
  static const Color accentBlue = Color(0xFF64B5F6);
  
  // Glassmorphic colors
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x66FFFFFF);
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textTertiary = Color(0x99FFFFFF);
  
  // Weather-adaptive background gradients
  static const LinearGradient clearDayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4A90D9),
      Color(0xFF87CEEB),
      Color(0xFFB0E0E6),
    ],
  );
  
  static const LinearGradient clearNightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F0C29),
      Color(0xFF302B63),
      Color(0xFF24243E),
    ],
  );
  
  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF606C88),
      Color(0xFF8B9CB5),
      Color(0xFFB0BEC5),
    ],
  );
  
  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A2A3A),
      Color(0xFF2C3E50),
      Color(0xFF3D5A73),
    ],
  );
  
  static const LinearGradient snowyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFB0C4DE),
      Color(0xFFD3E0EA),
      Color(0xFFE8EFF5),
    ],
  );
  
  static const LinearGradient thunderstormGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
      Color(0xFF0F3460),
    ],
  );
  
  static const LinearGradient foggyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF9E9E9E),
      Color(0xFFBDBDBD),
      Color(0xFFE0E0E0),
    ],
  );
  
  /// Get gradient based on weather code and day/night
  static LinearGradient getWeatherGradient(int weatherCode, bool isDay) {
    // Clear sky
    if (weatherCode == 0 || weatherCode == 1) {
      return isDay ? clearDayGradient : clearNightGradient;
    }
    // Partly cloudy
    if (weatherCode == 2 || weatherCode == 3) {
      return isDay ? cloudyGradient : clearNightGradient;
    }
    // Fog
    if (weatherCode >= 45 && weatherCode <= 48) {
      return foggyGradient;
    }
    // Rain/Drizzle
    if ((weatherCode >= 51 && weatherCode <= 67) || 
        (weatherCode >= 80 && weatherCode <= 82)) {
      return rainyGradient;
    }
    // Snow
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return snowyGradient;
    }
    // Thunderstorm
    if (weatherCode >= 95 && weatherCode <= 99) {
      return thunderstormGradient;
    }
    // Default
    return isDay ? clearDayGradient : clearNightGradient;
  }
  
  /// App theme data
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
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
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 96,
        fontWeight: FontWeight.w200,
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
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
    ),
  );
}
