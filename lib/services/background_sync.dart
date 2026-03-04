import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/services/notification_service.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:weatherman/services/weather_service.dart';
import 'package:weatherman/services/widget_service.dart';
import 'package:weatherman/utils/trend_analyzer.dart';

/// Background sync + notifications driven by WorkManager
class BackgroundSync {
  static const String taskName = 'weather_sync';

  /// Register the periodic worker (every ~2 hours for fresher data)
  static Future<void> register() async {
    await Workmanager().cancelByUniqueName(taskName);
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 2),
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

      // 1. Severe weather alerts (always check, highest priority)
      await _maybeSendSevereAlerts(weather, storage, notifier);

      // 2. Daily briefings (morning & evening)
      await _maybeSendBriefings(weather, storage, notifier);

      // 3. Smart trend insights
      await _maybeSendInsights(weather, storage, notifier);

      // 4. Update persistent notification
      final persistentOn = await storage.getPersistentNotificationEnabled();
      if (persistentOn) {
        await notifier.showPersistent(weather);
      }

      // 5. Update home screen widget
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

/// Check for severe weather conditions and alert immediately
Future<void> _maybeSendSevereAlerts(
  WeatherData weather,
  StorageService storage,
  NotificationService notifier,
) async {
  final severeOn = await storage.getSevereAlertsEnabled();
  if (!severeOn) return;

  final insights = TrendAnalyzer.detectAll(weather);
  final severe = insights.where((i) => i.severity == InsightSeverity.severe).toList();
  if (severe.isEmpty) return;

  // Deduplicate: only send if the severe alerts changed
  final hash = severe.map((s) => '${s.title}:${s.body}').join('|');
  final lastHash = await storage.getLastSevereHash();
  if (lastHash == hash) return;

  for (final alert in severe) {
    await notifier.showSevereAlert(alert);
  }
  await storage.setLastSevereHash(hash);
}

/// Send morning / evening briefings at appropriate times
Future<void> _maybeSendBriefings(
  WeatherData weather,
  StorageService storage,
  NotificationService notifier,
) async {
  final now = DateTime.now();
  final lastMorning = await storage.getLastMorningPush();
  final lastEvening = await storage.getLastEveningPush();

  // Morning briefing (5 AM – 10 AM)
  final morningOn = await storage.getMorningBriefingEnabled();
  if (morningOn && now.hour >= 5 && now.hour <= 10 && !_sameDay(lastMorning, now)) {
    await notifier.showMorningBriefing(weather);
    await storage.setLastMorningPush(now);
  }

  // Evening outlook (2 PM – 6 PM)
  final eveningOn = await storage.getEveningOutlookEnabled();
  if (eveningOn && now.hour >= 14 && now.hour <= 18 && !_sameDay(lastEvening, now)) {
    await notifier.showEveningOutlook(weather);
    await storage.setLastEveningPush(now);
  }
}

/// Send smart weather insights (trends, probability changes, etc.)
Future<void> _maybeSendInsights(
  WeatherData weather,
  StorageService storage,
  NotificationService notifier,
) async {
  final trendOn = await storage.getTrendInsightsEnabled();
  if (!trendOn) return;

  final insights = TrendAnalyzer.detectAll(weather);
  // Pick the top non-severe insight (severe is already handled)
  final nonSevere = insights.where((i) => i.severity != InsightSeverity.severe).toList();
  if (nonSevere.isEmpty) return;

  // Only send the top one to avoid spamming
  final insight = nonSevere.first;
  final hash = '${insight.title}:${insight.body}';
  final last = await storage.getLastTrendHash();
  if (last == hash) return;

  await notifier.showInsight(insight);
  await storage.setLastTrendHash(hash);
}

bool _sameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
