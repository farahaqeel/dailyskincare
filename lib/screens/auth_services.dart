import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? firebaseUser = userCredential.user;
      return firebaseUser;
    } catch (e) {
      print("Error signing in anonymously: $e");
      return null;
    }
  }

  static Future<void> signOut() async{
    _auth.signOut();
  }

  static Stream<User?> get firebaseUserStream => _auth.authStateChanges();
}