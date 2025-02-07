import 'package:flutter/material.dart';
import 'profile_sidebar.dart'; // Import Sidebar

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome User"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Open Sidebar Menu
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA6E3E9), Color(0xFF71C9CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Welcome to Home Page!"),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to Login Page
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "WELCOME USER",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child:
                              Icon(Icons.person, size: 24, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoBox("Upcoming Alert", "Pill Name          Time"),
                    const SizedBox(height: 20),
                    _buildInfoBox("Today's Pills",
                        "Pill Name          Time          Time"),
                    const SizedBox(height: 20),
                    _buildAlarmDetailsBox(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton("Pill Details", () {}),
                        _buildButton("Additional Settings", () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildAlarmDetailsBox() {
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
            "Alarm Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              _buildAlarmRow(
                  "DISMISSED", "Pill has been dispensed", Colors.orange),
              _buildAlarmRow(
                  "SNOOZED", "Time remaining till 40 min mark", Colors.orange),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            "40 minutes passed since dosage time",
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "NOTIFY THE PATIENT IMMEDIATELY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAlarmRow(String title, String description, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
