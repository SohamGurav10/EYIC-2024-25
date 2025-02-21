import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final String esp32Url = "http://192.168.1.100"; // Update with ESP32 IP

  /// Checks if ESP32 is reachable
  Future<bool> checkConnection() async {
    try {
      final Uri url = Uri.parse("$esp32Url/ping");
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        debugPrint("✅ ESP32 is online.");
        return true;
      } else {
        debugPrint("❌ ESP32 connection failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Could not connect to ESP32: $e");
      return false;
    }
  }

  /// Sends pill schedule to ESP32
  Future<void> sendSchedule(String pill, int hour, int minute) async {
    final Uri url = Uri.parse("$esp32Url/schedule");

    final Map<String, dynamic> data = {
      "pill": pill,
      "hour": hour,
      "minute": minute
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Schedule for $pill at $hour:$minute sent successfully.");
      } else {
        debugPrint("❌ Failed to send schedule (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Error sending schedule: $e");
    }
  }

  /// Sends a command to load new pills into a container
  Future<void> sendLoadPillCommand(
      String userId,
      String container,
      String pillName,
      String pillQuantity,
      String pillExpiryDate,
      List<String> dosageTimings) async {
    final Uri url = Uri.parse("$esp32Url/load_pill");

    final Map<String, dynamic> data = {
      "user_id": userId,
      "container": container,
      "pill_name": pillName,
      "quantity": pillQuantity,
      "expiry_date": pillExpiryDate,
      "dosage_timings": dosageTimings,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Pills loaded successfully into container $container.");
      } else {
        debugPrint("❌ Failed to load pills (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Error loading pills: $e");
    }
  }

  /// Sends dispense command to ESP32 when user confirms pill intake
  Future<void> sendDispenseCommand() async {
    final Uri url = Uri.parse("$esp32Url/dispense");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        debugPrint("✅ Pill dispensed successfully.");
      } else {
        debugPrint("❌ Error dispensing pill (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to send dispense command: $e");
    }
  }
}
