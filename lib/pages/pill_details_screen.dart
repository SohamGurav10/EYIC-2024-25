import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_dispenser/pages/pill_reload_page.dart';
import 'package:medicine_dispenser/pages/load_new_pills_screen.dart';
import 'package:medicine_dispenser/pages/set_dosage_and_timings.dart';
import 'package:medicine_dispenser/services/http_service.dart';

class PillDetailsScreen extends StatefulWidget {
  const PillDetailsScreen({super.key});

  @override
  _PillDetailsScreenState createState() => _PillDetailsScreenState();
}

class _PillDetailsScreenState extends State<PillDetailsScreen> {
  String selectedContainer = "A"; // Default container selection
  final HttpService httpService = HttpService();
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String pillName = "Enter Pill Name";
  String pillQuantity = "0 Remaining";
  String pillExpiryDate = "DD|MM|YYYY";
  List<String> dosageTimings = [];

  @override
  void initState() {
    super.initState();
    fetchPillData(selectedContainer);
  }

  void fetchPillData(String container) async {
    if (user == null) return;
    
    setState(() => isLoading = true);

    try {
      DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pills')
          .doc(container)
          .get();

      if (doc.exists) {
        setState(() {
          pillName = doc['pillName'] ?? "Enter Pill Name";
          pillQuantity = "${doc['pillQuantity'] ?? 0} Remaining";
          pillExpiryDate = doc['expiryDate'] ?? "DD|MM|YYYY";
          
          // ✅ Correctly fetch dosageTimings (List of Maps)
          var fetchedDosage = doc['dosageTimings'] as List<dynamic>?;

          if (fetchedDosage != null) {
            dosageTimings = fetchedDosage.map((item) {
              return "${item['dosage']} Pills at ${item['time']} on ${item['repeatDays'].join(", ")}";
            }).toList();
          } else {
            dosageTimings = [];
          }
        });
      } else {
        setState(() {
          pillName = "Enter Pill Name";
          pillQuantity = "0 Remaining";
          pillExpiryDate = "DD|MM|YYYY";
          dosageTimings = [];
        });
      }
    } catch (e) {
      print("Error fetching pill data: $e");
    }

    setState(() => isLoading = false);
  }

void removeDosage(String doseToRemove) async {
  if (user == null) return;

  try {
    DocumentSnapshot doc = await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pills')
        .doc(selectedContainer)
        .get();

    if (!doc.exists) return;

    List<dynamic> existingDosages = doc['dosageTimings'] ?? [];

    // Convert the string back to a map to match Firestore structure
    Map<String, dynamic>? dosageToRemove;

    for (var item in existingDosages) {
      String formattedDosage =
          "${item['dosage']} Pills at ${item['time']} on ${item['repeatDays'].join(", ")}";
      if (formattedDosage == doseToRemove) {
        dosageToRemove = item;
        break;
      }
    }

    if (dosageToRemove != null) {
      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pills')
          .doc(selectedContainer)
          .update({
        'dosageTimings': FieldValue.arrayRemove([dosageToRemove])
      });

      setState(() {
        dosageTimings.remove(doseToRemove); // Remove from UI
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dosage removed successfully!")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error removing dosage: $e")),
    );
  }
}


  void openSetDosagePopup() async {
    if (selectedContainer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a container first.")),
      );
      return;
    }

    final result = await showDialog<List<String>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return SetDosageAndTimings(
          httpService: httpService,
          container: selectedContainer,
          sourceScreen: "pill_details_screen",
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        dosageTimings = result;
      });

      try {
        await firestore
            .collection('users')
            .doc(user!.uid)
            .collection('pills')
            .doc(selectedContainer)
            .update({'dosageTimings': dosageTimings});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating Firestore: $e")),
        );
      }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _containerButton("A"),
                  _containerButton("B"),
                  _containerButton("C"),
                ],
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : _infoSection(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton("LOAD NEW PILLS", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoadNewPillsScreen(httpService: httpService)),
                    );
                  }),
                  _actionButton("RELOAD PILLS", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PillReloadPage()),
                    );
                  }),
                  _actionButton("CLOSE", () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _containerButton(String container) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedContainer == container
              ? Colors.teal.shade700
              : Colors.teal.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedContainer = container;
            fetchPillData(container);
          });
        },
        child: Text(
          "Container $container",
          style: TextStyle(
            color: selectedContainer == container ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoSection() {
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
        _infoRow("Pill Name", pillName),
        const Divider(color: Colors.teal, thickness: 1),
        _infoRow("Pill Quantity Remaining", pillQuantity),
        const Divider(color: Colors.teal, thickness: 1),
        _infoRow("Expiry Date", pillExpiryDate),
        const Divider(color: Colors.teal, thickness: 1),
        _dosageRow(),
      ],
    ),
  );
}

  Widget _dosageRow() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Dosage & Timings",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      dosageTimings.isNotEmpty
          ? Column(
              children: dosageTimings.map((dose) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dose,
                          style: const TextStyle(fontSize: 14, color: Colors.teal),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeDosage(dose), // Call remove function
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          : const Text("No Dosage Set",
              style: TextStyle(fontSize: 14, color: Colors.red)),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: openSetDosagePopup,
        child: const Text("ADD NEW"),
      ),
    ],
  );
}


  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}