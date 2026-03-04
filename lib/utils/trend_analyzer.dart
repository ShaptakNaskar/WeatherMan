import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/weather_utils.dart';

/// Severity of a weather insight
enum InsightSeverity { info, warning, severe }

/// Represents a concise trend message for notifications/widgets
class TrendInsight {
  final String title;
  final String body;
  final InsightSeverity severity;

  const TrendInsight({
    required this.title,
    required this.body,
    this.severity = InsightSeverity.info,
  });
}

class TrendAnalyzer {
  // ─── Public API ───────────────────────────────────────────────

  /// Return the single highest-priority insight (backward-compatible).
  static TrendInsight? detect(WeatherData data) {
    final all = detectAll(data);
    return all.isNotEmpty ? all.first : null;
  }

  /// Return ALL applicable insights, sorted severe → info.
  static List<TrendInsight> detectAll(WeatherData data) {
    final insights = <TrendInsight>[];
    final daily = data.daily;
    final hourly = data.hourly;
    if (daily.length < 2 || hourly.isEmpty) return insights;

    // ── Severe weather alerts (highest priority) ──
    _checkThunderstorms(hourly, insights);
    _checkHeavyPrecipitation(hourly, daily, insights);
    _checkExtremeTemperature(daily, insights);
    _checkDangerousWind(hourly, daily, insights);

    // ── Multi-day temperature trends ──
    _checkWeeklyWarming(daily, insights);
    _checkWeeklyCooling(daily, insights);
    _check48hTempShift(daily, insights);

    // ── Overnight / imminent changes ──
    _checkNightfallDrop(hourly, insights);

    // ── Precipitation intelligence ──
    _checkRainProbabilityRising(hourly, insights);
    _checkSnowIncoming(hourly, daily, insights);
    _checkDrySpell(daily, insights);
    _checkRainEndingSoon(hourly, insights);

    // ── UV & Air Quality ──
    _checkUvExtreme(daily, insights);
    _checkAirQuality(data, insights);

    // ── Atmospheric ──
    _checkWindPickingUp(hourly, insights);
    _checkFogRisk(hourly, insights);
    _checkBigTempSwing(daily, insights);

    // Sort: severe first, then warning, then info
    insights.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return insights;
  }

  // ─── Severe Weather ───────────────────────────────────────────

  static void _checkThunderstorms(List<HourlyForecast> hourly, List<TrendInsight> out) {
    final next12 = hourly.take(12).toList();
    final storm = next12.where((h) => h.weatherCode >= 95);
    if (storm.isNotEmpty) {
      final first = storm.first;
      final h = _hoursUntil(first.time);
      final desc = WeatherUtils.getWeatherDescription(first.weatherCode);
      out.add(TrendInsight(
        title: '⚡ STORM_FRONT DETECTED',
        body: '$desc ETA ~${h}h. EM interference imminent — jack out of outdoor ops.',
        severity: InsightSeverity.severe,
      ));
    }
  }

  static void _checkHeavyPrecipitation(
      List<HourlyForecast> hourly, List<DailyForecast> daily, List<TrendInsight> out) {
    // Heavy rain in next 6h
    final next6 = hourly.take(6).toList();
    final heavy = next6.where((h) =>
        h.weatherCode == 65 || h.weatherCode == 67 || h.weatherCode == 82);
    if (heavy.isNotEmpty) {
      out.add(TrendInsight(
        title: '🌧️ HEAVY PRECIP ALERT',
        body: 'Downpour inbound T-${_hoursUntil(heavy.first.time)}h. Flash flood risk in low sectors. Reroute.',
        severity: InsightSeverity.severe,
      ));
      return;
    }
    // Heavy snowfall today/tomorrow
    for (var i = 0; i < 2 && i < daily.length; i++) {
      if (daily[i].snowfallSum >= 10) {
        final when = i == 0 ? 'today' : 'tomorrow';
        out.add(TrendInsight(
          title: '❄️ BLIZZARD WARNING',
          body: '${daily[i].snowfallSum.toStringAsFixed(0)}cm snow dump $when. Road nav offline — stay docked.',
          severity: InsightSeverity.severe,
        ));
        return;
      }
    }
  }

  static void _checkExtremeTemperature(List<DailyForecast> daily, List<TrendInsight> out) {
    final tomorrow = daily.length > 1 ? daily[1] : daily[0];
    if (tomorrow.temperatureMax >= 42) {
      out.add(TrendInsight(
        title: '🔥 THERMAL OVERLOAD',
        body: 'Core temps spike to ${tomorrow.temperatureMax.round()}°C. Coolant reserves critical — minimize exposure.',
        severity: InsightSeverity.severe,
      ));
    } else if (tomorrow.temperatureMin <= -15) {
      out.add(TrendInsight(
        title: '🥶 CRYO-HAZARD ACTIVE',
        body: 'Dropping to ${tomorrow.temperatureMin.round()}°C. Frostbite in <10min — insulate all cyberware.',
        severity: InsightSeverity.severe,
      ));
    }
  }

  static void _checkDangerousWind(
      List<HourlyForecast> hourly, List<DailyForecast> daily, List<TrendInsight> out) {
    // Check hourly gusts first
    final next12 = hourly.take(12).toList();
    final gusty = next12.where((h) => h.windSpeed >= 70);
    if (gusty.isNotEmpty) {
      out.add(TrendInsight(
        title: '💨 GALE_FORCE BREACH',
        body: 'Wind shear ${gusty.first.windSpeed.round()} km/h in ~${_hoursUntil(gusty.first.time)}h. Debris hazard — anchor down.',
        severity: InsightSeverity.severe,
      ));
      return;
    }
    // Check daily
    for (var i = 0; i < 2 && i < daily.length; i++) {
      if (daily[i].windGustsMax >= 80) {
        final when = i == 0 ? 'Today' : 'Tomorrow';
        out.add(TrendInsight(
          title: '💨 WIND ADVISORY',
          body: '$when: gusts to ${daily[i].windGustsMax.round()} km/h. Secure loose hardware, choom.',
          severity: InsightSeverity.warning,
        ));
        return;
      }
    }
  }

  // ─── Temperature Trends ───────────────────────────────────────

  static void _checkWeeklyWarming(List<DailyForecast> daily, List<TrendInsight> out) {
    if (daily.length < 5) return;
    final todayHigh = daily[0].temperatureMax;
    // Check if temps generally rise over 5-7 days
    final laterHighs = daily.skip(3).take(4).map((d) => d.temperatureMax).toList();
    if (laterHighs.isEmpty) return;
    final avgLater = laterHighs.reduce((a, b) => a + b) / laterHighs.length;
    if (avgLater - todayHigh >= 5) {
      final days = daily.length > 7 ? 7 : daily.length;
      out.add(TrendInsight(
        title: '📈 Thermal Uptrend',
        body: 'Heat ramping over ${days}d — ${todayHigh.round()}° → ~${avgLater.round()}°C. Route coolant accordingly.',
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _checkWeeklyCooling(List<DailyForecast> daily, List<TrendInsight> out) {
    if (daily.length < 5) return;
    final todayHigh = daily[0].temperatureMax;
    final laterHighs = daily.skip(3).take(4).map((d) => d.temperatureMax).toList();
    if (laterHighs.isEmpty) return;
    final avgLater = laterHighs.reduce((a, b) => a + b) / laterHighs.length;
    if (todayHigh - avgLater >= 5) {
      out.add(TrendInsight(
        title: '📉 Cold Drift Incoming',
        body: 'Ambient dropping — ${todayHigh.round()}° → ~${avgLater.round()}°C over coming days. Layer up, runner.',
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _check48hTempShift(List<DailyForecast> daily, List<TrendInsight> out) {
    if (daily.length < 3) return;
    final todayHigh = daily[0].temperatureMax;
    final tomorrowHigh = daily[1].temperatureMax;
    final dayTwoHigh = daily[2].temperatureMax;
    final maxUpcoming = _max([tomorrowHigh, dayTwoHigh]);
    final minUpcoming = _min([tomorrowHigh, dayTwoHigh]);

    if (maxUpcoming - todayHigh >= 4) {
      out.add(TrendInsight(
        title: '🌡️ Heat Spike // 48h',
        body: 'Thermals climbing — peaks near ${maxUpcoming.toStringAsFixed(0)}°C. Coolant reserves advised.',
        severity: InsightSeverity.warning,
      ));
    } else if (todayHigh - minUpcoming >= 4) {
      out.add(TrendInsight(
        title: '🌡️ Cold Front Inbound',
        body: 'Temps crashing to ${minUpcoming.toStringAsFixed(0)}°C over 48h. Gear up.',
        severity: InsightSeverity.warning,
      ));
    }
  }

  // ─── Night / Imminent ─────────────────────────────────────────

  static void _checkNightfallDrop(List<HourlyForecast> hourly, List<TrendInsight> out) {
    final next12 = hourly.take(12).toList();
    if (next12.length < 4) return;
    final startTemp = next12.first.temperature;
    final minTemp = next12.map((h) => h.temperature).reduce((a, b) => a < b ? a : b);
    if (startTemp - minTemp >= 5) {
      out.add(TrendInsight(
        title: '🌙 Nightfall Drop',
        body: '~${(startTemp - minTemp).round()}°C thermal bleed in 12h. Boost shielding if heading out after dark.',
        severity: InsightSeverity.info,
      ));
    }
  }

  // ─── Precipitation Intelligence ───────────────────────────────

  static void _checkRainProbabilityRising(List<HourlyForecast> hourly, List<TrendInsight> out) {
    // Look at 6-hour windows: if probability jumps significantly
    if (hourly.length < 6) return;
    final now3 = hourly.take(3).map((h) => h.precipitationProbability).toList();
    final later3 = hourly.skip(3).take(3).map((h) => h.precipitationProbability).toList();
    if (now3.isEmpty || later3.isEmpty) return;
    final avgNow = now3.reduce((a, b) => a + b) / now3.length;
    final avgLater = later3.reduce((a, b) => a + b) / later3.length;
    if (avgLater - avgNow >= 30 && avgLater >= 50) {
      out.add(TrendInsight(
        title: '🌧️ Rain Prob Climbing',
        body: 'Precip vector ${avgNow.round()}% → ${avgLater.round()}% in 3-6h. Waterproof your rig.',
        severity: InsightSeverity.warning,
      ));
    }
    // Also check for imminent rain
    final imminent = hourly.take(6).toList();
    final spike = imminent.where(
      (h) => h.precipitationProbability >= 70 || h.precipitation >= 2 || h.rain >= 2,
    );
    if (spike.isNotEmpty && avgLater - avgNow < 30) {
      out.add(TrendInsight(
        title: '☔ Precip Spike Imminent',
        body: 'Rain ping in ~${_hoursUntil(spike.first.time)}h. Grab a shell, choom.',
        severity: InsightSeverity.warning,
      ));
    }
  }

  static void _checkSnowIncoming(
      List<HourlyForecast> hourly, List<DailyForecast> daily, List<TrendInsight> out) {
    // Check hourly for snow codes
    final next24 = hourly.take(24);
    final snowHours = next24.where((h) =>
        h.weatherCode >= 71 && h.weatherCode <= 77 ||
        h.weatherCode >= 85 && h.weatherCode <= 86);
    if (snowHours.isNotEmpty) {
      final first = snowHours.first;
      out.add(TrendInsight(
        title: '🌨️ Snow Incoming',
        body: 'White-out in ~${_hoursUntil(first.time)}h. Ice on roads — switch to snow tires or stay parked.',
        severity: InsightSeverity.warning,
      ));
    }
  }

  static void _checkDrySpell(List<DailyForecast> daily, List<TrendInsight> out) {
    // Count consecutive dry days
    int dryDays = 0;
    for (final d in daily) {
      if (d.precipitationSum < 0.5 && d.precipitationProbabilityMax < 20) {
        dryDays++;
      } else {
        break;
      }
    }
    if (dryDays >= 5) {
      out.add(TrendInsight(
        title: '☀️ Extended Dry Spell',
        body: 'No precip for $dryDays+ days. Clear skies — prime conditions for outdoor ops.',
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _checkRainEndingSoon(List<HourlyForecast> hourly, List<TrendInsight> out) {
    if (hourly.isEmpty) return;
    // If it's raining now but clears within 3h
    final current = hourly.first;
    if (current.precipitation < 0.5 && current.rain < 0.5) return;
    final next3 = hourly.skip(1).take(3).toList();
    final clearingSoon = next3.every((h) => h.precipitation < 0.3 && h.rain < 0.3);
    if (clearingSoon && next3.isNotEmpty) {
      out.add(TrendInsight(
        title: '🌤️ Rain Clearing',
        body: 'Downpour tapering in 2-3h. Window opening — plan your move.',
        severity: InsightSeverity.info,
      ));
    }
  }

  // ─── UV & Air Quality ─────────────────────────────────────────

  static void _checkUvExtreme(List<DailyForecast> daily, List<TrendInsight> out) {
    if (daily.length < 2) return;
    final tomorrow = daily[1];
    if (tomorrow.uvIndexMax >= 8) {
      out.add(TrendInsight(
        title: '☀️ UV Spike Tomorrow',
        body: 'UV index ${tomorrow.uvIndexMax.toStringAsFixed(0)} — dermal damage in minutes. Sunscreen mandatory.',
        severity: tomorrow.uvIndexMax >= 11
            ? InsightSeverity.severe
            : InsightSeverity.warning,
      ));
    }
  }

  static void _checkAirQuality(WeatherData data, List<TrendInsight> out) {
    final aqi = data.airQuality;
    if (aqi == null) return;
    if (aqi.usAqi > 150) {
      out.add(TrendInsight(
        title: '😷 Toxic Air // AQI ${aqi.usAqi}',
        body: '${aqi.category.label}. Seal respirator — limit all outdoor exposure.',
        severity: InsightSeverity.severe,
      ));
    } else if (aqi.usAqi > 100) {
      out.add(TrendInsight(
        title: '🌫️ Air Degraded // AQI ${aqi.usAqi}',
        body: 'Particles elevated. Sensitive ops should mask up and reduce exertion.',
        severity: InsightSeverity.warning,
      ));
    }
  }

  // ─── Atmospheric ──────────────────────────────────────────────

  static void _checkWindPickingUp(List<HourlyForecast> hourly, List<TrendInsight> out) {
    if (hourly.length < 6) return;
    final nowWind = hourly.first.windSpeed;
    final later = hourly.skip(3).take(3).map((h) => h.windSpeed).toList();
    if (later.isEmpty) return;
    final avgLater = later.reduce((a, b) => a + b) / later.length;
    if (avgLater - nowWind >= 15 && avgLater >= 25) {
      out.add(TrendInsight(
        title: '💨 Wind Ramp-Up',
        body: 'Gust vector ${nowWind.round()} → ~${avgLater.round()} km/h. Brace for turbulence.',
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _checkFogRisk(List<HourlyForecast> hourly, List<TrendInsight> out) {
    final next12 = hourly.take(12);
    final foggy = next12.where((h) => h.weatherCode == 45 || h.weatherCode == 48);
    if (foggy.isNotEmpty) {
      out.add(TrendInsight(
        title: '🌫️ Fog Advisory',
        body: 'Visibility tanking in ~${_hoursUntil(foggy.first.time)}h. Switch to enhanced optics if driving.',
        severity: InsightSeverity.warning,
      ));
    }
  }

  static void _checkBigTempSwing(List<DailyForecast> daily, List<TrendInsight> out) {
    if (daily.isEmpty) return;
    final today = daily[0];
    final swing = today.temperatureMax - today.temperatureMin;
    if (swing >= 18) {
      out.add(TrendInsight(
        title: '🌡️ Temp Swing // ${swing.round()}°',
        body: 'Range today: ${today.temperatureMin.round()}° → ${today.temperatureMax.round()}°C. Layer protocol recommended.',
        severity: InsightSeverity.info,
      ));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────

  static double _max(Iterable<double> values) => values.reduce((a, b) => a > b ? a : b);
  static double _min(Iterable<double> values) => values.reduce((a, b) => a < b ? a : b);

  static int _hoursUntil(DateTime time) {
    final diff = time.difference(DateTime.now()).inHours;
    return diff < 1 ? 1 : diff;
  }
}
