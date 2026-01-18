import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_absensi_app/core/helper/notification_storage.dart';

class FirebaseMessagingRemoteDatasource {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await localNotifications.initialize(initSettings);

    final token = await messaging.getToken();
    // ignore: avoid_print
    print("🔥 FCM TOKEN = $token");

    // ✅ FOREGROUND: app terbuka
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // ignore: avoid_print
      print("📩 FOREGROUND");

      // 1) tampilkan notif lokal (biar ada heads-up)
      await _showLocalNotification(message);

      // 2) simpan ke NotificationPage
      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';
      await NotificationStorage.push(
        title: title,
        message: body,
        type: message.data['type'] ?? 'general',
      );
    });

    // ✅ BACKGROUND: user tap notif (app sebelumnya background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // ignore: avoid_print
      print("📲 OPENED FROM BACKGROUND");

      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';
      await NotificationStorage.push(
        title: title,
        message: body,
        type: message.data['type'] ?? 'general',
      );
    });

    // ✅ TERMINATED: app mati lalu dibuka dari notif
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      // ignore: avoid_print
      print("🧊 OPENED FROM TERMINATED");

      final title = initial.notification?.title ?? 'Notifikasi';
      final body = initial.notification?.body ?? '';
      await NotificationStorage.push(
        title: title,
        message: body,
        type: initial.data['type'] ?? 'general',
      );
    }

    // ❌ JANGAN pasang onBackgroundMessage di sini!
    // Itu sudah dipasang di main.dart.
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ✅ unik
      notif.title,
      notif.body,
      platformDetails,
    );
  }
}
