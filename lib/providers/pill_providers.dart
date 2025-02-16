import 'package:flutter/material.dart';

class PillProvider with ChangeNotifier {
  Map<String, String> pillNames = {
    "Pill A": "Enter Pill Name",
    "Pill B": "Enter Pill Name",
    "Pill C": "Enter Pill Name",
  };

  Map<String, String> expiryDates = {
    "Pill A": "DD|MM|YYYY",
    "Pill B": "DD|MM|YYYY",
    "Pill C": "DD|MM|YYYY",
  };

  Map<String, int> pillCounts = {
    "Pill A": 0,
    "Pill B": 0,
    "Pill C": 0,
  };

  void updatePill(String pill, String name, String expiryDate, int count) {
    pillNames[pill] = name;
    expiryDates[pill] = expiryDate;
    pillCounts[pill] = count;
    notifyListeners(); // Updates UI in listening widgets
  }

  void updatePillCount(String pill, int change) {
    if (!pillCounts.containsKey(pill)) return; // Ensure pill exists
    pillCounts[pill] =
        (pillCounts[pill]! + change).clamp(0, 999); // Prevent negative values
    notifyListeners();
  }
}
