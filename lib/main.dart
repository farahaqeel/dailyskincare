import 'package:dailyskincare/screens/get_started.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:dailyskincare/screens/get_started.dart';
// import 'package:dailyskincare/widget/bottom_bar.dart'; // Import your BottomBar widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA_hvIbEQHuHTYciI6YTsYMwVP9eZ3cCVI',
      appId: '1:155642764344:android:f8559a8cba58900906dacd',
      messagingSenderId: '155642764344',
      projectId: 'dailyskincare-38173',
    ),
  );
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const GetStarted(), // Set the BottomBar as the home widget
    );
  }
}
