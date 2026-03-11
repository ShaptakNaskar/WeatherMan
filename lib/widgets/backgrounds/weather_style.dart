import 'package:flutter/material.dart';

/// Sky phases based on solar position relative to sunrise/sunset.
enum SkyPhase {
  nightDeep,
  astronomicalTwilight,
  civilTwilight,
  goldenHour,
  blueHour,
  solarNoon,
  midDay,
}

/// Weather condition groups for gradient selection.
enum WeatherCondition {
  clearSky,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  showers,
  thunderstorm,
}

/// Maps a WMO weather code to a [WeatherCondition].
WeatherCondition conditionFromCode(int code) {
  if (code <= 1) return WeatherCondition.clearSky;
  if (code == 2) return WeatherCondition.partlyCloudy;
  if (code == 3) return WeatherCondition.overcast;
  if (code == 45 || code == 48) return WeatherCondition.fog;
  if (code >= 51 && code <= 57) return WeatherCondition.drizzle;
  if (code >= 61 && code <= 67) return WeatherCondition.rain;
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
    return WeatherCondition.snow;
  }
  if (code >= 80 && code <= 82) return WeatherCondition.showers;
  if (code >= 95) return WeatherCondition.thunderstorm;
  return WeatherCondition.clearSky;
}

/// Immutable descriptor for the visual style of a weather state.
class WeatherStyle {
  /// Top-to-bottom gradient colors.
  final List<Color> gradientColors;

  /// Glass tint color for glass cards.
  final Color glassTint;

  /// Whether it is daytime.
  final bool isDay;

  /// Current sky phase.
  final SkyPhase phase;

  /// Current weather condition.
  final WeatherCondition condition;

  const WeatherStyle({
    required this.gradientColors,
    required this.glassTint,
    required this.isDay,
    required this.phase,
    required this.condition,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      );

  /// Fallback style used before data loads.
  static const WeatherStyle fallback = WeatherStyle(
    gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFF64B5F6)],
    glassTint: Color(0xFF4A90D9),
    isDay: true,
    phase: SkyPhase.midDay,
    condition: WeatherCondition.clearSky,
  );
}
