import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/home_screen.dart';
import 'package:medicine_dispenser/pages/pill_details_screen.dart';
import 'package:medicine_dispenser/pages/set_dosage_and_timings.dart';
import 'package:medicine_dispenser/services/http_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadNewPillsScreen extends StatefulWidget {
  final HttpService httpService;

  const LoadNewPillsScreen({super.key, required this.httpService}); // Add httpService

  @override
  _LoadNewPillsScreenState createState() => _LoadNewPillsScreenState();
}

class _LoadNewPillsScreenState extends State<LoadNewPillsScreen> {
  String? selectedContainer;
  String pillName = "";
  String pillQuantity = "";
  String pillExpiryDate = "";
  List<String> dosageTimings = [];

  final User? user = FirebaseAuth.instance.currentUser;

  bool canLoadPill() {
    return selectedContainer != null &&
        pillName.isNotEmpty &&
        pillQuantity.isNotEmpty &&
        pillExpiryDate.isNotEmpty;
  }

  void loadPill() {
    if (canLoadPill()) {
      widget.httpService.sendLoadPillCommand(
          user!.uid, selectedContainer!, pillName, pillQuantity, pillExpiryDate, dosageTimings);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pill successfully loaded!")),
      );

      setState(() {
        selectedContainer = null;
        pillName = "";
        pillQuantity = "";
        pillExpiryDate = "";
        dosageTimings = [];
      });
    }
  }

  void openSetDosagePopup() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return SetDosageAndTimings(httpService: widget.httpService); // ✅ Pass httpService here
      },
    );

    if (result != null) {
      setState(() {
        dosageTimings = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text("Load New Pills"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Select a Container", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["A", "B", "C"].map((container) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedContainer == container ? Colors.teal[400] : Colors.teal[200],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedContainer = container;
                    });
                  },
                  child: Text("Container $container", style: const TextStyle(fontSize: 18)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (selectedContainer != null) ...[
              TextField(
                decoration: const InputDecoration(labelText: "Pill Name"),
                onChanged: (value) => setState(() => pillName = value),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Pill Quantity"),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => pillQuantity = value),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Expiry Date (YYYY-MM-DD)"),
                keyboardType: TextInputType.datetime,
                onChanged: (value) => setState(() => pillExpiryDate = value),
              ),

              const SizedBox(height: 20),

              const Text("Dosage & Timings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              dosageTimings.isEmpty
                  ? ElevatedButton(
                      onPressed: openSetDosagePopup,
                      child: const Text("Add Dosage & Timings"),
                    )
                  : Column(
                      children: dosageTimings
                          .map((timing) => ListTile(
                                title: Text(timing),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      dosageTimings.remove(timing);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: canLoadPill() ? loadPill : null,
                child: const Text("Load New Pill"),
              ),
            ],

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PillDetailsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
