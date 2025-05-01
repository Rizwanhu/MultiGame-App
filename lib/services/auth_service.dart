import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login with email/password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // Register with email/password
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'invalid-email': return 'Invalid email format';
      case 'user-disabled': return 'Account disabled';
      case 'user-not-found': return 'No account found';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'Email already registered';
      case 'weak-password': return 'Password must be 6+ characters';
      default: return 'Login failed. Please try again.';
    }
  }
}