import 'package:flutter/material.dart';
import 'package:weatherman/widgets/backgrounds/weather_style.dart';

/// Central lookup that returns [WeatherStyle] for a condition + sky phase.
class WeatherGradientSystem {
  WeatherGradientSystem._();

  static WeatherStyle resolve({
    required WeatherCondition condition,
    required SkyPhase phase,
    required bool isDay,
  }) {
    final colors = _gradientFor(condition, phase, isDay);
    final tint = _tintFor(condition, isDay);
    return WeatherStyle(
      gradientColors: colors,
      glassTint: tint,
      isDay: isDay,
      phase: phase,
      condition: condition,
    );
  }

  // ── Glass tints ──
  static Color _tintFor(WeatherCondition c, bool day) {
    switch (c) {
      case WeatherCondition.clearSky:
        return day ? const Color(0xFF4A90D9) : const Color(0xFF1B2951);
      case WeatherCondition.partlyCloudy:
        return day ? const Color(0xFF5DADE2) : const Color(0xFF2D4360);
      case WeatherCondition.overcast:
        return day ? const Color(0xFF78909C) : const Color(0xFF3A4656);
      case WeatherCondition.fog:
        return day ? const Color(0xFF90A4AE) : const Color(0xFF3E4850);
      case WeatherCondition.drizzle:
        return day ? const Color(0xFF78909C) : const Color(0xFF2F3E4C);
      case WeatherCondition.rain:
      case WeatherCondition.showers:
        return day ? const Color(0xFF546E7A) : const Color(0xFF1C2A34);
      case WeatherCondition.snow:
        return day ? const Color(0xFF97ADB8) : const Color(0xFF364854);
      case WeatherCondition.thunderstorm:
        return day ? const Color(0xFF455A64) : const Color(0xFF141828);
    }
  }

  // ── Gradients ──
  static List<Color> _gradientFor(WeatherCondition c, SkyPhase p, bool day) {
    // Precipitation and special conditions override sky phase
    if (c == WeatherCondition.thunderstorm) return _thunderstorm(day);
    if (c == WeatherCondition.rain || c == WeatherCondition.showers) return _rain(day);
    if (c == WeatherCondition.drizzle) return _drizzle(day);
    if (c == WeatherCondition.snow) return _snow(day);
    if (c == WeatherCondition.fog) return _fog(day);
    if (c == WeatherCondition.overcast) return _overcast(day);
    // Phase-aware for clear/partly-cloudy
    return _skyPhaseGradient(c, p);
  }

  static List<Color> _skyPhaseGradient(WeatherCondition c, SkyPhase p) {
    final partly = c == WeatherCondition.partlyCloudy;
    switch (p) {
      case SkyPhase.nightDeep:
        return partly
            ? const [Color(0xFF101828), Color(0xFF1E2E45), Color(0xFF2D4360), Color(0xFF3D5474)]
            : const [Color(0xFF070B24), Color(0xFF0F1A3C), Color(0xFF1B2951), Color(0xFF2A3F6F)];
      case SkyPhase.astronomicalTwilight:
        return const [Color(0xFF0B1026), Color(0xFF1C1B4B), Color(0xFF3B2D6B), Color(0xFF5C3D8F)];
      case SkyPhase.civilTwilight:
        return const [Color(0xFF1A1040), Color(0xFF4A2068), Color(0xFF8B3A62), Color(0xFFD4785A)];
      case SkyPhase.goldenHour:
        return const [Color(0xFF0B0033), Color(0xFF2D1B5C), Color(0xFFB34700), Color(0xFFFF8C00), Color(0xFFFFD700)];
      case SkyPhase.blueHour:
        return partly
            ? const [Color(0xFF2C3E6B), Color(0xFF4A6FA0), Color(0xFF6A9EC8), Color(0xFF9CC4E0)]
            : const [Color(0xFF1A2E55), Color(0xFF38608E), Color(0xFF5B8DB8), Color(0xFF87B8DA)];
      case SkyPhase.solarNoon:
        return partly
            ? const [Color(0xFF1565C0), Color(0xFF2E86C1), Color(0xFF5DADE2), Color(0xFF85C1E9)]
            : const [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)];
      case SkyPhase.midDay:
        return partly
            ? const [Color(0xFF1565C0), Color(0xFF2E86C1), Color(0xFF5DADE2), Color(0xFF85C1E9)]
            : const [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFF64B5F6)];
    }
  }

  // ── Precipitation / condition gradients ──
  static List<Color> _rain(bool day) => day
      ? const [Color(0xFF546E7A), Color(0xFF6B8494), Color(0xFF8298A8), Color(0xFF99ACBC)]
      : const [Color(0xFF0E1820), Color(0xFF1C2A34), Color(0xFF2A3C48), Color(0xFF384E5C)];

  static List<Color> _drizzle(bool day) => day
      ? const [Color(0xFF607D8B), Color(0xFF78909C), Color(0xFF90A4AE), Color(0xFFB0BEC5)]
      : const [Color(0xFF151E28), Color(0xFF222E3A), Color(0xFF2F3E4C), Color(0xFF3C4E5E)];

  static List<Color> _snow(bool day) => day
      ? const [Color(0xFF7E99A8), Color(0xFF97ADB8), Color(0xFFB0C2CC), Color(0xFFC8D6DE)]
      : const [Color(0xFF1A2530), Color(0xFF283642), Color(0xFF364854), Color(0xFF445A66)];

  static List<Color> _thunderstorm(bool day) => day
      ? const [Color(0xFF37474F), Color(0xFF455A64), Color(0xFF546E7A), Color(0xFF607D8B)]
      : const [Color(0xFF0A0E1A), Color(0xFF141828), Color(0xFF1E2236), Color(0xFF282C44)];

  static List<Color> _fog(bool day) => day
      ? const [Color(0xFF78909C), Color(0xFF90A4AE), Color(0xFFB0BEC5), Color(0xFFC8D0D8)]
      : const [Color(0xFF1E2830), Color(0xFF2E3840), Color(0xFF3E4850), Color(0xFF4E5860)];

  static List<Color> _overcast(bool day) => day
      ? const [Color(0xFF546E7A), Color(0xFF6B838F), Color(0xFF8398A4), Color(0xFF90A4AE)]
      : const [Color(0xFF1A2332), Color(0xFF2A3444), Color(0xFF3A4656), Color(0xFF4A5666)];

  /// For debug screen: resolve a style from raw weatherCode + isDay.
  static WeatherStyle fromCode(int weatherCode, bool isDay, {DateTime? sunrise, DateTime? sunset}) {
    final condition = conditionFromCode(weatherCode);
    // If no sunrise/sunset info, use simple day/night
    SkyPhase phase;
    if (isDay) {
      phase = SkyPhase.midDay;
    } else {
      phase = SkyPhase.nightDeep;
    }
    return resolve(condition: condition, phase: phase, isDay: isDay);
  }
}
