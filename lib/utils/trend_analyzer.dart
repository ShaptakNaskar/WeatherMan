import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/weather_utils.dart';

/// Severity of a weather insight
enum InsightSeverity { info, warning, severe }

/// Text style for themed insight messages
enum InsightTextStyle { cyber, kawaii, neutral }

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
  static TrendInsight? detect(WeatherData data, [InsightTextStyle style = InsightTextStyle.neutral]) {
    final all = detectAll(data, style);
    return all.isNotEmpty ? all.first : null;
  }

  /// Return ALL applicable insights, sorted severe → info.
  static List<TrendInsight> detectAll(WeatherData data, [InsightTextStyle style = InsightTextStyle.neutral]) {
    final insights = <TrendInsight>[];
    final daily = data.daily;
    final hourly = data.hourly;
    if (daily.length < 2 || hourly.isEmpty) return insights;

    // ── Severe weather alerts (highest priority) ──
    _checkThunderstorms(hourly, insights, style);
    _checkHeavyPrecipitation(hourly, daily, insights, style);
    _checkExtremeTemperature(daily, insights, style);
    _checkDangerousWind(hourly, daily, insights, style);

    // ── Multi-day temperature trends ──
    _checkWeeklyWarming(daily, insights, style);
    _checkWeeklyCooling(daily, insights, style);
    _check48hTempShift(daily, insights, style);

    // ── Overnight / imminent changes ──
    _checkNightfallDrop(hourly, insights, style);

    // ── Precipitation intelligence ──
    _checkRainProbabilityRising(hourly, insights, style);
    _checkSnowIncoming(hourly, daily, insights, style);
    _checkDrySpell(daily, insights, style);
    _checkRainEndingSoon(hourly, insights, style);

    // ── UV & Air Quality ──
    _checkUvExtreme(daily, insights, style);
    _checkAirQuality(data, insights, style);

    // ── Atmospheric ──
    _checkWindPickingUp(hourly, insights, style);
    _checkFogRisk(hourly, insights, style);
    _checkBigTempSwing(daily, insights, style);

    // Sort: severe first, then warning, then info
    insights.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return insights;
  }

  // ─── Text helper ──────────────────────────────────────────────

  static String _t(InsightTextStyle s, String cyber, String kawaii, String neutral) =>
      switch (s) {
        InsightTextStyle.cyber => cyber,
        InsightTextStyle.kawaii => kawaii,
        InsightTextStyle.neutral => neutral,
      };

  // ─── Severe Weather ───────────────────────────────────────────

  static void _checkThunderstorms(List<HourlyForecast> hourly, List<TrendInsight> out, InsightTextStyle s) {
    final next12 = hourly.take(12).toList();
    final storm = next12.where((h) => h.weatherCode >= 95);
    if (storm.isNotEmpty) {
      final first = storm.first;
      final h = _hoursUntil(first.time);
      final desc = WeatherUtils.getWeatherDescription(first.weatherCode);
      out.add(TrendInsight(
        title: _t(s,
          '⚡ STORM_FRONT DETECTED',
          '⚡ Eek, storm incoming!',
          '⚡ Storm Approaching',
        ),
        body: _t(s,
          '$desc ETA ~${h}h. EM interference imminent — jack out of outdoor ops.',
          '$desc expected in ~${h}h. Please stay safe indoors!',
          '$desc expected in approximately $h hours. Consider staying indoors.',
        ),
        severity: InsightSeverity.severe,
      ));
    }
  }

  static void _checkHeavyPrecipitation(
      List<HourlyForecast> hourly, List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    final next6 = hourly.take(6).toList();
    final heavy = next6.where((h) =>
        h.weatherCode == 65 || h.weatherCode == 67 || h.weatherCode == 82);
    if (heavy.isNotEmpty) {
      final h = _hoursUntil(heavy.first.time);
      out.add(TrendInsight(
        title: _t(s,
          '🌧️ HEAVY PRECIP ALERT',
          '🌧️ Big rain coming!',
          '🌧️ Heavy Rain Alert',
        ),
        body: _t(s,
          'Downpour inbound T-${h}h. Flash flood risk in low sectors. Reroute.',
          'Heavy rain in about ${h}h. Flash flood risk — stay somewhere safe!',
          'Heavy rainfall expected in $h hours. Watch for potential flooding.',
        ),
        severity: InsightSeverity.severe,
      ));
      return;
    }
    for (var i = 0; i < 2 && i < daily.length; i++) {
      if (daily[i].snowfallSum >= 10) {
        final when = i == 0 ? 'today' : 'tomorrow';
        final cm = daily[i].snowfallSum.toStringAsFixed(0);
        out.add(TrendInsight(
          title: _t(s,
            '❄️ BLIZZARD WARNING',
            '❄️ Snowstorm alert!',
            '❄️ Blizzard Warning',
          ),
          body: _t(s,
            '${cm}cm snow dump $when. Road nav offline — stay docked.',
            '${cm}cm of snow expected $when. Roads will be tricky — stay cozy inside!',
            '${cm}cm of snowfall expected $when. Travel not recommended.',
          ),
          severity: InsightSeverity.severe,
        ));
        return;
      }
    }
  }

  static void _checkExtremeTemperature(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    final tomorrow = daily.length > 1 ? daily[1] : daily[0];
    if (tomorrow.temperatureMax >= 42) {
      final t = tomorrow.temperatureMax.round();
      out.add(TrendInsight(
        title: _t(s,
          '🔥 THERMAL OVERLOAD',
          '🔥 Way too hot!',
          '🔥 Extreme Heat',
        ),
        body: _t(s,
          'Core temps spike to $t°C. Coolant reserves critical — minimize exposure.',
          'Temperature reaching $t°C! Stay hydrated and find some shade!',
          'Temperature expected to reach $t°C. Minimize sun exposure and stay hydrated.',
        ),
        severity: InsightSeverity.severe,
      ));
    } else if (tomorrow.temperatureMin <= -15) {
      final t = tomorrow.temperatureMin.round();
      out.add(TrendInsight(
        title: _t(s,
          '🥶 CRYO-HAZARD ACTIVE',
          '🥶 Brrr, so cold!',
          '🥶 Extreme Cold',
        ),
        body: _t(s,
          'Dropping to $t°C. Frostbite in <10min — insulate all cyberware.',
          'Dropping to $t°C — frostbite risk! Bundle up extra warm!',
          'Temperature dropping to $t°C. Frostbite risk — dress warmly and limit exposure.',
        ),
        severity: InsightSeverity.severe,
      ));
    }
  }

  static void _checkDangerousWind(
      List<HourlyForecast> hourly, List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    final next12 = hourly.take(12).toList();
    final gusty = next12.where((h) => h.windSpeed >= 70);
    if (gusty.isNotEmpty) {
      final w = gusty.first.windSpeed.round();
      final h = _hoursUntil(gusty.first.time);
      out.add(TrendInsight(
        title: _t(s,
          '💨 GALE_FORCE BREACH',
          '💨 Super windy!',
          '💨 Dangerous Winds',
        ),
        body: _t(s,
          'Wind shear $w km/h in ~${h}h. Debris hazard — anchor down.',
          'Winds up to $w km/h in ~${h}h. Hold onto your hat!',
          'Wind gusts of $w km/h expected in ~$h hours. Secure loose items.',
        ),
        severity: InsightSeverity.severe,
      ));
      return;
    }
    for (var i = 0; i < 2 && i < daily.length; i++) {
      if (daily[i].windGustsMax >= 80) {
        final when = i == 0 ? 'Today' : 'Tomorrow';
        final w = daily[i].windGustsMax.round();
        out.add(TrendInsight(
          title: _t(s,
            '💨 WIND ADVISORY',
            '💨 Windy day ahead!',
            '💨 Wind Advisory',
          ),
          body: _t(s,
            '$when: gusts to $w km/h. Secure loose hardware, choom.',
            '$when: gusts up to $w km/h. Be careful out there!',
            '$when: gusts up to $w km/h. Secure outdoor items.',
          ),
          severity: InsightSeverity.warning,
        ));
        return;
      }
    }
  }

  // ─── Temperature Trends ───────────────────────────────────────

  static void _checkWeeklyWarming(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    if (daily.length < 5) return;
    final todayHigh = daily[0].temperatureMax;
    final laterHighs = daily.skip(3).take(4).map((d) => d.temperatureMax).toList();
    if (laterHighs.isEmpty) return;
    final avgLater = laterHighs.reduce((a, b) => a + b) / laterHighs.length;
    if (avgLater - todayHigh >= 5) {
      final days = daily.length > 7 ? 7 : daily.length;
      out.add(TrendInsight(
        title: _t(s,
          '📈 Thermal Uptrend',
          '📈 Getting warmer!',
          '📈 Warming Trend',
        ),
        body: _t(s,
          'Heat ramping over ${days}d — ${todayHigh.round()}° → ~${avgLater.round()}°C. Route coolant accordingly.',
          'Temps climbing over $days days — ${todayHigh.round()}° → ~${avgLater.round()}°C. Time for lighter clothes!',
          'Temperatures rising over $days days from ${todayHigh.round()}° to ~${avgLater.round()}°C.',
        ),
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _checkWeeklyCooling(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    if (daily.length < 5) return;
    final todayHigh = daily[0].temperatureMax;
    final laterHighs = daily.skip(3).take(4).map((d) => d.temperatureMax).toList();
    if (laterHighs.isEmpty) return;
    final avgLater = laterHighs.reduce((a, b) => a + b) / laterHighs.length;
    if (todayHigh - avgLater >= 5) {
      out.add(TrendInsight(
        title: _t(s,
          '📉 Cold Drift Incoming',
          '📉 Getting chillier!',
          '📉 Cooling Trend',
        ),
        body: _t(s,
          'Ambient dropping — ${todayHigh.round()}° → ~${avgLater.round()}°C over coming days. Layer up, runner.',
          'Cooling down from ${todayHigh.round()}° to ~${avgLater.round()}°C over the next few days. Layer up!',
          'Temperatures dropping from ${todayHigh.round()}° to ~${avgLater.round()}°C over the coming days.',
        ),
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _check48hTempShift(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    if (daily.length < 3) return;
    final todayHigh = daily[0].temperatureMax;
    final tomorrowHigh = daily[1].temperatureMax;
    final dayTwoHigh = daily[2].temperatureMax;
    final maxUpcoming = _max([tomorrowHigh, dayTwoHigh]);
    final minUpcoming = _min([tomorrowHigh, dayTwoHigh]);

    if (maxUpcoming - todayHigh >= 4) {
      out.add(TrendInsight(
        title: _t(s,
          '🌡️ Heat Spike // 48h',
          '🌡️ Heat wave coming!',
          '🌡️ Temperature Rising',
        ),
        body: _t(s,
          'Thermals climbing — peaks near ${maxUpcoming.toStringAsFixed(0)}°C. Coolant reserves advised.',
          'Temperatures rising — peaks near ${maxUpcoming.toStringAsFixed(0)}°C soon. Stay cool!',
          'Temperatures expected to peak near ${maxUpcoming.toStringAsFixed(0)}°C in the next 48 hours.',
        ),
        severity: InsightSeverity.warning,
      ));
    } else if (todayHigh - minUpcoming >= 4) {
      out.add(TrendInsight(
        title: _t(s,
          '🌡️ Cold Front Inbound',
          '🌡️ Cold snap ahead!',
          '🌡️ Cold Front Coming',
        ),
        body: _t(s,
          'Temps crashing to ${minUpcoming.toStringAsFixed(0)}°C over 48h. Gear up.',
          'Temps dropping to ${minUpcoming.toStringAsFixed(0)}°C in the next couple days. Dress warmly!',
          'Temperatures dropping to ${minUpcoming.toStringAsFixed(0)}°C over the next 48 hours.',
        ),
        severity: InsightSeverity.warning,
      ));
    }
  }

  // ─── Night / Imminent ─────────────────────────────────────────

  static void _checkNightfallDrop(List<HourlyForecast> hourly, List<TrendInsight> out, InsightTextStyle s) {
    final next12 = hourly.take(12).toList();
    if (next12.length < 4) return;
    final startTemp = next12.first.temperature;
    final minTemp = next12.map((h) => h.temperature).reduce((a, b) => a < b ? a : b);
    if (startTemp - minTemp >= 5) {
      final drop = (startTemp - minTemp).round();
      out.add(TrendInsight(
        title: _t(s,
          '🌙 Nightfall Drop',
          '🌙 Chilly evening ahead!',
          '🌙 Evening Cooldown',
        ),
        body: _t(s,
          '~$drop°C thermal bleed in 12h. Boost shielding if heading out after dark.',
          'It\'ll drop ~$drop°C tonight. Bring a jacket if going out later!',
          'Temperature will drop ~$drop°C over the next 12 hours. Dress accordingly for evening.',
        ),
        severity: InsightSeverity.info,
      ));
    }
  }

  // ─── Precipitation Intelligence ───────────────────────────────

  static void _checkRainProbabilityRising(List<HourlyForecast> hourly, List<TrendInsight> out, InsightTextStyle s) {
    if (hourly.length < 6) return;
    final now3 = hourly.take(3).map((h) => h.precipitationProbability).toList();
    final later3 = hourly.skip(3).take(3).map((h) => h.precipitationProbability).toList();
    if (now3.isEmpty || later3.isEmpty) return;
    final avgNow = now3.reduce((a, b) => a + b) / now3.length;
    final avgLater = later3.reduce((a, b) => a + b) / later3.length;
    if (avgLater - avgNow >= 30 && avgLater >= 50) {
      out.add(TrendInsight(
        title: _t(s,
          '🌧️ Rain Prob Climbing',
          '🌧️ Rain chance rising!',
          '🌧️ Increasing Rain Chance',
        ),
        body: _t(s,
          'Precip vector ${avgNow.round()}% → ${avgLater.round()}% in 3-6h. Waterproof your rig.',
          'Rain probability going from ${avgNow.round()}% to ${avgLater.round()}% in 3-6h. Grab an umbrella!',
          'Rain probability rising from ${avgNow.round()}% to ${avgLater.round()}% over the next 3-6 hours.',
        ),
        severity: InsightSeverity.warning,
      ));
    }
    // Also check for imminent rain
    final imminent = hourly.take(6).toList();
    final spike = imminent.where(
      (h) => h.precipitationProbability >= 70 || h.precipitation >= 2 || h.rain >= 2,
    );
    if (spike.isNotEmpty && avgLater - avgNow < 30) {
      final h = _hoursUntil(spike.first.time);
      out.add(TrendInsight(
        title: _t(s,
          '☔ Precip Spike Imminent',
          '☔ Rain coming soon!',
          '☔ Rain Expected Soon',
        ),
        body: _t(s,
          'Rain ping in ~${h}h. Grab a shell, choom.',
          'Showers expected in ~${h}h. Don\'t forget your umbrella!',
          'Precipitation likely within ~$h hours. Bring rain gear.',
        ),
        severity: InsightSeverity.warning,
      ));
    }
  }

  static void _checkSnowIncoming(
      List<HourlyForecast> hourly, List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    final next24 = hourly.take(24);
    final snowHours = next24.where((h) =>
        h.weatherCode >= 71 && h.weatherCode <= 77 ||
        h.weatherCode >= 85 && h.weatherCode <= 86);
    if (snowHours.isNotEmpty) {
      final first = snowHours.first;
      final h = _hoursUntil(first.time);
      out.add(TrendInsight(
        title: _t(s,
          '🌨️ Snow Incoming',
          '🌨️ Snow is coming!',
          '🌨️ Snowfall Expected',
        ),
        body: _t(s,
          'White-out in ~${h}h. Ice on roads — switch to snow tires or stay parked.',
          'Snowfall starting in ~${h}h. Roads may be icy — be extra careful!',
          'Snow expected in approximately $h hours. Roads may become hazardous.',
        ),
        severity: InsightSeverity.warning,
      ));
    }
  }

  static void _checkDrySpell(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
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
        title: _t(s,
          '☀️ Extended Dry Spell',
          '☀️ Sunny days ahead!',
          '☀️ Extended Dry Period',
        ),
        body: _t(s,
          'No precip for $dryDays+ days. Clear skies — prime conditions for outdoor ops.',
          'No rain for $dryDays+ days! Perfect for outdoor adventures!',
          'No precipitation expected for $dryDays+ days. Good conditions for outdoor activities.',
        ),
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _checkRainEndingSoon(List<HourlyForecast> hourly, List<TrendInsight> out, InsightTextStyle s) {
    if (hourly.isEmpty) return;
    final current = hourly.first;
    if (current.precipitation < 0.5 && current.rain < 0.5) return;
    final next3 = hourly.skip(1).take(3).toList();
    final clearingSoon = next3.every((h) => h.precipitation < 0.3 && h.rain < 0.3);
    if (clearingSoon && next3.isNotEmpty) {
      out.add(TrendInsight(
        title: _t(s,
          '🌤️ Rain Clearing',
          '🌤️ Rain stopping soon!',
          '🌤️ Rain Easing',
        ),
        body: _t(s,
          'Downpour tapering in 2-3h. Window opening — plan your move.',
          'The rain should ease up in 2-3h. Hang in there!',
          'Current rainfall expected to taper off within 2-3 hours.',
        ),
        severity: InsightSeverity.info,
      ));
    }
  }

  // ─── UV & Air Quality ─────────────────────────────────────────

  static void _checkUvExtreme(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    if (daily.length < 2) return;
    final tomorrow = daily[1];
    if (tomorrow.uvIndexMax >= 8) {
      final uv = tomorrow.uvIndexMax.toStringAsFixed(0);
      out.add(TrendInsight(
        title: _t(s,
          '☀️ UV Spike Tomorrow',
          '☀️ Strong sun tomorrow!',
          '☀️ High UV Tomorrow',
        ),
        body: _t(s,
          'UV index $uv — dermal damage in minutes. Sunscreen mandatory.',
          'UV index $uv — sunburn risk! Don\'t forget sunscreen!',
          'UV index $uv expected. Apply sunscreen and wear protective clothing.',
        ),
        severity: tomorrow.uvIndexMax >= 11
            ? InsightSeverity.severe
            : InsightSeverity.warning,
      ));
    }
  }

  static void _checkAirQuality(WeatherData data, List<TrendInsight> out, InsightTextStyle s) {
    final aqi = data.airQuality;
    if (aqi == null) return;
    if (aqi.usAqi > 150) {
      out.add(TrendInsight(
        title: _t(s,
          '😷 Toxic Air // AQI ${aqi.usAqi}',
          '😷 Unhealthy air!',
          '😷 Poor Air Quality',
        ),
        body: _t(s,
          '${aqi.category.label}. Seal respirator — limit all outdoor exposure.',
          '${aqi.category.label} (AQI ${aqi.usAqi}). Please wear a mask outdoors!',
          '${aqi.category.label} (AQI ${aqi.usAqi}). Limit outdoor exposure, especially for sensitive groups.',
        ),
        severity: InsightSeverity.severe,
      ));
    } else if (aqi.usAqi > 100) {
      out.add(TrendInsight(
        title: _t(s,
          '🌫️ Air Degraded // AQI ${aqi.usAqi}',
          '🌫️ Air quality notice',
          '🌫️ Moderate Air Quality',
        ),
        body: _t(s,
          'Particles elevated. Sensitive ops should mask up and reduce exertion.',
          'AQI is ${aqi.usAqi} — sensitive people should consider wearing a mask outside.',
          'AQI is ${aqi.usAqi}. Sensitive individuals should limit prolonged outdoor activity.',
        ),
        severity: InsightSeverity.warning,
      ));
    }
  }

  // ─── Atmospheric ──────────────────────────────────────────────

  static void _checkWindPickingUp(List<HourlyForecast> hourly, List<TrendInsight> out, InsightTextStyle s) {
    if (hourly.length < 6) return;
    final nowWind = hourly.first.windSpeed;
    final later = hourly.skip(3).take(3).map((h) => h.windSpeed).toList();
    if (later.isEmpty) return;
    final avgLater = later.reduce((a, b) => a + b) / later.length;
    if (avgLater - nowWind >= 15 && avgLater >= 25) {
      out.add(TrendInsight(
        title: _t(s,
          '💨 Wind Ramp-Up',
          '💨 Wind picking up!',
          '💨 Increasing Winds',
        ),
        body: _t(s,
          'Gust vector ${nowWind.round()} → ~${avgLater.round()} km/h. Brace for turbulence.',
          'Winds increasing from ${nowWind.round()} to ~${avgLater.round()} km/h. Hold on tight!',
          'Wind speeds rising from ${nowWind.round()} to ~${avgLater.round()} km/h.',
        ),
        severity: InsightSeverity.info,
      ));
    }
  }

  static void _checkFogRisk(List<HourlyForecast> hourly, List<TrendInsight> out, InsightTextStyle s) {
    final next12 = hourly.take(12);
    final foggy = next12.where((h) => h.weatherCode == 45 || h.weatherCode == 48);
    if (foggy.isNotEmpty) {
      final h = _hoursUntil(foggy.first.time);
      out.add(TrendInsight(
        title: _t(s,
          '🌫️ Fog Advisory',
          '🌫️ Foggy soon!',
          '🌫️ Fog Advisory',
        ),
        body: _t(s,
          'Visibility tanking in ~${h}h. Switch to enhanced optics if driving.',
          'Fog expected in ~${h}h. Drive carefully and use your headlights!',
          'Reduced visibility expected in ~$h hours. Use headlights and drive slowly.',
        ),
        severity: InsightSeverity.warning,
      ));
    }
  }

  static void _checkBigTempSwing(List<DailyForecast> daily, List<TrendInsight> out, InsightTextStyle s) {
    if (daily.isEmpty) return;
    final today = daily[0];
    final swing = today.temperatureMax - today.temperatureMin;
    if (swing >= 18) {
      out.add(TrendInsight(
        title: _t(s,
          '🌡️ Temp Swing // ${swing.round()}°',
          '🌡️ Big temp change today!',
          '🌡️ Large Temperature Range',
        ),
        body: _t(s,
          'Range today: ${today.temperatureMin.round()}° → ${today.temperatureMax.round()}°C. Layer protocol recommended.',
          'Today goes from ${today.temperatureMin.round()}° to ${today.temperatureMax.round()}°C — that\'s a ${swing.round()}° swing! Layer up!',
          'Today\'s range: ${today.temperatureMin.round()}° to ${today.temperatureMax.round()}°C (${swing.round()}° swing). Dress in layers.',
        ),
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
