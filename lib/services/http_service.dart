import 'package:flutter/foundation.dart'; // For debugPrint()
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final String esp32Url = "http://192.168.1.100"; // Update with your ESP32 IP

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
        debugPrint("Schedule sent successfully"); // Replaces print()
      } else {
        debugPrint("Error sending schedule: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Failed to send schedule: $e");
    }
  }
}