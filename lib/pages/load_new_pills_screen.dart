import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:medicine_dispenser/pages/pill_details_screen.dart';
import 'package:medicine_dispenser/pages/set_dosage_and_timings.dart';
import 'package:medicine_dispenser/services/http_service.dart';

class LoadNewPillsScreen extends StatefulWidget {
  final HttpService httpService;

  const LoadNewPillsScreen({super.key, required this.httpService});

  @override
  _LoadNewPillsScreenState createState() => _LoadNewPillsScreenState();
}

class _LoadNewPillsScreenState extends State<LoadNewPillsScreen> {
  String? selectedContainer;
  String pillName = "";
  String pillQuantity = "";
  String pillExpiryDate = "";
  List<String> dosageTimings = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool containerHasData = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadPillData(String container) async {
    if (user == null) return;

    setState(() => isLoading = true);

    DocumentSnapshot doc = await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pills')
        .doc(container)
        .get();

    if (doc.exists) {
      setState(() {
        pillName = doc['pillName'];
        pillQuantity = doc['pillQuantity'];
        pillExpiryDate = doc['expiryDate'];
        dosageTimings = List<String>.from(doc['dosageTimings']);
        containerHasData = true;
      });
    } else {
      setState(() {
        pillName = "";
        pillQuantity = "";
        pillExpiryDate = "";
        dosageTimings = [];
        containerHasData = false;
      });
    }

    setState(() => isLoading = false);
  }

  bool canSavePill() {
    return selectedContainer != null &&
        pillName.isNotEmpty &&
        pillQuantity.isNotEmpty &&
        pillExpiryDate.isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        pillExpiryDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void savePill() async {
    if (!canSavePill() || user == null) return;

    setState(() => isLoading = true);

    try {
      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('pills')
          .doc(selectedContainer!)
          .set({
        'pillName': pillName,
        'pillQuantity': pillQuantity,
        'expiryDate': pillExpiryDate,
        'dosageTimings': dosageTimings,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pill successfully saved!")),
      );

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving pill: $e")),
      );
    }
  }

  void openSetDosagePopup() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return SetDosageAndTimings(httpService: widget.httpService);
      },
    );

    if (result != null) {
      setState(() {
        dosageTimings = result;
      });
    }
  }

  void removeDosage(String timing) {
    setState(() {
      dosageTimings.remove(timing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Light sky blue background
      appBar: AppBar(
        title: const Text("Load New Pills", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PillDetailsScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select a Container", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ["A", "B", "C"].map((container) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedContainer == container ? Colors.teal[700] : Colors.teal[300],
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedContainer = container;
                          });
                          loadPillData(container);
                        },
                        child: Text("Container $container", style: const TextStyle(fontSize: 18, color: Colors.white)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  if (selectedContainer != null)
                    containerHasData
                        ? _buildPillDetails()
                        : _buildPillInputFields(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildPillDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pill Name: $pillName"),
        Text("Quantity: $pillQuantity"),
        Text("Expiry Date: $pillExpiryDate"),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: () => setState(() => containerHasData = false),
          child: const Text("CHANGE PILLS"),
        ),
      ],
    );
  }

  Widget _buildPillInputFields() {
    return Column(
      children: [
        _buildInputField("Pill Name", (value) => setState(() => pillName = value)),
        _buildInputField("Pill Quantity", (value) => setState(() => pillQuantity = value), isNumeric: true),
        _buildDateInputField(),
        _buildDosageAndTimings(),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: canSavePill() ? savePill : null,
          child: const Text("LOAD PILLS"),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, Function(String) onChanged, {bool isNumeric = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateInputField() {
    TextEditingController dateController = TextEditingController(text: pillExpiryDate);

    return GestureDetector(
      onTap: () async {
        await _selectDate(context);
        dateController.text = pillExpiryDate;
      },
      child: AbsorbPointer(
        child: _buildInputField("Expiry Date", (_) {}, controller: dateController),
      ),
    );
  }

  Widget _buildDosageAndTimings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Dosage and Timings:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: openSetDosagePopup,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
