import 'package:weatherman/widgets/backgrounds/weather_style.dart';

/// Calculates [SkyPhase] from the current time relative to sunrise/sunset.
class SkyPhaseCalculator {
  SkyPhaseCalculator._();

  /// Determine the current sky phase.
  ///
  /// [now] current time, [sunrise] and [sunset] for today.
  static SkyPhase calculate(DateTime now, DateTime sunrise, DateTime sunset) {
    final minutesSinceMidnight = now.hour * 60 + now.minute;
    final sunriseMin = sunrise.hour * 60 + sunrise.minute;
    final sunsetMin = sunset.hour * 60 + sunset.minute;

    final beforeSunrise = sunriseMin - minutesSinceMidnight;
    final afterSunrise = minutesSinceMidnight - sunriseMin;
    final beforeSunset = sunsetMin - minutesSinceMidnight;
    final afterSunset = minutesSinceMidnight - sunsetMin;

    // Night deep: > 2 h after sunset or > 1 h before sunrise
    if (afterSunset > 120 || beforeSunrise > 60) {
      return SkyPhase.nightDeep;
    }

    // Astronomical twilight: within 1 h of sunrise (before) or 1–2 h after sunset
    if (beforeSunrise > 0 && beforeSunrise <= 60) {
      return SkyPhase.astronomicalTwilight;
    }
    if (afterSunset > 60 && afterSunset <= 120) {
      return SkyPhase.astronomicalTwilight;
    }

    // Civil twilight: 0–30 min before sunrise or 30–60 min after sunset
    if (beforeSunrise > -30 && beforeSunrise <= 0) {
      // Note: negative = just past sunrise
      return SkyPhase.civilTwilight;
    }
    if (afterSunset > 0 && afterSunset <= 60) {
      return SkyPhase.civilTwilight;
    }

    // Golden hour: 0–45 min after sunrise or 45–0 min before sunset
    if (afterSunrise >= 0 && afterSunrise <= 45) {
      return SkyPhase.goldenHour;
    }
    if (beforeSunset >= 0 && beforeSunset <= 45) {
      return SkyPhase.goldenHour;
    }

    // Blue hour: 45–90 min after sunrise or 90–45 min before sunset
    if (afterSunrise > 45 && afterSunrise <= 90) {
      return SkyPhase.blueHour;
    }
    if (beforeSunset > 45 && beforeSunset <= 90) {
      return SkyPhase.blueHour;
    }

    // Solar noon: within 1 h of midpoint between sunrise and sunset
    final solarNoonMin = (sunriseMin + sunsetMin) ~/ 2;
    if ((minutesSinceMidnight - solarNoonMin).abs() <= 60) {
      return SkyPhase.solarNoon;
    }

    // Otherwise general midDay
    return SkyPhase.midDay;
  }

  /// Whether the current time is during daytime (between sunrise and sunset).
  static bool isDaytime(DateTime now, DateTime sunrise, DateTime sunset) {
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  /// Fractional sun position (0 = sunrise, 1 = sunset).
  /// Returns null if outside daytime.
  static double? sunProgress(DateTime now, DateTime sunrise, DateTime sunset) {
    if (now.isBefore(sunrise) || now.isAfter(sunset)) return null;
    final total = sunset.difference(sunrise).inMinutes;
    if (total <= 0) return null;
    return now.difference(sunrise).inMinutes / total;
  }
}
