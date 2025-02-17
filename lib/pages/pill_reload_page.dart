import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';
import 'package:intl/intl.dart';

class PillReloadPage extends StatefulWidget {
  const PillReloadPage({super.key});

  @override
  _PillReloadPageState createState() => _PillReloadPageState();
}

class _PillReloadPageState extends State<PillReloadPage> {
  String selectedPill = "Pill A";
  final List<String> pillOptions = ["Pill A", "Pill B", "Pill C"];

  // Pill Selection Button
  Widget _pillButton(PillProvider pillProvider, String pillName) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
  Widget _pillInfo(PillProvider pillProvider) {
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
          _editableRow("Pill Name",
              pillProvider.pillNames[selectedPill] ?? "Enter Pill Name", () {
            _editTextDialog(context, "Pill Name",
                pillProvider.pillNames[selectedPill] ?? "Enter Pill Name",
                (value) {
              pillProvider.updatePill(selectedPill, value,
                  pillProvider.expiryDates[selectedPill] ?? "DD|MM|YYYY", 10);
            });
          }),
          const Divider(color: Colors.teal, thickness: 1),
          _pillCountRow(pillProvider),
          const Divider(color: Colors.teal, thickness: 1),
          _editableRow(
            "Expiry Date",
            pillProvider.expiryDates[selectedPill] ?? "DD|MM|YYYY",
            () => _selectExpiryDate(context, pillProvider),
          ),
        ],
      ),
    );
  }

  // Pill Count Row Widget
  Widget _pillCountRow(PillProvider pillProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              "Number of pills added",
              style: TextStyle(
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
                    pillProvider.updatePillCount(selectedPill, -1);
                  },
                ),
                Text(
                  pillProvider.pillCounts[selectedPill]
                          ?.toString()
                          .padLeft(2, '0') ??
                      "00",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                  onPressed: () {
                    pillProvider.updatePillCount(selectedPill, 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Generic editable row widget
  Widget _editableRow(String title, String value, VoidCallback onTap) {
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
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Edit Text Dialog
  Future<void> _editTextDialog(BuildContext context, String title,
      String initialValue, Function(String) onSave) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Date Picker Dialog
  Future<void> _selectExpiryDate(
      BuildContext context, PillProvider pillProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        String formattedDate = DateFormat('dd|MM|yyyy').format(pickedDate);
        pillProvider.updatePill(
            selectedPill,
            pillProvider.pillNames[selectedPill] ?? "Enter Pill Name",
            formattedDate,
            10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillProvider = Provider.of<PillProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: const Text("RELOAD PILLS"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: pillOptions
                        .map((pill) => _pillButton(pillProvider, pill))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: _pillInfo(pillProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
