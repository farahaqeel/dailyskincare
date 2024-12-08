import 'package:flutter/material.dart';
import 'package:dailyskincare/screens/sign_in.dart';
import 'package:dailyskincare/screens/sign_up.dart';

void main() {
  runApp(const GetStarted());
}

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GetStartedPage(),
    );
  }
}

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten secara vertikal
          children: [
            Image.asset(
              'assets/logo.png', // Ganti dengan path logo Anda
              height: 100, // Sesuaikan ukuran logo
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Daily Skincare!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),


            const SizedBox(height: 20),
            const Text(
              'Your personalized skincare routine starts here. Follow these steps to get started:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center, // Menjaga agar teks berada di tengah
            ),
            const SizedBox(height: 20),

              // Modifikasi ListTile untuk di tengah
            const Align(
              alignment: Alignment.center, // Memusatkan ListTile
              child: Row(
                mainAxisSize: MainAxisSize.min, // Meminimalkan ukuran Row agar sesuai konten
                children: [
                  Icon(Icons.water_drop),
                  SizedBox(width: 10), // Spasi antara ikon dan teks
                  Text('Step 1: Choose your skin type'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center, // Memusatkan ListTile
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 10),
                  Text('Step 2: Set your routine schedule'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center, // Memusatkan ListTile
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done),
                  SizedBox(width: 10),
                  Text('Step 3: Track your progress'),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Aksi tombol Sign Up
                    Navigator.push(
                      context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 127, 1, 139),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Aksi tombol Sign In
                    Navigator.push(
                      context,
                    MaterialPageRoute(builder: (context) => const SignInPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 127, 1, 139),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
