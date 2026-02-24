import 'package:weatherman/models/weather.dart';

/// Represents a concise trend message for notifications/widgets
class TrendInsight {
  final String title;
  final String body;

  const TrendInsight({required this.title, required this.body});
}

class TrendAnalyzer {
  /// Inspect forecast and extract a noteworthy shift (warming, cooling, rain spike)
  static TrendInsight? detect(WeatherData data) {
    final daily = data.daily;
    if (daily.length < 2) return null;

    // Temperature trend over next 2 days
    final todayHigh = daily[0].temperatureMax;
    final tomorrowHigh = daily[1].temperatureMax;
    final dayTwoHigh = daily.length > 2 ? daily[2].temperatureMax : tomorrowHigh;
    final maxUpcomingHigh = _max([tomorrowHigh, dayTwoHigh]);
    final minUpcomingHigh = _min([tomorrowHigh, dayTwoHigh]);

    if (maxUpcomingHigh - todayHigh >= 4) {
      final peak = maxUpcomingHigh.toStringAsFixed(1);
      return TrendInsight(
        title: 'Heat Drift Detected',
        body: 'Temps climbing next 48h — peaks near $peak°C. Route coolant.',
      );
    }

    if (todayHigh - minUpcomingHigh >= 4) {
      final drop = minUpcomingHigh.toStringAsFixed(1);
      return TrendInsight(
        title: 'Cold Front Inbound',
        body: 'Temps dropping over 48h — highs near $drop°C. Layer up.',
      );
    }

    // Sudden drop tonight (next 12 hours)
    final hourly = data.hourly.take(12).toList();
    if (hourly.length >= 4) {
      final startTemp = hourly.first.temperature;
      final minTemp = hourly
          .map((h) => h.temperature)
          .reduce((a, b) => a < b ? a : b);
      if (startTemp - minTemp >= 5) {
        return TrendInsight(
          title: 'Nightfall Drop',
          body: 'Temp falls ~${(startTemp - minTemp).round()}°C in 12h. Boost thermal shielding.',
        );
      }
    }

    // Rain probability spike in next 6 hours
    final imminent = data.hourly.take(6).toList();
    final rainSpike = imminent.firstWhere(
      (h) => h.precipitationProbability >= 70 || h.precipitation >= 2 || h.rain >= 2,
      orElse: () => HourlyForecast(
        time: DateTime.now(),
        temperature: 0,
        weatherCode: 0,
        precipitationProbability: 0,
        isDay: true,
      ),
    );
    if (rainSpike.precipitationProbability >= 70 || rainSpike.precipitation >= 2 || rainSpike.rain >= 2) {
      return TrendInsight(
        title: 'Precip Spike',
        body: 'High chance in ${_hoursUntil(rainSpike.time)}h. Grab a shell.',
      );
    }

    return null;
  }

  static double _max(Iterable<double> values) => values.reduce((a, b) => a > b ? a : b);
  static double _min(Iterable<double> values) => values.reduce((a, b) => a < b ? a : b);

  static int _hoursUntil(DateTime time) {
    final diff = time.difference(DateTime.now()).inHours;
    return diff < 0 ? 0 : diff;
  }
}
