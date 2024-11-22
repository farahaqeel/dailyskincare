import 'package:dailyskincare/screens/auth_services.dart';
import 'package:dailyskincare/widget/bottom_nav_bar.dart';
import 'package:flutter/material.dart';


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
      appBar: AppBar(
        title: const Text(''), // Kosongkan title untuk AppBar atau tambahkan logo kecil jika diperlukan
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Membuat seluruh item berada di tengah secara vertikal
          crossAxisAlignment: CrossAxisAlignment.center, // Membuat item berada di tengah secara horizontal
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 80, // Sesuaikan ukuran gambar
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Daily Skincare!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Menjaga agar teks berada di tengah
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
            
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await AuthServices.signInAnonymously();
                  // Navigate to next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MotionTabBarPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Mengubah bentuk menjadi kotak dengan ujung tumpul
                  ),
                  backgroundColor: const Color.fromARGB(255, 246, 215, 252),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Color.fromARGB(255, 127, 1, 139), // Mengubah warna teks menjadi ungu
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
