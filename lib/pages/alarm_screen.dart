import 'package:flutter/material.dart';
import 'package:medicine_dispenser/services/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final HttpService httpService = HttpService();
  int snoozeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSnoozeCount();
  }

  void _loadSnoozeCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      snoozeCount = prefs.getInt("snooze_count") ?? 0;
    });
  }

  void _incrementSnoozeCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (snoozeCount < 3) {
      prefs.setInt("snooze_count", snoozeCount + 1);
      Navigator.pop(context);
      Future.delayed(const Duration(minutes: 10), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlarmScreen()),
        );
      });
    }
  }

  void _resetSnoozeCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("snooze_count", 0);
  }

  void _dispensePills() async {
    await httpService.sendDispenseCommand();
    _resetSnoozeCount();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Time to take your medicine!",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -10) {
                  _incrementSnoozeCount();
                }
              },
              child: const Text(
                "Swipe up to Snooze",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! > 10) {
                  _dispensePills();
                }
              },
              child: const Text(
                "Swipe down to Dispense",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
