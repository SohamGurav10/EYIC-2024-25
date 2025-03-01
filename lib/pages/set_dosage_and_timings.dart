import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:medicine_dispenser/services/http_service.dart';

class SetDosageAndTimings extends StatefulWidget {
  final HttpService httpService;
  final String container;
  final String sourceScreen;

  const SetDosageAndTimings({
    super.key,
    required this.httpService,
    required this.container,
    required this.sourceScreen,
  });

  @override
  _SetDosageAndTimingsState createState() => _SetDosageAndTimingsState();
}

class _SetDosageAndTimingsState extends State<SetDosageAndTimings> {
  int dosageCount = 0;
  DateTime selectedTime = DateTime.now();
  List<String> selectedDays = [];
  final User? user = FirebaseAuth.instance.currentUser;

  bool get isDoneEnabled => dosageCount > 0 && selectedDays.isNotEmpty;

  
  void saveDosageToFirestore() async {
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save data.")),
      );
      return;
    }

    try {
      // Create a properly structured dosage map
      final Map<String, dynamic> dosageData = {
        'dosage': dosageCount,
        'time':
            "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
        'repeatDays': selectedDays,
        'alarmName': "Pills have been dispensed, take the pill!",
        'createdAt': FieldValue.serverTimestamp(), // Add timestamp for ordering
      };

      // Reference to the specific pill document
      final pillRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('pills')
          .doc(widget.container);

      // First check if the document exists
      final pillDoc = await pillRef.get();

      if (!pillDoc.exists) {
        // Create the document with initial data
        await pillRef.set({
          'dosageTimings': [dosageData],
        });
      } else {
        // Update existing document
        await pillRef.update({
          'dosageTimings': FieldValue.arrayUnion([dosageData]),
        });
      }

      // Send schedule after successful Firestore update
      await widget.httpService.sendSchedule(
        "Pill",
        selectedTime.hour,
        selectedTime.minute,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dosage saved successfully!")),
      );

      Navigator.pop(context, widget.sourceScreen);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  void discardInputs() {
    setState(() {
      dosageCount = 0;
      selectedTime = DateTime.now();
      selectedDays.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA6E3E9), Color(0xFF71C9CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Set New Dosage & Timings",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Enter Dosage:"),
            const SizedBox(height: 10),
            _buildDosageCounter(),
            const SizedBox(height: 20),
            _buildSectionTitle("Select Time:"),
            const SizedBox(height: 10),
            _buildTimePicker(),
            const SizedBox(height: 20),
            _buildSectionTitle("Repeat Dosage:"),
            const SizedBox(height: 10),
            _buildDaySelection(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    discardInputs();
                    Navigator.pop(context, widget.sourceScreen);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.teal.shade700, width: 1),
                    ),
                  ),
                  child: const Text("Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: isDoneEnabled ? saveDosageToFirestore : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDoneEnabled ? Colors.teal.shade600 : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Done",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildDosageCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () {
            setState(() {
              if (dosageCount > 0) dosageCount--;
            });
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.teal, width: 1),
          ),
          child: Text(
            "$dosageCount",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () {
            setState(() {
              dosageCount++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return TimePickerSpinner(
      is24HourMode: true,
      normalTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      highlightedTextStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      spacing: 50,
      itemHeight: 45,
      isForce2Digits: true,
      onTimeChange: (time) {
        setState(() {
          selectedTime = time;
        });
      },
    );
  }

  Widget _buildDaySelection() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((day) {
        return ChoiceChip(
          label: Text(day, style: const TextStyle(fontSize: 16)),
          selected: selectedDays.contains(day),
          selectedColor: Colors.teal.shade700,
          backgroundColor: Colors.teal.shade200,
          onSelected: (selected) {
            setState(() {
              selected ? selectedDays.add(day) : selectedDays.remove(day);
            });
          },
        );
      }).toList(),
    );
  }
}
