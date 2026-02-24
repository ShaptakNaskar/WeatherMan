import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:weatherman/services/weather_service.dart';
import 'package:weatherman/services/widget_service.dart';
import 'package:weatherman/utils/trend_analyzer.dart';
import 'package:weatherman/utils/weather_utils.dart';

/// Background sync + notifications driven by WorkManager
class BackgroundSync {
  static const String taskName = 'weather_sync';

  /// Register the periodic worker (every ~3 hours)
  static Future<void> register() async {
    await Workmanager().cancelByUniqueName(taskName);
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 3),
      initialDelay: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }
}

/// Entry point invoked by WorkManager in the background isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final storage = StorageService();
    final weatherService = WeatherService();
    final notifier = NotificationService.instance;

    try {
      final location = await storage.getLastLocation();
      if (location == null) return true;

      final weather = await weatherService.fetchWeather(location);
      await storage.cacheWeather(weather);

      await _maybeSendBriefings(weather, storage, notifier);
      await _maybeSendTrend(weather, storage, notifier);
      await WidgetService.update(weather);
    } catch (_) {
      // Best-effort; failures are ignored to keep worker alive
      return true;
    } finally {
      weatherService.dispose();
    }

    return true;
  });
}

Future<void> _maybeSendBriefings(
  WeatherData weather,
  StorageService storage,
  NotificationService notifier,
) async {
  final now = DateTime.now();
  final lastMorning = await storage.getLastMorningPush();
  final lastEvening = await storage.getLastEveningPush();

  if (now.hour >= 5 && now.hour <= 10 && !_sameDay(lastMorning, now)) {
    final message = _buildMorningMessage(weather);
    await notifier.showNow(title: 'Morning Briefing', body: message);
    await storage.setLastMorningPush(now);
  }

  if (now.hour >= 14 && now.hour <= 18 && !_sameDay(lastEvening, now)) {
    final message = _buildEveningMessage(weather);
    await notifier.showNow(title: 'Evening Outlook', body: message);
    await storage.setLastEveningPush(now);
  }
}

Future<void> _maybeSendTrend(
  WeatherData weather,
  StorageService storage,
  NotificationService notifier,
) async {
  final insight = TrendAnalyzer.detect(weather);
  if (insight == null) return;

  final hash = '${insight.title}:${insight.body}';
  final last = await storage.getLastTrendHash();
  if (last == hash) return;

  await notifier.showNow(title: insight.title, body: insight.body);
  await storage.setLastTrendHash(hash);
}

String _buildMorningMessage(WeatherData weather) {
  final hourly = weather.hourly;
  if (hourly.isEmpty || weather.daily.isEmpty) {
    return 'Forecast uplink syncing...';
  }
  final nextRain = hourly.firstWhere(
    (h) => h.precipitationProbability >= 50 || h.rain >= 1 || h.precipitation >= 1,
    orElse: () => hourly.first,
  );
  if (nextRain != hourly.first) {
    final hour = nextRain.time.hour.toString().padLeft(2, '0');
    return 'Morning Briefing // Rain ping near $hour:00. High ${weather.daily.first.temperatureMax.toStringAsFixed(0)}°C. Charge the implants.';
  }
  return 'Morning Briefing // Clear start. High ${weather.daily.first.temperatureMax.toStringAsFixed(0)}°C / Low ${weather.daily.first.temperatureMin.toStringAsFixed(0)}°C. Keep optics polished.';
}

String _buildEveningMessage(WeatherData weather) {
  if (weather.daily.length < 2 || weather.hourly.isEmpty) {
    return 'Evening uplink offline; retrying soon.';
  }
  final tomorrow = weather.daily[1];
  final desc = WeatherUtils.getWeatherDescription(tomorrow.weatherCode);
  return 'Evening Uplink // Now ~${weather.hourly.first.temperature.toStringAsFixed(0)}°C. Tomorrow: $desc, ${tomorrow.temperatureMin.toStringAsFixed(0)}–${tomorrow.temperatureMax.toStringAsFixed(0)}°C. Prep your run.';
}

bool _sameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
