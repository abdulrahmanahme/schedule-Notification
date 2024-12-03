import 'package:flutter/material.dart';
import 'package:schedule_notification/noification/notification_handel.dart';
import 'package:schedule_notification/widget/custom_data_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NotificationHandler.requestNotificationPermissions();
  // NotificationHandler.initializeNotifications();
  NotificationService.checkAndRequestNotificationPermission();
  NotificationService.init();
  // NotificationService.scheduleDailyNotificationAfter2Second();
  NotificationService.scheduleNotificationAtSpecificTime();
  // NotificationService.scheduleNotificationOnSpecificDays();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Notification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SetNotificationScreen(),
    );
  }
}
