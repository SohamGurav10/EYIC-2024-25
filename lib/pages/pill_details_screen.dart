import 'package:flutter/material.dart';
import 'package:medicine_dispenser/pages/pill_reload_page.dart';
import 'package:medicine_dispenser/pages/additional_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';

class PillDetailsScreen extends StatefulWidget {
  const PillDetailsScreen({super.key});

  @override
  _PillDetailsScreenState createState() => _PillDetailsScreenState();
}

class _PillDetailsScreenState extends State<PillDetailsScreen> {
  String selectedContainer = "Container A"; // Default container selection

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
              _pillReloadSection(),
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

  Widget _pillReloadSection() {
    return Column(
      children: [
        _pillReloadHeader(),
        for (var pill in pills)
          _pillRow(pill["name"]!, "Remaining Qty: ${pill["remaining"]}",
              pill["container"]!),
      ],
    );
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
