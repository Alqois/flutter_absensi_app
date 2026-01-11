import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/data/datasources/auth_remote_datasource.dart';

class FirebaseMessagingRemoteDatasource {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
  
    // 🔥 WAJIB: Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.max,
    );
  
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  
    await localNotifications.initialize(initSettings);
  
    final token = await messaging.getToken();
    print("🔥 FCM TOKEN = $token");
  
    // ❌ HAPUS BAGIAN UPDATE TOKEN
    // karena ini dipanggil sebelum login
  
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 FOREGROUND");
      _showLocalNotification(message);
    });
  
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 OPENED FROM BACKGROUND");
      _showLocalNotification(message);
    });
  
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  }


  // SHOW NOTIFICATION
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotifications.show(
      DateTime.now().millisecond,
      notif.title,
      notif.body,
      platformDetails,
    );
  }
}

// HARUS DI LUAR CLASS!!
// BACKGROUND HANDLER (APP MATI / TERMINATE)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 BACKGROUND MESSAGE: ${message.notification?.title}");
}
