import 'package:dailyskincare/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:dailyskincare/screens/auth_services.dart';
import 'package:dailyskincare/widget/snack_bar.dart';

// void main() => runApp(NotificationPage());

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<Map<String, dynamic>> routines = [
    {
      'title': 'Cleanser - Pagi',
      'days': 'Setiap Hari',
      'time': DateTime.now().add(const Duration(minutes: 1)),
      'status': 'Complete'
    },
    {
      'title': 'Sunscreen - Pagi',
      'days': 'Senin - Jumat',
      'time': DateTime.now().add(const Duration(minutes: 2)),
      'status': 'Complete'
    },
    {
      'title': 'Serum - Malam',
      'days': 'Minggu, Rabu, Jumat',
      'time': DateTime.now().add(const Duration(minutes: 3)),
      'status': 'Complete'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(
      String title, DateTime scheduledTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'routine_channel_id',
      'Routine Notifications',
      channelDescription: 'Notifications for daily skincare routines',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final String curTz = await FlutterTimezone.getLocalTimezone();

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(curTz));

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID
        title,
        'It’s time for your skincare routine!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  void signOutUser() async {
    setState(() {
      isLoading = true; // Menampilkan indikator loading
    });       

    // Memanggil metode signOutUser dari AuthServices
    String res = await AuthServices().signOutUser();

    // Cek hasil logout
    if (res == "Successfully signed out") {
      setState(() {
        isLoading = false;
      });
      // Navigasi kembali ke halaman login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // Menampilkan pesan error jika logout gagal
      showSnackBar(context, res);
    }
  }

  final email = FirebaseAuth.instance.currentUser?.email;
  final name = FirebaseAuth.instance.currentUser?.displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 195, 3, 229),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOutUser, // Fungsi logout
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Profil
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 240, 230, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profil",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text("Nama: $name"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text("Email: $email"),
                    ],
                  ),
                ],
              ),
            ),
            // Bagian Notifikasi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                final remainingTime =
                    routine['time'].difference(DateTime.now());

                // Schedule a notification for each routine
                _scheduleNotification(routine['title'], routine['time']);

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 246, 215, 252),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Color.fromARGB(255, 127, 1, 139),
                      ),
                    ),
                    title: Text(routine['title']),
                    subtitle: Text(
                      'Hari: ${routine['days']}\nWaktu: ${formatTime(routine['time'])} (${remainingTime.inMinutes} minutes left)',
                    ),
                    trailing: Text(routine['status']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
