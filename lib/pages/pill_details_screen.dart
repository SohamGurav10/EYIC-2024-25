import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/add_new_pill.dart';
import 'package:medicine_dispenser/pages/pill_reload_page.dart';
import 'package:medicine_dispenser/pages/additional_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';

class PillDetailsPage extends StatefulWidget {
  const PillDetailsPage({super.key});

  @override
  _PillDetailsPageState createState() => _PillDetailsPageState();
}

class _PillDetailsPageState extends State<PillDetailsPage> {
  List<Map<String, dynamic>> pills = [
    {"name": "Add Pill", "time": "08:00 AM", "quantity": 1},
    {"name": "Add Pill", "time": "08:00 AM", "quantity": 1},
    {"name": "Add Pill", "time": "08:00 AM", "quantity": 1},
  ];
  int pillIndex = 0;

  Future<void> _navigateToAddPill() async {
    if (pillIndex >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 pills can be added')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPillPage()),
    );

    if (result != null && mounted) {
      setState(() {
        pills[pillIndex] = {
          "name": result["name"],
          "time": result["time"],
          "quantity": result["quantity"],
        };
        pillIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: const Text("PILL DETAILS"),
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
            children: [
              _sectionContainer(
                title: "PILL RELOAD",
                child: Column(
                  children: [
                    _pillReloadHeader(),
                    _pillRow(pills[0]["name"], "Remaining Qty: 10", "A"),
                    _pillRow(pills[1]["name"], "Remaining Qty: 10", "B"),
                    _pillRow(pills[2]["name"], "Remaining Qty: 10", "C"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _navigateToAddPill,
                child: const Text(
                  "ADD NEW PILL",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pill Information Section (NON-EDITABLE)
  Widget _infoSection(BuildContext context, String pill) {
    var pillProvider = Provider.of<PillProvider>(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // Get Dosage & Timings as a formatted string
  String _getDosageDetails(PillProvider pillProvider, String container) {
    List<String>? dosages = pillProvider.dosageSchedules[container];
    if (dosages == null || dosages.isEmpty) {
      return "Not Set";
    }
    
    String formattedDosages = dosages.map((dose) => "• $dose").join("\n");
    return formattedDosages;
  }

  Widget _pillReloadHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(
            child: Text("Pill Name",
                style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
            child: Text("Pills Remaining",
                style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
            child: Text("Container Name",
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _pillRow(String pillName, String remaining, String container) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          _pillButton(pillName),
          _pillText(remaining),
          _pillText(container),
        ],
      ),
    );
  }

  Widget _pillButton(String text) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade300,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PillReloadPage()));
        },
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _pillText(String text) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.shade300),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
