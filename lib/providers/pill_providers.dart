import 'package:flutter/material.dart';

class PillProvider with ChangeNotifier {
  Map<String, String> pillNames = {
    "Container A": "Enter Pill Name",
    "Container B": "Enter Pill Name",
    "Container C": "Enter Pill Name",
  };

  Map<String, String> expiryDates = {
    "Container A": "DD|MM|YYYY",
    "Container B": "DD|MM|YYYY",
    "Container C": "DD|MM|YYYY",
  };

  Map<String, int> pillCounts = {
    "Container A": 0,
    "Container B": 0,
    "Container C": 0,
  };

  // New: Dosage and Timings
  Map<String, List<String>> dosageSchedules = {
    "Container A": [], 
    "Container B": [],
    "Container C": [],
  };

  // Update pill details
  void updatePill(String container, String name, String expiryDate, int count) {
    pillNames[container] = name;
    expiryDates[container] = expiryDate;
    pillCounts[container] = count;
    notifyListeners(); 
  }

  // Update pill count safely
  void updatePillCount(String container, int change) {
    if (!pillCounts.containsKey(container)) return; 
    pillCounts[container] =
        (pillCounts[container]! + change).clamp(0, 999); 
    notifyListeners();
  }

  void updateDosageSchedule(String container, List<String> newSchedule) {
    dosageSchedules[container] = newSchedule;
    notifyListeners();
  }
}
