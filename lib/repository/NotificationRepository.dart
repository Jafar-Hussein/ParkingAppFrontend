import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;

class NotificationRepository {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _configureTimeZone();

    final android = AndroidInitializationSettings('@drawable/ic_notification');
    final ios = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> _configureTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImpl =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImpl?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String content,
    required DateTime deliveryTime,
    required int id,
  }) async {
    await requestPermissions();
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Standard notifications',
      channelDescription: 'Notisbeskrivning',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      content,
      tz.TZDateTime.from(deliveryTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'optional payload',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
