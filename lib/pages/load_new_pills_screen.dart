import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/home_screen.dart';
// import 'package:medicine_dispenser/pages/pill_details_screen.dart';
import 'package:medicine_dispenser/pages/set_dosage_and_timings.dart';
import 'package:medicine_dispenser/services/http_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LoadNewPillsScreen extends StatefulWidget {
  final HttpService httpService;

  const LoadNewPillsScreen({super.key, required this.httpService});

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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        pillExpiryDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void loadPill() async {
    if (canLoadPill() && user != null) {
      try {
        await widget.httpService.sendLoadPillCommand(
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading pill: $e")),
        );
      }
    }
  }

  void openSetDosagePopup() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return SetDosageAndTimings(httpService: widget.httpService);
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
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text("Load New Pills", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select a Container", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["A", "B", "C"].map((container) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedContainer == container ? Colors.teal[700] : Colors.teal[300],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedContainer = container;
                    });
                  },
                  child: Text("Container $container", style: const TextStyle(fontSize: 18, color: Colors.white)),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            if (selectedContainer != null) ...[
              _buildInputField("Pill Name", (value) => setState(() => pillName = value)),
              _buildInputField("Pill Quantity", (value) => setState(() => pillQuantity = value), isNumeric: true),
              _buildDateSelector(),
              const SizedBox(height: 20),

              const Text("Dosage & Timings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              dosageTimings.isEmpty
                  ? ElevatedButton(
                      onPressed: openSetDosagePopup,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text("Add Dosage & Timings", style: TextStyle(color: Colors.white)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: canLoadPill() ? Colors.teal : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Center(child: Text("Load New Pill", style: TextStyle(fontSize: 18, color: Colors.white))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, Function(String) onChanged, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateSelector() {
    return ListTile(
      title: const Text("Expiry Date"),
      subtitle: Text(pillExpiryDate.isEmpty ? "Select a date" : pillExpiryDate),
      trailing: const Icon(Icons.calendar_today, color: Colors.teal),
      onTap: () => _selectDate(context),
    );
  }
}
