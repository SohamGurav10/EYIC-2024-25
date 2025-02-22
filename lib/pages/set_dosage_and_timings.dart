import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:medicine_dispenser/services/http_service.dart';

class SetDosageAndTimings extends StatefulWidget {
  final HttpService httpService;

  const SetDosageAndTimings({super.key, required this.httpService});

  @override
  _SetDosageAndTimingsState createState() => _SetDosageAndTimingsState();
}

class _SetDosageAndTimingsState extends State<SetDosageAndTimings> {
  int dosageCount = 0;
  DateTime selectedTime = DateTime.now();
  List<String> selectedDays = [];
  final User? user = FirebaseAuth.instance.currentUser;

  void saveDosageToFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save data.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dosages')
          .add({
        'dosage': dosageCount,
        'time': "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
        'repeatDays': selectedDays,
        'alarmName': "Pills have been dispensed, take the pill!"
      });

      widget.httpService.sendSchedule("Pill", selectedTime.hour, selectedTime.minute);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dosage saved successfully!")),
      );

    } catch (e) {
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
    return AlertDialog(
      backgroundColor: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Set New Dosage & Timings",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        textAlign: TextAlign.center,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            // Dosage Counter
            _buildSectionTitle("Enter Dosage:"),
            const SizedBox(height: 10),
            _buildDosageCounter(),

            const SizedBox(height: 20),

            // Time Picker
            _buildSectionTitle("Select Time:"),
            const SizedBox(height: 10),
            _buildTimePicker(),

            const SizedBox(height: 20),

            // Repeat Dosage Selection
            _buildSectionTitle("Repeat Dosage:"),
            const SizedBox(height: 10),
            _buildDaySelection(),

            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            discardInputs();
            Navigator.pop(context);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () {
            saveDosageToFirestore();
            if (mounted) {
              Navigator.pop(context, [dosageCount, selectedTime, selectedDays]);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade400),
          child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
      normalTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
      highlightedTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
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
      children: [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
      ].map((day) {
        return ChoiceChip(
          label: Text(day, style: const TextStyle(fontSize: 16)),
          selected: selectedDays.contains(day),
          selectedColor: Colors.teal.shade300,
          backgroundColor: Colors.teal.shade100,
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
