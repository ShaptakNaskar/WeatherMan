import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:weatherman/models/weather.dart';
import 'package:weatherman/utils/weather_utils.dart';

/// Handles local notification setup and delivery
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'weather_alerts';
  static const String _channelName = 'Weather Alerts';
  static const String _channelDesc = 'Daily briefings, evening updates, and trend alerts';
  static const String _channelPersistentId = 'weather_persistent';
  static const String _channelPersistentName = 'Weather Status';
  static const String _channelPersistentDesc = 'Live weather status';

  /// Initialize notification plugin and request permission if needed
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_weather');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);

    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
      ));
      await androidImpl.createNotificationChannel(const AndroidNotificationChannel(
        _channelPersistentId,
        _channelPersistentName,
        description: _channelPersistentDesc,
        importance: Importance.low,
        enableLights: false,
        enableVibration: false,
        showBadge: false,
      ));
    }

    _initialized = true;
  }

  /// Ask for notification permission when user agrees
  Future<bool?> requestPermission() async {
    await init();
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return androidImpl?.requestNotificationsPermission();
  }

  /// Show an immediate notification
  Future<void> showNow({
    required String title,
    required String body,
    String payload = '',
  }) async {
    await init();
    final details = _details();
    await _plugin.show(
      id: _nextId(),
      title: title,
      body: body,
      notificationDetails: details,
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
    final details = _details();
    await _plugin.zonedSchedule(
      id: _nextId(),
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Build Android notification details
  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_stat_weather',
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
    );
    return const NotificationDetails(android: android);
  }

  /// Persistent status notification (ongoing)
  Future<void> showPersistent(WeatherData weather) async {
    await init();
    final current = weather.current;
    final cond = WeatherUtils.getWeatherDescription(current.weatherCode);
    final place = weather.location.shortDisplayName;
    final body =
        'NOW ${current.temperature.toStringAsFixed(1)}°C | $cond | HUM ${current.relativeHumidity}% | WIND ${current.windSpeed.toStringAsFixed(0)}km/h | AQI ${weather.airQuality?.usAqi ?? '--'} | PRECIP ${current.precipitation.toStringAsFixed(1)}mm | PRESS ${current.pressure.toStringAsFixed(0)}hPa';

    const android = AndroidNotificationDetails(
      _channelPersistentId,
      _channelPersistentName,
      channelDescription: _channelPersistentDesc,
      importance: Importance.low,
      priority: Priority.low,
      icon: '@drawable/ic_stat_weather',
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.service,
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(android: android);

    await _plugin.show(
      id: 9999,
      title: 'CYBERWEATHER // $place',
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> cancelPersistent() async {
    await init();
    await _plugin.cancel(id: 9999);
  }

  int _counter = 0;
  int _nextId() => ++_counter;
}
