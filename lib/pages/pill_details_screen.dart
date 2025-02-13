import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/pill_reload_page.dart';

class PillDetailsScreen extends StatelessWidget {
  const PillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: const Text("PILL DETAILS"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pillTab("Pill A", isSelected: true),
                  _pillTab("Pill B"),
                  _pillTab("Pill C"),
                ],
              ),
              const SizedBox(height: 20),
              _infoSection("Pill Name", "Display pill name"),
              _infoSection(
                  "Pill Quantity Remaining", "Display Remaining pill quantity"),
              _infoSection("Expiry Date", "Display expiry date of the pills"),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton("RELOAD PILLS", context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PillReloadPage()),
                    );
                  }),
                  _actionButton("CLOSE", context, () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillTab(String text, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        backgroundColor: isSelected ? Colors.teal : Colors.teal.shade100,
        label: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoSection(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(description),
        ],
      ),
    );
  }

  Widget _actionButton(
      String text, BuildContext context, VoidCallback onPressed) {
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
