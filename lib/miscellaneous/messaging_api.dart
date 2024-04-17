import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundNotification(RemoteMessage msg) async {}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notification',
      description: 'The Channel Is Important',
      importance: Importance.defaultImportance);
  final _localNotifications = FlutterLocalNotificationsPlugin();
  void handleMessage(RemoteMessage? msg) {
    if (msg == null) return;
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const ios = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(settings,
        onSelectNotification: (payload) {
      final msg = RemoteMessage.fromMap(jsonDecode(payload!));
      handleMessage(msg);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage;
    });
    FirebaseMessaging.onBackgroundMessage(
        (message) => handleBackgroundNotification(message));
    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
        payload: jsonEncode(event.toMap()),
      );
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
    final token = await _firebaseMessaging.getToken();

    initPushNotifications();
    initLocalNotifications();
  }
}
