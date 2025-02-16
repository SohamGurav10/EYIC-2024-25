import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/pill_reload_page.dart';
import 'package:provider/provider.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';

class PillDetailsScreen extends StatefulWidget {
  const PillDetailsScreen({super.key});

  @override
  _PillDetailsScreenState createState() => _PillDetailsScreenState();
}

class _PillDetailsScreenState extends State<PillDetailsScreen> {
  String selectedPill = "Pill A"; // Default selected pill

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
      body: Consumer<PillProvider>(
        builder: (context, pillProvider, child) {
          return Container(
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
                  // Pill Selection Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _pillButton("Pill A"),
                      _pillButton("Pill B"),
                      _pillButton("Pill C"),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Pill Information Section (NON-EDITABLE)
                  _infoSection(context, selectedPill),

                  const Spacer(),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton("RELOAD PILLS", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PillReloadPage()),
                        );
                      }),
                      _actionButton("CLOSE", () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Pill Selection Button
  Widget _pillButton(String pill) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedPill == pill
              ? Colors.teal.shade700
              : Colors.teal.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedPill = pill;
          });
        },
        child: Text(
          pill,
          style: TextStyle(
            color: selectedPill == pill ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Pill Information Section (NON-EDITABLE)
  Widget _infoSection(BuildContext context, String pill) {
    var pillProvider = Provider.of<PillProvider>(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Pill Name", pillProvider.pillNames[pill] ?? "Not Set"),
          const Divider(color: Colors.teal, thickness: 1),
          _infoRow("Pill Quantity Remaining",
              "${pillProvider.pillCounts[pill] ?? 0} Remaining"),
          const Divider(color: Colors.teal, thickness: 1),
          _infoRow(
              "Expiry Date", pillProvider.expiryDates[pill] ?? "DD|MM|YYYY"),
        ],
      ),
    );
  }

  // Non-Editable Text Row
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  // Action Button Widget
  Widget _actionButton(String text, VoidCallback onPressed) {
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
