// import 'dart:developer';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotificationHandler {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> requestNotificationPermissions() async {
//     final bool? result = await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestExactAlarmsPermission();
//     print("Permissions granted: $result");
//   }

//   Future<void> scheduleNotification() async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'schedule_channel_id',
//       'Scheduled Notifications',
//       channelDescription: 'Notifications that are scheduled',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'scheduled title',
//       'scheduled body',
//       tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
//       const NotificationDetails(
//         android: androidDetails,
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }

import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Request IOS permissions
  void requestPermissions() {
    // _notificationsPlugin
    //     .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(
    //       alert: true,
    //       badge: true,
    //       sound: true,
    //     );

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> init() async {
    /// First add initializeTimeZones  Local
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    /// First add initializeTimeZones  From Device
    // final String currentTimeZone = DateTime.now().timeZoneName;
    // tz.setLocalLocation(tz.getLocation(currentTimeZone));

    /// initialize android with '@mipmap/ic_launcher' icon and do not forget to add keep.xml file  to app /res
    /// android\app\src\main\res\raw
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// initialize IOS AND Mac
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    /// initialize method
    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  /// scheduleDailyNotification  after 2 second
  static Future<void> scheduleDailyNotificationAfter2Second() async {
    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        "notification title",
        "notification body",
        // scheduledTime,
        tz.TZDateTime.now(tz.local).add(
          const Duration(seconds: 2),
        ), // Schedule time
        _notificationDetailScheduleAfter2Second(),
        // The time you specify for the notification is considered an absolute time in the local timezone of the device.
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,

        ///ensures that the notification is scheduled to repeat at the same time every day.
        matchDateTimeComponents: DateTimeComponents.time,

        /// Ensures that the notification triggers at the exact time, even if the device is in Doze mode or idle.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// scheduleDailyNotification  you can you time here
  static Future<void> scheduleDailyNotification(DateTime selectedTime) async {
    const scheduleDailyNotification = NotificationDetails(
      android: AndroidNotificationDetails(
        '1',
        'schedule Daily Notification',
        // 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
      iOS: DarwinNotificationDetails(),
    );
    if (selectedTime.isBefore(DateTime.now())) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(selectedTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        "notification title",
        "notification body",
        scheduledTime, // Schedule time
        scheduleDailyNotification,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> scheduleNotificationAtSpecificTime() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: 'Notifications that occur daily at a specific time',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Define the time for the notification
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // Set the hour (e.g., 9 AM)
      16, // Set the minute
    );

    // If the scheduled time is in the past, move it to the next day
    final tz.TZDateTime adjustedTime = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    await _notificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Daily Reminder at 8 :29', // Notification Title
      'This is your daily scheduled notification!', // Notification Body
      adjustedTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // Ensures it triggers daily at the same time
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleNotificationOnSpecificDays(
      //   {
      //   required int hour,
      //   required int minutes,
      //   required int id,
      //   required String sound,
      // }
      ) async {
    const AndroidNotificationDetails reminderChannel =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: reminderChannel);
    await _notificationsPlugin.zonedSchedule(
      2,
      'Reminder',
      'This is your reminder for the day!',
      _convertTime(22, 19, 2),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // Match both day and time
    );
  }

  /// Notification channels
  static NotificationDetails _notificationDetailScheduleAfter2Second() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'schedule After 2 Second',
        // 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static tz.TZDateTime _convertTime(int hour, int minutes, int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day, // monday is 2 and tuesday  3 until tuesday
      hour,
      minutes,
    );
    // If the scheduled time is in the past, move it to the next day
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  cancelAll() async => await _notificationsPlugin.cancelAll();
  cancel(id) async => await _notificationsPlugin.cancel(id);
}