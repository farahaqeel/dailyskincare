import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // static final GoogleSignIn _googleSignIn = GoogleSignIn();

  //for signup
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Register user in Firebase Auth with email and password
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Update the user's display name in Firebase Auth
        await credential.user!.updateDisplayName(name);

        // Add user data to Cloud Firestore
        await _firestore.collection("users").doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': credential.user!.uid,
        });

        res = "Successfully";
      } else {
        res = "Please fill in all fields";
      }
    } catch (e) {
      print(e.toString());
      res = e.toString();
    }
    return res;
  }

  //sign in user
  Future<String> signInUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      // Validasi input tidak kosong
      if (email.isNotEmpty && password.isNotEmpty) {
        // Autentikasi pengguna dengan Firebase
        UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Cek jika autentikasi berhasil
        if (credential.user != null) {
          res = "Successfully signed in";
        }
      } else {
        res = "Please fill in all fields";
      }
    } catch (e) {
      // Menangkap kesalahan dan mencetak ke log
      print(e.toString());
      res = e.toString();
    }
    return res;
  }

  //log out user
  Future<String> signOutUser() async {
  String res = "Some error occurred";
  try {
    // Proses logout dengan Firebase
    await _auth.signOut();
    res = "Successfully signed out";
  } catch (e) {
    // Menangkap kesalahan dan mencetak ke log
    print(e.toString());
    res = e.toString();
  }
  return res;
}



  // Sign in Anonymously
  static Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? firebaseUser = userCredential.user;
      print("Signed in anonymously: ${firebaseUser?.uid}");
      return firebaseUser;
    } catch (e) {
      print("Error signing in anonymously: $e");
      return null;
    }
  }

  // Sign in with Google
  // static Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     // Trigger the Google Sign-In flow
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       print("Google sign-in aborted by user.");
  //       return null; // User canceled the sign-in process
  //     }

  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //     // Create a new credential
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Sign in to Firebase with the Google credential
  //     UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     print("Google sign-in successful: ${userCredential.user?.email}");

  //     // Return the user credential
  //     return userCredential;
  //   } catch (e) {
  //     print("Error signing in with Google: $e");
  //     return null;
  //   }
  // }

  // Firebase User Stream
  static Stream<User?> get firebaseUserStream => _auth.authStateChanges();
}