import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Sign Up User
  Future<String?> signUpUser(String firstName, String lastName, String email, String phone, String password) async {
    try {
      // Check if email already exists
      final emailCheck = await _auth.fetchSignInMethodsForEmail(email);
      if (emailCheck.isNotEmpty) {
        return "Account using this email ID already exists, try to sign in instead";
      }

      // Check if phone number already exists
      final phoneCheck = await _firestore.collection('users').where('phone', isEqualTo: phone).get();
      if (phoneCheck.docs.isNotEmpty) {
        return "Account using this phone number already exists, try to sign in instead";
      }

      // Create a new user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      // Store additional user info in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'createdAt': DateTime.now(),
      });

      return null; // No error means success
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
