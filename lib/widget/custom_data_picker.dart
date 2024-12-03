import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schedule_notification/noification/notification_handel.dart';

class SetNotificationScreen extends StatefulWidget {
  @override
  _SetNotificationScreenState createState() => _SetNotificationScreenState();
}

class _SetNotificationScreenState extends State<SetNotificationScreen> {
  int id = 0;
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  List<Map<String, String>> notifications = [];
  Duration selectedTime = Duration(hours: 0, minutes: 0);

  void _showCupertinoTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: CupertinoTimerPicker(
            initialTimerDuration: selectedTime,
            mode: CupertinoTimerPickerMode.hm, // Hours and minutes mode
            onTimerDurationChanged: (Duration newTime) {
              setState(() {
                selectedTime = newTime;
              });
            },
          ),
        );
      },
    );
  }

  void addNotification(String title, String body) {
    setState(() {
      id++;
      notifications.add({'title': title, 'body': body});
    });

    NotificationService.scheduleNotificationOnSpecificDays(
      title: title,
      body: body,
      id: id,
      hour: selectedTime.inHours,
      minutes: selectedTime.inMinutes % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Notification "),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration:const InputDecoration(labelText: 'Notification Title'),
            ),
            TextField(
              controller: bodyController,
              decoration:const InputDecoration(labelText: 'Notification Body'),
            ),
            const SizedBox(height: 10),
            Text(
                "Selected Time: ${selectedTime.inHours}h ${selectedTime.inMinutes % 60}m Notification Id $id"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text;
                      final body = bodyController.text;

                      if (title.isNotEmpty &&
                          body.isNotEmpty &&
                          selectedTime.inHours != 0 &&
                          selectedTime.inMinutes != 0) {
                        addNotification(title, body);

                        titleController.clear();
                        bodyController.clear();
                      }
                    },
                    child: const Text('Add Notification'),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showCupertinoTimePicker(context);
                  },
                  child: const Text("Pick Time"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      notifications[index]['title'] ?? '',
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    subtitle: Text(
                      notifications[index]['body'] ?? '',
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                NotificationService.cancel(id);
              },
              child: const Text("Cancel Notification"),
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
