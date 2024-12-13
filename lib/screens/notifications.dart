import 'package:dailyskincare/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyskincare/screens/auth_services.dart';
import 'package:dailyskincare/widget/snack_bar.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // List of routines fetched from Firestore
  List<Map<String, dynamic>> routines = [];

  final User? _user = FirebaseAuth.instance.currentUser;
  final String name = FirebaseAuth.instance.currentUser!.displayName!;
  final String email = FirebaseAuth.instance.currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchIncompleteRoutines(); // Fetch routines from Firestore
  }

  // Initialize notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fetch incomplete routines from Firestore
  void _fetchIncompleteRoutines() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('incompleteRoutines')
          .get();

      List<Map<String, dynamic>> fetchedRoutines = snapshot.docs.map((doc) {
        // Check if 'time' is a Map and parse it
        var timeField = doc['time'];
        DateTime time;

        if (timeField is Map<String, dynamic>) {
          // Construct a DateTime object using hour and minute
          int hour = timeField['hour'] ?? 0;
          int minute = timeField['minute'] ?? 0;

          // Create a DateTime object with the current date and the fetched hour/minute
          time = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            hour,
            minute,
          );
        } else {
          // Handle the case where 'time' is not in the expected format
          time = DateTime.now(); // Default to current time if invalid
          print('Invalid time format for routine: ${doc['title']}');
        }

        return {
          'title': doc['title'],
          'days': doc['days'],
          'time': time,
        };
      }).toList();

      setState(() {
        routines = fetchedRoutines; // Update the routines list
        isLoading = false; // Hide loading indicator
      });

      // Schedule notifications for all routines
      for (var routine in routines) {
        _scheduleNotification(routine['title'], routine['time']);
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator on error
      });
      print('Error fetching routines: $e');
    }
  }


  // Schedule notification for a routine
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
        "It's time for your skincare routine!",
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time); // Format time using DateFormat
  }

  void signOutUser() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Call the signOutUser method from AuthServices
    String res = await AuthServices().signOutUser();

    if (res == "Successfully signed out") {
      setState(() {
        isLoading = false;
      });
      // Navigate to the SignInPage after successful logout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // Show error message if logout fails
      showSnackBar(context, res);
    }
  }

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
            onPressed: signOutUser, // Logout function
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil section
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
            // Notifikasi section
            isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading spinner while fetching data
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      final remainingTime =
                          routine['time'].difference(DateTime.now());

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
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
