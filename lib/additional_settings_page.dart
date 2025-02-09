import 'package:flutter/material.dart';

class AdditionalSettingsPage extends StatelessWidget {
  const AdditionalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade300,
        title: const Text("ADDITIONAL SETTINGS"),
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
              // Add New Pill Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Implement Add New Pill functionality here
                },
                child: const Text(
                  "ADD NEW PILL",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // Reload Pills Section
              _sectionContainer(
                title: "RELOAD PILLS",
                child: Column(
                  children: [
                    _pillReloadHeader(),
                    _pillRow("Pill A", "qq", "A"),
                    _pillRow("Pill B", "rr", "B"),
                    _pillRow("Pill C", "ss", "C"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Update Dosage Section
              _sectionContainer(
                title: "UPDATE DOSAGE/PRESCRIPTION",
                child: Column(
                  children: [
                    _dosageButton("Pill A"),
                    _dosageButton("Pill B"),
                    _dosageButton("Pill C"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Container
  Widget _sectionContainer({required String title, required Widget child}) {
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
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // Pills Header Row
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

  // Pill Row
  Widget _pillRow(String pillName, String remaining, String container) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pillButton(pillName),
          _pillText(remaining),
          _pillText(container),
        ],
      ),
    );
  }

  // Pill Button
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
          // Implement pill selection logic here
        },
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Pill Text Field
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
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Dosage Update Button
  Widget _dosageButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade300,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Implement dosage update logic
        },
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
