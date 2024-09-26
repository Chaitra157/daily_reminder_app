import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
//import 'package:flutter_local_reminder_notifications';

void main() => runApp(ReminderApp());

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReminderHome(),
    );
  }
}

class ReminderHome extends StatefulWidget {
  @override
  _ReminderHomeState createState() => _ReminderHomeState();
}

class _ReminderHomeState extends State<ReminderHome> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String selectedDay = 'Monday';
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedActivity = 'Wake up';
  AudioPlayer audioPlayer = AudioPlayer();

  List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  List<String> activities = [
    'Wake up', 'Go to gym', 'Breakfast', 'Meetings', 'Lunch',
    'Quick nap', 'Go to library', 'Dinner', 'Go to sleep'
  ];

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidInitSettings = AndroidInitializationSettings('app_icon');
    var initSettings = InitializationSettings(android: androidInitSettings);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification() async {
    var time = Time(selectedTime.hour, selectedTime.minute, 0);
    var androidDetails = AndroidNotificationDetails('channelId', 'Reminder', channelDescription: 'Reminder notification');
    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      '$selectedActivity time!',
      _nextInstanceOfTime(time),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  void main()
  {
    tz.initializeTimeZones();
    runApp(ReminderApp());
  }

  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  void playChime() async {
    await audioPlayer.play('assets/chime.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Day Dropdown

            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String? newValue) {
                if(newValue != null) {
                  setState(() {
                    selectedActivity = newValue;
                  });
                }
              },
              items: activities.map<DropdownMenuItem<String>>((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
            ),

            // Time Picker
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null && picked != selectedTime) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: Text('Pick Time: ${selectedTime.format(context)}'),
            ),

            // Activity Dropdown
            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedActivity = newValue;
                  });
                }
              },
              items: activities.map<DropdownMenuItem<String>>((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
            ),

            // Set Reminder Button
            ElevatedButton(
              onPressed: () {
                scheduleNotification();
                playChime(); // Plays sound when reminder is triggered
              },
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}