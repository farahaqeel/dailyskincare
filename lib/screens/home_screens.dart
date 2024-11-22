import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:intl/intl.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       locale: const Locale('id', 'ID'), // Set the locale to Indonesian
//       supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')], // Add Indonesian to supported locale
//       home: const HomePage(),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;

  // Sample routine data with a 'checked' state
  final List<Map<String, dynamic>> routines = [
    {
      'title': 'Cleanser - Pagi',
      'time': DateTime.now().add(const Duration(hours: 1)),
      'days': ['Monday', 'Wednesday', 'Friday'],
      'checked': false, // Checkbox state
    },
    {
      'title': 'Moisturizer - Pagi',
      'time': DateTime.now().add(const Duration(hours: 2)),
      'days': ['Monday', 'Tuesday'],
      'checked': false,
    },
    {
      'title': 'Sunscreen - Pagi',
      'time': DateTime.now().add(const Duration(hours: 3)),
      'days': ['Everyday'],
      'checked': false,
    },
    {
      'title': 'Serum - Malam',
      'time': DateTime.now().add(const Duration(hours: 12)),
      'days': ['Monday'],
      'checked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 1,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController!.dispose();
    super.dispose();
  }

  // Helper function to format time to 24-hour format
  String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'id_ID').format(time); // Format time in 24-hour format
  }

  // Function to map English day names to Indonesian
  String convertToIndonesianDay(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Senin';
      case 'tuesday':
        return 'Selasa';
      case 'wednesday':
        return 'Rabu';
      case 'thursday':
        return 'Kamis';
      case 'friday':
        return 'Jumat';
      case 'saturday':
        return 'Sabtu';
      case 'sunday':
        return 'Minggu';
      case 'everyday':
        return 'Setiap Hari';
      default:
        return day;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        onDateChanged: (value) => (value),
        firstDate: DateTime.now().subtract(const Duration(days: 140)),
        lastDate: DateTime.now(),
        accent: const Color.fromARGB(255, 195, 3, 229),
        backButton: false,
        locale: 'id_ID', // Set locale for CalendarAppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adding the title "Rutinitas Saya" above the scrollable content
          const Padding(
            padding:  EdgeInsets.all(16.0),
            child: Text(
              'Rutinitas Saya',
              style:  TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:  Color.fromARGB(255, 75, 1, 82),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      final remainingTime = routine['time'].difference(DateTime.now());
                      
                      // Convert days to Indonesian
                      final daysInIndonesian = routine['days']
                          .map<String>((day) => convertToIndonesianDay(day))
                          .toList();

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 246, 215, 252),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: routine['checked'],
                            onChanged: (bool? value) {
                              setState(() {
                                routines[index]['checked'] = value ?? false;
                              });
                            },
                          ),
                          title: Text(routine['title']),
                          subtitle: Text(
                            'Hari: ${daysInIndonesian.join(", ")}\nWaktu: ${formatTime(routine['time'])} '
                            '(${remainingTime.inMinutes} menit tersisa)',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
