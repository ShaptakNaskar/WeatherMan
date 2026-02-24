import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weatherman/services/notification_service.dart';

/// Handles Firebase Cloud Messaging setup and bridges payloads to local notifications
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _initialized = false;

  Future<void> init({bool requestPermission = false}) async {
    if (_initialized) return;

    // Ensure Firebase is ready (main already initializes, but guard for bg isolates)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    final messaging = FirebaseMessaging.instance;

    // Permissions (Android 13+)
    if (requestPermission) {
      await messaging.requestPermission();
    }

    // Foreground presentation
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Background / terminated
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Optional: log token for debugging (not persisted)
    try {
      final token = await messaging.getToken();
      // ignore: avoid_print
      print('FCM token: $token');
    } catch (_) {}

    _initialized = true;
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    await NotificationService.instance.init();
    final title = message.notification?.title ?? 'Weather update';
    final body = message.notification?.body ?? _bodyFromData(message);
    await NotificationService.instance.showNow(
      title: title,
      body: body.isNotEmpty ? body : 'Signal received. Check the feed.',
    );
  }

  String _bodyFromData(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return 'Open for details.';
    if (data.containsKey('body')) return data['body'] as String;
    if (data.containsKey('summary')) return data['summary'] as String;
    return data.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
  }
}

/// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.instance.init();
  final title = message.notification?.title ?? 'Weather update';
  final body = message.notification?.body ??
      (message.data['body'] as String? ?? 'Open for details.');
  await NotificationService.instance.showNow(title: title, body: body);
}
