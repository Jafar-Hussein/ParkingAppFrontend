import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;

class NotificationRepository {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      await _configureTimeZone();

      final android = AndroidInitializationSettings(
        '@drawable/ic_notification',
      );
      final ios = DarwinInitializationSettings();
      final settings = InitializationSettings(android: android, iOS: ios);
      await _plugin.initialize(settings);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> _configureTimeZone() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        await androidImpl?.requestNotificationsPermission();
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String content,
    required DateTime deliveryTime,
    required int id,
  }) async {
    try {
      await requestPermissions();
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'custom_sound_channel', // nytt unikt id!
            'Ljudkanal',
            channelDescription: 'Kanal med anpassat ljud',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('notification_sound'),
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
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
