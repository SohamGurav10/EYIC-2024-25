import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine_dispenser/pages/login_screen.dart';
import 'package:medicine_dispenser/pages/home_screen.dart';
import 'package:medicine_dispenser/pages/pill_details_screen.dart';
import 'package:medicine_dispenser/pages/additional_settings_page.dart';
import 'package:medicine_dispenser/pages/signup_screen.dart';
import 'package:medicine_dispenser/pages/alarm_screen.dart';
import 'package:medicine_dispenser/pages/load_new_pills_screen.dart';
// import 'package:medicine_dispenser/pages/set_dosage_and_timings.dart';
import 'package:medicine_dispenser/providers/pill_providers.dart';
import 'package:medicine_dispenser/services/http_service.dart';
import 'firebase_options.dart';

// Initialize Local Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background Notification Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  showFullScreenAlarm(message.notification?.title, message.notification?.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _configureFirebaseListeners();
    _getToken();
  }

  Future<void> _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $token");
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == "alarm_screen") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AlarmScreen()),
          );
        }
      },
    );
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFullScreenAlarm(
          message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AlarmScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine Dispenser',
      theme: ThemeData(primarySwatch: Colors.teal),
      // home: LoadNewPillsScreen(httpService: httpService), // Fixed httpService passing
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(), // Fixed
        '/pill_details': (context) => const PillDetailsScreen(),
        '/additional_settings': (context) => const AdditionalSettingsPage(),
        '/signup': (context) => const SignupPage(),
        '/alarm': (context) => const AlarmScreen(),
        '/scheduler': (context) => PillScheduler(httpService: httpService),
        '/load_new_pills': (context) => LoadNewPillsScreen(httpService: httpService), 
      },
    );
  }
}

// Function to Show Full-Screen Alarm
void showFullScreenAlarm(String? title, String? body) {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Medicine Alarm',
    channelDescription: 'Channel for medicine alarms',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  flutterLocalNotificationsPlugin.show(
    0,
    title ?? "Time to Take Your Medicine",
    body ?? "Swipe to Snooze or Dispense",
    notificationDetails,
    payload: "alarm_screen",
  );
}

// Pill Scheduler UI
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
          "Selected Time: ${selectedTime.hour}:${selectedTime.minute}",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
