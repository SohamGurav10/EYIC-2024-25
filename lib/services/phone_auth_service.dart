import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = "";
  String? _errorMessage; // Store error messages here

  // 🔹 Send OTP
  Future<String?> sendOTP(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      return "Phone number cannot be empty.";
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            _errorMessage = "The phone number is not valid.";
          } else if (e.code == 'quota-exceeded') {
            _errorMessage = "SMS quota exceeded. Try again later.";
          } else {
            _errorMessage = e.message ?? "Verification failed.";
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return _errorMessage; // Return error message if there was an issue
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // 🔹 Verify OTP
  Future<String?> verifyOTP(String smsCode) async {
    if (smsCode.isEmpty) {
      return "Please enter the OTP.";
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode.trim(),
      );

      await _auth.signInWithCredential(credential);
      return null; // Success, return no error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return "Invalid OTP. Please try again.";
      } else if (e.code == 'session-expired') {
        return "OTP expired. Please request a new one.";
      }
      return e.message ?? "Verification failed.";
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // 🔹 Resend OTP
  Future<String?> resendOTP(String phoneNumber) async {
    return await sendOTP(phoneNumber); // Calls sendOTP method again
  }

  // 🔹 Sign Out
  Future<String?> signOutUser() async {
    try {
      await _auth.signOut();
      return null; // Success
    } catch (e) {
      return "Error signing out: $e";
    }
  }

  // 🔹 Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
