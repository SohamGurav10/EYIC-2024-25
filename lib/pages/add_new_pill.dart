import 'package:flutter/material.dart';

class AddPillPage extends StatefulWidget {
  final Map<String, dynamic>? initialPill;

  const AddPillPage({super.key, this.initialPill});

  @override
  _AddPillPageState createState() => _AddPillPageState();
}

class _AddPillPageState extends State<AddPillPage> {
  final TextEditingController _pillNameController = TextEditingController();
  int _pillCount = 1;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPill != null) {
      isEditing = true;
      _pillNameController.text = widget.initialPill!["name"];
      _pillCount = widget.initialPill!["quantity"];

      // Parse the time string to TimeOfDay
      final timeStr = widget.initialPill!["time"];
      if (timeStr != null) {
        final timeParts = timeStr.toLowerCase().split(' ');
        final time = timeParts[0].split(':');
        int hour = int.parse(time[0]);
        final minute = int.parse(time[1]);

        // Convert to 24-hour format if needed
        if (timeParts[1] == 'pm' && hour != 12) {
          hour += 12;
        } else if (timeParts[1] == 'am' && hour == 12) {
          hour = 0;
        }

        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _handleSavePill() {
    String pillName = _pillNameController.text.trim();
    if (pillName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a pill name')),
      );
      return;
    }

    Navigator.pop(context, {
      "name": pillName,
      "time": _selectedTime.format(context),
      "quantity": _pillCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: Text(isEditing ? "EDIT PILL" : "ADD NEW PILL"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA6E3E9), Color(0xFF71C9CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pill Name:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _pillNameController,
              decoration: InputDecoration(
                hintText: "Enter Pill Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    "Number of pills to take per day:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            if (_pillCount > 1) _pillCount--;
                          });
                        },
                      ),
                      Text(
                        _pillCount.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _pillCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Time:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickTime,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                        ),
                        child: const Text(
                          "CHANGE TIME",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _handleSavePill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEditing ? "SAVE CHANGES" : "ADD PILL",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pillNameController.dispose();
    super.dispose();
  }
}
