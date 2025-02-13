import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Register a new user with Email & Password
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'The password is too weak.';
      if (e.code == 'email-already-in-use') return 'Email is already in use.';
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // 🔹 Login with Email & Password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No user found with this email.';
      if (e.code == 'wrong-password') return 'Incorrect password.';
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // 🔹 Google Sign-In Authentication
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Google Sign-In was canceled.';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google Sign-In failed.';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // 🔹 Sign Out (for both Google & Email authentication)
  Future<void> signOutUser() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // 🔹 Get the current signed-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 🔹 Listen for authentication state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
