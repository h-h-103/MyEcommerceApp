import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myecommerceapp/main.dart';

class MessagingConfig {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> initFirebaseMessaging() async {
    await createNotificationChannel();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        log("Notification tapped with payload: ${payload.payload.toString()}");
        return;
      },
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      log("📱 Message received in foreground");
      try {
        RemoteNotification? notification = event.notification;
        // ignore: unused_local_variable
        AndroidNotification? android = event.notification?.android;
        log("Title: ${notification?.title}");
        log("Body: ${notification?.body}");
        log("Data: ${event.data}");

        var body = notification?.body;

        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification?.title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              sound: RawResourceAndroidNotificationSound('custom_sound'),
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'custom_sound.caf',
            ),
          ),
        );

        handleNotification(navigatorKey.currentContext!, event.data);
      } catch (err) {
        log("❌ Error handling foreground message: $err");
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        log("📱 App opened from notification");
        handleNotification(navigatorKey.currentContext!, message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("📱 App opened from background notification");
      handleNotification(navigatorKey.currentContext!, message.data);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> messageHandler(RemoteMessage message) async {
    log('📱 Background message: ${message.notification?.body}');
  }
}

// Notification handler for admin app - only handles admin-specific routes
void handleNotification(BuildContext context, Map<String, dynamic> data) {
  String route = data['route'] ?? '';
  String id = data['id'] ?? '';
  String action = data['action'] ?? '';

  // ignore: avoid_print
  print('Handling notification - Route: $route, ID: $id, Action: $action');

  // Handle admin-specific routes only
  if (route == '/addCategory') {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         // AddProductScreen(companyId: id.isNotEmpty ? id : null),
    //   ),
    // );
  }
  // For notifications meant for user apps, just log and ignore
  else if (action == 'new_product') {
    // ignore: avoid_print
    print(
      '📱 New product notification sent to user apps - no action needed in admin app',
    );
  }
  // Default fallback for admin app
  else {
    // ignore: avoid_print
    print('Unknown admin notification route: $route');
    // Admin app doesn't need to handle user app routes
  }
}
