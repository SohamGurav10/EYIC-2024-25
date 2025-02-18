import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicine_dispenser/pages/login_screen.dart';
import 'package:medicine_dispenser/pages/home_page.dart';
import 'package:medicine_dispenser/pages/pill_details_screen.dart';
import 'package:medicine_dispenser/pages/additional_settings_page.dart';
import 'package:medicine_dispenser/pages/signup_screen.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:medicine_dispenser/http_services.dart'; // Ensure correct file name

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PillProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HttpService httpService = HttpService();
  String selectedPill = "Pill A";
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        // Automatically send update when time is picked
        httpService.sendSchedule(
            selectedPill, selectedTime.hour, selectedTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine Dispenser',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/pill_details': (context) => const PillDetailsPage(),
        '/additional_settings': (context) => const AdditionalSettingsPage(),
        '/signup': (context) => const SignupPage(),
        '/scheduler': (context) => PillScheduler(httpService: httpService),
      },
    );
  }
}

class PillScheduler extends StatelessWidget {
  final HttpService httpService;

  const PillScheduler({super.key, required this.httpService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pill Dispenser Scheduler')),
      body: PillSchedulerBody(httpService: httpService),
    );
  }
}

class PillSchedulerBody extends StatefulWidget {
  final HttpService httpService;

  const PillSchedulerBody({super.key, required this.httpService});

  @override
  _PillSchedulerBodyState createState() => _PillSchedulerBodyState();
}

class _PillSchedulerBodyState extends State<PillSchedulerBody> {
  String selectedPill = "Pill A";
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.httpService
            .sendSchedule(selectedPill, selectedTime.hour, selectedTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: selectedPill,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedPill = newValue;
                widget.httpService.sendSchedule(
                    selectedPill, selectedTime.hour, selectedTime.minute);
              });
            }
          },
          items: <String>['Pill A', 'Pill B', 'Pill C']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: const Text("Select Time"),
        ),
        const SizedBox(height: 10),
        Text(
          "Selected Time: \${selectedTime.hour}:\${selectedTime.minute}",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
