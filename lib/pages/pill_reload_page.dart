import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PillReloadPage extends StatefulWidget {
  const PillReloadPage({super.key});

  @override
  _PillReloadPageState createState() => _PillReloadPageState();
}

class _PillReloadPageState extends State<PillReloadPage> {
  String selectedPill = "Pill A"; // Default selected pill
  String pillName = "Enter Pill Name";
  int pillCount = 0;
  String expiryDate = "DD|MM|YYYY"; // Default date format

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: const Text("RELOAD PILLS"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA6E3E9), Color(0xFF71C9CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pill Selection Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pillButton("Pill A"),
                  _pillButton("Pill B"),
                  _pillButton("Pill C"),
                ],
              ),
              const SizedBox(height: 30),

              // Pill Information Section (Editable)
              _pillInfo(),

              const Spacer(),

              // Start Reloading Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Handle pill reloading logic
                  },
                  child: const Text(
                    "START RELOADING",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Pill Selection Button
  Widget _pillButton(String pillName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedPill == pillName
              ? Colors.teal.shade700
              : Colors.teal.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedPill = pillName;
          });
        },
        child: Text(
          pillName,
          style: TextStyle(
            color: selectedPill == pillName ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Editable Pill Information Section
  Widget _pillInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _editableRow(
              "Pill Name",
              pillName,
              () => _editTextDialog("Pill Name", pillName, (value) {
                    setState(() {
                      pillName = value;
                    });
                  })),
          const Divider(color: Colors.teal, thickness: 1),
          _pillCountRow("Number of pills added"),
          const Divider(color: Colors.teal, thickness: 1),
          _editableRow("Expiry Date", expiryDate, _selectExpiryDate),
        ],
      ),
    );
  }

  // Editable Text Field Row
  Widget _editableRow(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.teal),
              ),
            ),
            const Icon(Icons.edit_calendar, color: Colors.teal, size: 18),
          ],
        ),
      ),
    );
  }

  // Editable Number Counter for Pills
  Widget _pillCountRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      if (pillCount > 0) pillCount--;
                    });
                  },
                ),
                Text(
                  pillCount.toString().padLeft(2, '0'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      pillCount++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Date Picker Dialog for Expiry Date
  Future<void> _selectExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        expiryDate = DateFormat('dd|MM|yyyy').format(pickedDate);
      });
    }
  }

  // Dialog for Editing Text Fields
  Future<void> _editTextDialog(
      String title, String currentValue, Function(String) onSave) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
