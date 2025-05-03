import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Email/Password Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    }
  }

  // Registration with Firestore profile creation
  Future<User?> register(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'score': 0,
          'photoUrl': null,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    }
  }

  // Password Reset
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    }
  }

  // Google Sign-In with Firestore user check
  Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user == null) return null;

    // If user is new, create Firestore profile
    if (userCredential.additionalUserInfo?.isNewUser == true) {
      final generatedUsername = user.displayName ??
          'GuestUser_${user.uid.substring(0, 4)}'; // Fallback username

      await _firestore.collection('users').doc(user.uid).set({
        'username': generatedUsername,
        'email': user.email ?? '',
        'score': 0,
        'photoUrl': user.photoURL,
      });
    }

    return user;
  } on FirebaseAuthException catch (e) {
    throw handleAuthError(e);
  }
}


  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Error Handling
  String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'Account disabled';
      case 'user-not-found':
        return 'No account found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'operation-not-allowed':
        return 'Email/password not enabled';
      case 'weak-password':
        return 'Password too weak';
      case 'too-many-requests':
        return 'Too many attempts';
      case 'network-request-failed':
        return 'Network error';
      default:
        return 'Login failed: ${e.message}';
    }
  }

  // Current User
  User? get currentUser => _auth.currentUser;
}
