import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../miscellaneous/time.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max),
        iOS: IOSNotificationDetails());
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings,
        onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(id, title, body, await _notificationDetails(),
          payload: payload);

  static Future showScheduledNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payload,
      required DateTime date}) async {
    final timeZone = TimeZone();
    String timeZoneName = await timeZone.getTimeZoneName();
    final location = await timeZone.getLocation(timeZoneName);

    return _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(date, location), await _notificationDetails(),
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }
}
