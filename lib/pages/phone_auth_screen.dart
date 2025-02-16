import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medicine_dispenser/pages/login_screen.dart';
import 'package:medicine_dispenser/pages/home_page.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isPhoneAuthRequested = false;
  bool isLoading = false;
  String verificationId = "";
  String? errorMessage;

  // 🔹 Send OTP
  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      setState(() => errorMessage = "Phone number cannot be empty");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          errorMessage = e.message;
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          isPhoneAuthRequested = true;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 🔹 Verify OTP
  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      setState(() => errorMessage = "Please enter the OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Invalid OTP. Please try again.";
        isLoading = false;
      });
    }
  }

  // 🔹 Google Sign-In
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Google Sign-In failed.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA6E3E9), Color(0xFF71C9CE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // 🔹 App Logo
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/logo.png"),
              ),

              const SizedBox(height: 20),

              // 🔹 App Tagline
              const Text("MediMate",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              const Text("Your Trusted Partner in Timely Medication.",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),

              const SizedBox(height: 30),

              // 🔹 Phone Number Input
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Phone Number",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Send OTP Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : sendOTP,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text("Send OTP", style: TextStyle(color: Colors.white)),
              ),

              if (isPhoneAuthRequested) ...[
                const SizedBox(height: 10),

                // 🔹 OTP Input
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Enter OTP",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔹 Verify OTP Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isLoading ? null : verifyOTP,
                  child: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
                ),
              ],

              const SizedBox(height: 20),

              // 🔹 Show error messages
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 20),

              // 🔹 OR Divider
              Row(children: [Expanded(child: Divider()), const Text(" OR "), Expanded(child: Divider())]),

              const SizedBox(height: 10),

              // 🔹 Navigate to Email & Password Login
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text("Email & Password Login"),
              ),

              const SizedBox(height: 10),

              // 🔹 OR Divider
              Row(children: [Expanded(child: Divider()), const Text(" OR "), Expanded(child: Divider())]),

              const SizedBox(height: 10),

              // 🔹 Google Sign-In
              OutlinedButton.icon(
                onPressed: isLoading ? null : signInWithGoogle,
                icon: Image.asset("assets/google_icon.png", height: 20),
                label: const Text("Log in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
