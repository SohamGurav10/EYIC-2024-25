import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medicine_dispenser/pages/home_page.dart';
import 'package:medicine_dispenser/pages/phone_auth_screen.dart';
import 'package:medicine_dispenser/pages/signup_screen.dart';
import 'package:medicine_dispenser/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? errorMessage;
  bool isLoading = false;

  // 🔹 Navigate to Home Screen
  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // 🔹 Email/Password Login
  Future<void> signInWithEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => errorMessage = "Email and password cannot be empty");
      return;
    }

    setState(() => isLoading = true);

    final String? error = await _authService.signInWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (error == null) {
      navigateToHome();
    } else {
      setState(() {
        errorMessage = error;
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      navigateToHome();
    } catch (e) {
      setState(() {
        errorMessage = "Google Sign-In failed.";
        isLoading = false;
      });
    }
  }

  // 🔹 Phone Authentication (OTP)
  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      setState(() => errorMessage = "Phone number cannot be empty");
      return;
    }

    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
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

      await FirebaseAuth.instance.signInWithCredential(credential);
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

              // 🔹 Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(onPressed: () {}, child: const Text("Forgot Password?")),

              // 🔹 Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isLoading ? null : signInWithEmail,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text("Log in",
                        style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 20),

              // 🔹 Phone Authentication Section
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

              ElevatedButton(
                onPressed: isLoading ? null : sendOTP,
                child: const Text("Send OTP"),
              ),

              if (isPhoneAuthRequested) ...[
                const SizedBox(height: 10),
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
                ElevatedButton(onPressed: isLoading ? null : verifyOTP, child: const Text("Verify OTP")),
              ],

              const SizedBox(height: 20),

              // 🔹 Google Sign-In Button
              OutlinedButton.icon(
                onPressed: isLoading ? null : signInWithGoogle,
                icon: Image.asset("assets/google_icon.png", height: 20),
                label: const Text("Log in with Google"),
              ),

              const SizedBox(height: 20),

              // 🔹 Sign Up Button (New)
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "New to MediMate? Sign Up instead",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
