import 'package:flutter/foundation.dart'; // For debugPrint()
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final String esp32Url = "http://192.168.1.100"; // Update with ESP32 IP

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
        debugPrint("✅ Schedule sent successfully");
      } else {
        debugPrint("❌ Error sending schedule: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to send schedule: $e");
    }
  }

  /// NEW: Sends dispense command to ESP32 when user confirms pill intake
  Future<void> sendDispenseCommand() async {
    final Uri url = Uri.parse("$esp32Url/dispense");

    try {
      final response = await http.get(Uri.parse("$esp32Url/dispense"));
      if (response.statusCode == 200) {
        print("✅ Pill dispensed successfully!");
      } else {
        debugPrint("❌ Error dispensing pill: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Failed to send dispense command: $e");
    }
  }
}
