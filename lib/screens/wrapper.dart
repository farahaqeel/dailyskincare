import 'package:dailyskincare/screens/home_screens.dart';
import 'package:dailyskincare/screens/get_started.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan user dari Provider
    User? firebaseUser = Provider.of<User?>(context);
    return (firebaseUser == null) ? const GetStartedPage() : const HomePage();
  }
}