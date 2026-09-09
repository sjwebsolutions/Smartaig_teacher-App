import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../controller/announcement_controller.dart';
import '../controller/banner_controller.dart';
import '../services/device_service.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class FcmService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription = 'This channel is used for important announcements and updates.';

  static Future<void> registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final deviceInfo = await DeviceService.getDeviceInfo();

      await DioClient.dio.post(
        ApiUrls.fcmToken,
        data: {
          "device_uuid": deviceInfo["device_uuid"],
          "fcm_token": token,
        },
      );
      print("FCM Token Registered Successfully: $token");
    } catch (e) {
      print("Error registering FCM token: $e");
    }
  }

  static Future<void> initialize() async {
    try {
      print('Initializing FCM Services...');

      // 1. Request Permission (Required for iOS and Android 13+)
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User granted notification permission: ${settings.authorizationStatus}');

      // 2. Set foreground notification options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Initialize Flutter Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print("Notification clicked: ${details.payload}");
          if (Get.isRegistered<AnnouncementController>()) {
            Get.find<AnnouncementController>().markAsRead();
          }
        },
      );

      // 4. Create Android Notification Channel and Request Android 13+ Permission
      if (GetPlatform.isAndroid) {
        final androidPlugin = _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        // Request runtime permission for Android 13+ (API 33+)
        await androidPlugin?.requestNotificationsPermission();

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await androidPlugin?.createNotificationChannel(channel);
      }

      // 5. Subscribe to Common Broadcast Topics for Announcements and Banners
      try {
        await FirebaseMessaging.instance.subscribeToTopic("all");
        await FirebaseMessaging.instance.subscribeToTopic("teachers");
        await FirebaseMessaging.instance.subscribeToTopic("announcements");
        await FirebaseMessaging.instance.subscribeToTopic("banners");
        print("Subscribed to FCM topics: all, teachers, announcements, banners");
      } catch (e) {
        print("Topic subscription notice: $e");
      }

      // 6. Listen for Token Refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("FCM Token refreshed: $newToken");
        registerFcmToken();
      });

      // 7. Handle Foreground Messages (Both Notification & Data payloads)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Foreground FCM Message Received: ${message.data} | ${message.notification?.title}");

        // Extract title and body from either notification object or data payload
        final String? title = message.notification?.title ?? 
            message.data['title'] ?? 
            message.data['heading'] ?? 
            message.data['subject'];

        final String? body = message.notification?.body ?? 
            message.data['body'] ?? 
            message.data['message'] ?? 
            message.data['description'] ??
            message.data['content'];

        if (title != null || body != null) {
          showLocalNotification(
            title: title ?? "New Update",
            body: body ?? "You have a new announcement.",
            payload: message.data['type'] ?? "announcement",
          );
        }

        // Live refresh controllers when announcement or banner notification arrives
        if (Get.isRegistered<AnnouncementController>()) {
          Get.find<AnnouncementController>().hasNewNotifications.value = true;
          Get.find<AnnouncementController>().fetchAnnouncements();
        }
        if (Get.isRegistered<BannerController>()) {
          Get.find<BannerController>().fetchBanners(showLoading: false);
        }
      });

      // 8. Handle Notification Click when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification opened from background: ${message.notification?.title ?? message.data}");
        if (Get.isRegistered<AnnouncementController>()) {
          Get.find<AnnouncementController>().markAsRead();
        }
        Get.toNamed('/banners');
      });

      print('FCM Initialization Complete');
    } catch (e) {
      print('Error during FCM initialization: $e');
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
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
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      print("Error showing local notification: $e");
    }
  }
}
