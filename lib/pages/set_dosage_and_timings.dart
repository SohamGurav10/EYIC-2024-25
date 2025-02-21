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

    // Check if user is authenticated
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save data."))
      );
      return; // Stop execution if the user is not logged in
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

      // Optional API call
      widget.httpService.sendSchedule("Pill", selectedTime.hour, selectedTime.minute);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dosage saved successfully!"))
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e"))
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
      title: const Text("Set New Dosage & Timings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dosage Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Enter Dosage:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        if (dosageCount > 0) dosageCount--;
                      });
                    },
                  ),
                  Text("$dosageCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        dosageCount++;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time Picker
          const Text("Select Time:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          TimePickerSpinner(
            is24HourMode: true,
            normalTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            highlightedTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            spacing: 40,
            itemHeight: 40,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                selectedTime = time;
              });
            },
          ),

          const SizedBox(height: 20),

          // Repeat Dosage Selection
          const Text("Repeat Dosage:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          Wrap(
            spacing: 8,
            children: [
              "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
            ].map((day) {
              return ChoiceChip(
                label: Text(day),
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
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            discardInputs();
            Navigator.pop(context); // Close the dialog without saving
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
}
