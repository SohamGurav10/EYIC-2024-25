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
  DateTime selectedTime = DateTime(0, 0, 0, 0, 0);
  List<String> selectedDays = [];
  final User? user = FirebaseAuth.instance.currentUser;

  void saveDosageToFirestore() async {
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('dosages').add({
        'dosage': dosageCount,
        'time': "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
        'repeatDays': selectedDays,
        'alarmName': "Pills Have been Dispensed, Take the Pill!"
      });
    }
    
    // Example API call using httpService (optional, adapt as needed)
    widget.httpService.sendSchedule("Pill", selectedTime.hour, selectedTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Set New Dosage and Timings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dosage Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Enter Dosage:", style: TextStyle(fontSize: 18)),
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
                  Text("$dosageCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Text("Select Time:", style: TextStyle(fontSize: 18)),
          TimePickerSpinner(
            is24HourMode: true,
            normalTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            highlightedTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          const Text("Repeat Dosage:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
            ].map((day) {
              return ChoiceChip(
                label: Text(day),
                selected: selectedDays.contains(day),
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
            Navigator.pop(context); // Close the dialog without saving
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            saveDosageToFirestore();
            Navigator.pop(context, [dosageCount, selectedTime, selectedDays]); // Return data
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}
