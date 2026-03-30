import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:weatherman/config/app_theme_data.dart';
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/services/storage_service.dart';
import 'package:weatherman/utils/weather_utils.dart';
import 'package:weatherman/utils/trend_analyzer.dart';

/// Handles local notification setup and delivery
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Channel IDs ──────────────────────────────────────────────
  static const String _channelBriefing = 'weather_briefings';
  static const String _channelSevere = 'weather_severe';
  static const String _channelInsights = 'weather_insights';
  static const String _channelPersistent = 'weather_persistent';

  // ── Notification IDs ─────────────────────────────────────────
  static const int _idPersistent = 9999;
  static const int _idMorning = 1001;
  static const int _idEvening = 1002;
  // Severe & insight IDs are dynamic via _nextId()

  /// Initialize notification plugin and request permission if needed
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_weather',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      // Daily briefings (morning / evening)
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelBriefing,
          'Daily Briefings',
          description: 'Morning and evening weather briefings',
          importance: Importance.high,
          enableLights: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
      // Severe weather alerts (max priority)
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelSevere,
          'Severe Weather Alerts',
          description:
              'Thunderstorms, extreme heat/cold, heavy rain/snow, high winds',
          importance: Importance.max,
          enableLights: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
      // Smart insights & trends
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelInsights,
          'Weather Insights',
          description:
              'Temperature trends, rain probability changes, UV alerts',
          importance: Importance.defaultImportance,
          enableLights: true,
          enableVibration: false,
          showBadge: true,
        ),
      );
      // Persistent status (low priority, ongoing)
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelPersistent,
          'Current Weather Status',
          description: 'Ongoing notification showing live weather conditions',
          importance: Importance.low,
          enableLights: false,
          enableVibration: false,
          showBadge: false,
        ),
      );
    }

    _initialized = true;
  }

  /// Check if current theme is cyberpunk
  Future<bool> _isCyberpunkTheme() async {
    final storage = StorageService();
    final theme = await storage.getTheme();
    return theme == AppThemeType.cyberpunk;
  }

  /// Get morning briefing title based on theme
  Future<String> _getMorningTitle(String location) async {
    final isCyberpunk = await _isCyberpunkTheme();
    return isCyberpunk
        ? '☀️ MORNING_BRIEF // $location'
        : '☀️ Morning Briefing — $location';
  }

  /// Get evening outlook title based on theme
  Future<String> _getEveningTitle(String location) async {
    final isCyberpunk = await _isCyberpunkTheme();
    return isCyberpunk
        ? '🌙 EVENING_RECON // $location'
        : '🌙 Evening Outlook — $location';
  }

  /// Ask for notification permission when user agrees
  Future<bool?> requestPermission() async {
    await init();
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return androidImpl?.requestNotificationsPermission();
  }

  // ── Generic show ─────────────────────────────────────────────

  /// Show an immediate notification (legacy / debug)
  Future<void> showNow({
    required String title,
    required String body,
    String payload = '',
  }) async {
    await init();
    await _plugin.show(
      id: _nextId(),
      title: title,
      body: body,
      notificationDetails: _briefingDetails(),
      payload: payload,
    );
  }

  /// Schedule a notification at a local time (tz safe)
  Future<void> scheduleAt({
    required DateTime time,
    required String title,
    required String body,
    String payload = '',
  }) async {
    await init();
    final tzTime = tz.TZDateTime.from(time, tz.local);
    await _plugin.zonedSchedule(
      id: _nextId(),
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: _briefingDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // ── Briefing notifications ───────────────────────────────────

  /// Morning briefing with rich weather summary
  Future<void> showMorningBriefing(WeatherData weather) async {
    await init();
    final msg = _buildMorningMessage(weather);
    final title = await _getMorningTitle(weather.location.name);
    await _plugin.show(
      id: _idMorning,
      title: title,
      body: msg,
      notificationDetails: _briefingDetails(),
    );
  }

  /// Evening outlook with tomorrow preview
  Future<void> showEveningOutlook(WeatherData weather) async {
    await init();
    final msg = _buildEveningMessage(weather);
    final title = await _getEveningTitle(weather.location.name);
    await _plugin.show(
      id: _idEvening,
      title: title,
      body: msg,
      notificationDetails: _briefingDetails(),
    );
  }

  // ── Severe weather alerts ────────────────────────────────────

  /// Show a severe weather notification (max importance)
  Future<void> showSevereAlert(TrendInsight insight) async {
    await init();
    await _plugin.show(
      id: _nextId(),
      title: insight.title,
      body: insight.body,
      notificationDetails: _severeDetails(),
    );
  }

  // ── Smart insight notifications ──────────────────────────────

  /// Show a weather insight notification
  Future<void> showInsight(TrendInsight insight) async {
    await init();
    await _plugin.show(
      id: _nextId(),
      title: insight.title,
      body: insight.body,
      notificationDetails: _insightDetails(),
    );
  }

  // ── Persistent weather status ────────────────────────────────

  /// Persistent status notification (ongoing)
  Future<void> showPersistent(WeatherData weather) async {
    await init();
    final current = weather.current;
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;
    final cond = WeatherUtils.getWeatherDescription(current.weatherCode);
    final place = weather.location.shortDisplayName;

    // Build a concise, informative status line
    final parts = <String>[];
    parts.add('${current.temperature.toStringAsFixed(0)}°C');
    parts.add(cond);
    if (today != null) {
      parts.add(
        'H:${today.temperatureMax.toStringAsFixed(0)}° L:${today.temperatureMin.toStringAsFixed(0)}°',
      );
    }
    parts.add('Humidity ${current.relativeHumidity}%');
    parts.add('Wind ${current.windSpeed.toStringAsFixed(0)} km/h');

    // Add upcoming change hint if available
    String? hint;
    final insights = TrendAnalyzer.detectAll(weather);
    if (insights.isNotEmpty) {
      hint = insights.first.title.replaceAll(RegExp(r'[^\w\s°—]'), '').trim();
    }

    final body = parts.join(' · ') + (hint != null ? '\n↗ $hint' : '');

    const android = AndroidNotificationDetails(
      _channelPersistent,
      'Current Weather Status',
      channelDescription:
          'Ongoing notification showing live weather conditions',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@drawable/ic_stat_weather',
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      category: AndroidNotificationCategory.status,
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(android: android);

    await _plugin.show(
      id: _idPersistent,
      title: '📍 $place // ${current.temperature.toStringAsFixed(0)}°C $cond',
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> cancelPersistent() async {
    await init();
    await _plugin.cancel(id: _idPersistent);
  }

  // ── Channel-specific NotificationDetails builders ────────────

  NotificationDetails _briefingDetails() {
    const android = AndroidNotificationDetails(
      _channelBriefing,
      'Daily Briefings',
      channelDescription: 'Morning and evening weather briefings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_stat_weather',
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
    );
    return const NotificationDetails(android: android);
  }

  NotificationDetails _severeDetails() {
    const android = AndroidNotificationDetails(
      _channelSevere,
      'Severe Weather Alerts',
      channelDescription:
          'Thunderstorms, extreme heat/cold, heavy rain/snow, high winds',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@drawable/ic_stat_weather',
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
      enableLights: true,
      enableVibration: true,
      fullScreenIntent: true,
    );
    return const NotificationDetails(android: android);
  }

  NotificationDetails _insightDetails() {
    const android = AndroidNotificationDetails(
      _channelInsights,
      'Weather Insights',
      channelDescription:
          'Temperature trends, rain probability changes, UV alerts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@drawable/ic_stat_weather',
      styleInformation: BigTextStyleInformation(''),
      playSound: false,
    );
    return const NotificationDetails(android: android);
  }

  // ── Briefing message builders ────────────────────────────────

  String _buildMorningMessage(WeatherData weather) {
    final hourly = weather.hourly;
    final daily = weather.daily;
    if (hourly.isEmpty || daily.isEmpty) {
      return 'Weather data unavailable. Try refreshing later.';
    }

    final today = daily.first;
    final cond = WeatherUtils.getWeatherDescription(today.weatherCode);
    final parts = <String>[];

    // Today's overview
    parts.add(
      'Today: $cond, ${today.temperatureMin.round()}°–${today.temperatureMax.round()}°C.',
    );

    // Rain check for the day
    final dayHours = hourly.take(12).toList();
    final rainyHour = dayHours.where(
      (h) =>
          h.precipitationProbability >= 50 ||
          h.rain >= 1 ||
          h.precipitation >= 1,
    );
    if (rainyHour.isNotEmpty) {
      final t = rainyHour.first.time;
      parts.add(
        'Rain likely around ${t.hour.toString().padLeft(2, '0')}:00 (${rainyHour.first.precipitationProbability}%). Bring an umbrella.',
      );
    } else {
      parts.add('No rain expected this morning.');
    }

    // UV warning
    if (today.uvIndexMax >= 8) {
      parts.add('UV index ${today.uvIndexMax.round()} — wear sunscreen.');
    }

    // Wind note
    if (today.windSpeedMax >= 30) {
      parts.add(
        'Wind gusts up to ${today.windGustsMax.round()} km/h expected.',
      );
    }

    return parts.join(' ');
  }

  String _buildEveningMessage(WeatherData weather) {
    if (weather.daily.length < 2 || weather.hourly.isEmpty) {
      return 'Weather data updating. Try again later.';
    }
    final current = weather.current;
    final tomorrow = weather.daily[1];
    final tomorrowCond = WeatherUtils.getWeatherDescription(
      tomorrow.weatherCode,
    );
    final parts = <String>[];

    // Current temp
    parts.add('Currently: ${current.temperature.round()}°C.');

    // Tomorrow preview
    parts.add(
      'Tomorrow forecast: $tomorrowCond, ${tomorrow.temperatureMin.round()}°–${tomorrow.temperatureMax.round()}°C.',
    );

    // Tomorrow rain?
    if (tomorrow.precipitationProbabilityMax >= 40) {
      parts.add('Precip probability ${tomorrow.precipitationProbabilityMax}%.');
    }

    // Week outlook
    if (weather.daily.length >= 5) {
      final weekHighs = weather.daily
          .skip(1)
          .take(5)
          .map((d) => d.temperatureMax);
      final weekLows = weather.daily
          .skip(1)
          .take(5)
          .map((d) => d.temperatureMin);
      final maxH = weekHighs.reduce((a, b) => a > b ? a : b);
      final minL = weekLows.reduce((a, b) => a < b ? a : b);
      parts.add('Week range: ${minL.round()}°–${maxH.round()}°C.');
    }

    return parts.join(' ');
  }

  int _counter = 2000;
  int _nextId() => ++_counter;
}
