import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../services/device_service.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class FcmService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> registerFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final deviceInfo = await DeviceService.getDeviceInfo();

    try {
      await DioClient.dio.post(
        ApiUrls.fcmToken,
        data: {
          "device_uuid": deviceInfo["device_uuid"],
          "fcm_token": token,
        },
      );
      print("FCM Token Registered: $token");
    } catch (e) {
      print("Error registering FCM token: $e");
    }
  }

  static Future<void> initialize() async {
    // 1. Request Permission (Required for iOS and Android 13+)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // 2. Set foreground notification options for iOS
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a native notification behavior on iOS
      badge: true,
      sound: true,
    );

    // 3. Initialize Flutter Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("Notification clicked: ${details.payload}");
      },
    );

    // 4. Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 5. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message Received: ${message.notification?.title}");
      
      RemoteNotification? notification = message.notification;
      
      if (notification != null) {
        // For Android, we show it manually using local notifications to ensure it pops up
        if (GetPlatform.isAndroid) {
          AndroidNotification? android = message.notification?.android;
          _localNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
            ),
          );
        }
        // For iOS, the setForegroundNotificationPresentationOptions handles the banner automatically
      }
    });

    // 6. Handle Notification Click when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked from background: ${message.notification?.title}");
    });

    // 7. Handle Notification Click when app is terminated (completely closed)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from terminated state via notification: ${initialMessage.notification?.title}");
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
