import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/pill_reload_page.dart';
import 'package:medicine_dispenser/pages/load_new_pills_screen.dart';
import 'package:provider/provider.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';
import 'package:medicine_dispenser/services/http_service.dart'; // Import HttpService

class PillDetailsScreen extends StatefulWidget {
  const PillDetailsScreen({super.key});

  @override
  _PillDetailsScreenState createState() => _PillDetailsScreenState();
}

class _PillDetailsScreenState extends State<PillDetailsScreen> {
  String selectedContainer = "Container A"; // Default container selection
  final HttpService httpService = HttpService(); // Create an instance of HttpService

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _containerButton("Container A"),
                      _containerButton("Container B"),
                      _containerButton("Container C"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _infoSection(context, selectedContainer, pillProvider),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton("LOAD NEW PILLS", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoadNewPillsScreen(httpService: httpService)), // Pass HttpService
                        );
                      }),
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

  Widget _containerButton(String container) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedContainer == container
              ? Colors.teal.shade700
              : Colors.teal.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedContainer = container;
          });
        },
        child: Text(
          container,
          style: TextStyle(
            color: selectedContainer == container ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoSection(
      BuildContext context, String container, PillProvider pillProvider) {
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
          _infoRow("Pill Name",
              pillProvider.pillNames[container] ?? "Enter Pill Name"),
          const Divider(color: Colors.teal, thickness: 1),
          _infoRow("Pill Quantity Remaining",
              "${pillProvider.pillCounts[container] ?? 0} Remaining"),
          const Divider(color: Colors.teal, thickness: 1),
          _infoRow("Expiry Date",
              pillProvider.expiryDates[container] ?? "DD|MM|YYYY"),
          const Divider(color: Colors.teal, thickness: 1),
          _infoRow(
              "Dosage & Timings", _getDosageDetails(pillProvider, container)),
        ],
      ),
    );
  }

  String _getDosageDetails(PillProvider pillProvider, String container) {
    List<String>? dosages = pillProvider.dosageSchedules[container];
    if (dosages == null || dosages.isEmpty) {
      return "Not Set";
    }
    return dosages.map((dose) => "• $dose").join("\n");
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
