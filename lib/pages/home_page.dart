import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'profile_sidebar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "User"; // Default name
  List<Map<String, dynamic>> pillSchedules = [];
  String alarmStatus = "No alarms";

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchPillSchedules();
  }

  Future<void> fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            fullName = "${userDoc['first_name']} ${userDoc['last_name']}";
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchPillSchedules() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var schedules = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pill_schedules')
            .get();

        setState(() {
          pillSchedules = schedules.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print("Error fetching pill schedules: $e");
    }
  }

  void _triggerAlarm() {
    setState(() {
      alarmStatus = "Upcoming Alarm! Take your medicine";
    });
    flutterLocalNotificationsPlugin.show(
      0,
      "Pill Reminder",
      "It's time to take your medicine!",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Medicine Alarm',
          channelDescription: 'Reminder for medicine intake',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        ),
      ),
    );
  }

  void _dismissAlarm() {
    setState(() {
      alarmStatus = "Alarm dismissed. Pill dispensed.";
    });
  }

  void _snoozeAlarm() {
    setState(() {
      alarmStatus = "Snoozed for 10 minutes.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 10),
            const Text("MediMate"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const ProfileSidebar(),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA6E3E9), Color(0xFF71C9CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "WELCOME $fullName!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoBox("Upcoming Alert", alarmStatus),
        _buildAlarmControls(),
      ],
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.teal.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _dismissAlarm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Dismiss"),
        ),
        ElevatedButton(
          onPressed: _snoozeAlarm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Snooze"),
        ),
        ElevatedButton(
          onPressed: _triggerAlarm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Trigger Alarm"),
        ),
      ],
    );
  }
}