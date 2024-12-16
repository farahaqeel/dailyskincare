import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

 DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );// Track selected date

  // Helper function to format time
  String formatTime(Map<String, dynamic> timeData) {
    final hour = timeData['hour'] ?? 0;
    final minute = timeData['minute'] ?? 0;
    return DateFormat('HH:mm', 'id_ID').format(
      DateTime(0, 0, 0, hour, minute),
    );
  }

  // Helper function to map day names to Indonesian
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

  // Get routines based on the selected date
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getAllRoutines() {
    if (_user == null) return const Stream.empty();

    final completeStream = _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('completeRoutines')
        .snapshots();

    final incompleteStream = _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('incompleteRoutines')
        .snapshots();

    return completeStream.asyncMap((completeSnapshot) async {

      final incompleteSnapshot = await incompleteStream.first;

      final allRoutines = [
        ...completeSnapshot.docs,
        ...incompleteSnapshot.docs
      ];

    return allRoutines.where((routineDoc) { 
        final data = routineDoc.data();

        final days = data['days'];
        if (days == null) {
          return false;
        }

        // Convert database days to Indonesian day names
        final daysList = (days is List)
            ? days
                .map((day) =>
                    convertToIndonesianDay(day.toString().toLowerCase()))
                .toList()
            : days
                .toString()
                .split(',')
                .map((day) => convertToIndonesianDay(day.trim().toLowerCase()))
                .toList();

        // Get the selected day in Indonesian
        final selectedDay = convertToIndonesianDay(
            DateFormat('EEEE', 'en_US').format(_selectedDate).toLowerCase());

        // Compare using case-insensitive match
        final containsDay = daysList
            .any((day) => day.toLowerCase() == selectedDay.toLowerCase());

        return containsDay;
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        onDateChanged: (value) {
          setState(() {
            _selectedDate = value; // Update the selected date
          });
        },
        firstDate: DateTime.now().subtract(const Duration(days: 140)),
        lastDate: DateTime.now(),
        accent: const Color.fromARGB(255, 127, 1, 139),
        backButton: false,
        locale: 'id_ID', // Set locale for CalendarAppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Rutinitas Saya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 75, 1, 82),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _getAllRoutines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Loading data...");
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print("No routines found.");
                  return const Center(child: Text('Tidak ada rutinitas.'));
                }

                final routines = snapshot.data!;
                print("Displaying ${routines.length} routines.");

                return ListView.builder(
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final data = routines[index].data();
                    print("Routine #$index: $data");

                    final time = data['time'] as Map<String, dynamic>? ?? {};
                    final isComplete = data['isComplete'] as bool? ?? false;

                    final daysInIndonesian = data['days'] is List<dynamic>
                        ? (data['days'] as List<dynamic>)
                            .map<String>((day) => convertToIndonesianDay(day as String))
                            .toList()
                        : data['days'] is String
                            ? [convertToIndonesianDay(data['days'] as String)]
                            : [];

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
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${data['title']} - ${data['period']}'),
                      Checkbox(
                          value: isComplete, // Gunakan isComplete untuk mencerminkan status
                          onChanged: (bool? value) async {
                            if (value == null || _user == null) return;

                            final routineId = routines[index].id;

                            // Perbarui nilai lokal
                            setState(() {
                              data['isComplete'] = value;
                            });

                            // Perbarui di Firestore
                            if (value) {
                              // Pindahkan ke 'completeRoutines'
                              await _firestore
                                  .collection('users')
                                  .doc(_user.uid)
                                  .collection('completeRoutines')
                                  .doc(routineId)
                                  .set({...data, 'isComplete': true}); // Perbarui isComplete menjadi true
                              await _firestore
                                  .collection('users')
                                  .doc(_user.uid)
                                  .collection('incompleteRoutines')
                                  .doc(routineId)
                                  .delete(); // Hapus dari 'incompleteRoutines'
                            } else {
                              // Pindahkan ke 'incompleteRoutines'
                              await _firestore
                                  .collection('users')
                                  .doc(_user.uid)
                                  .collection('incompleteRoutines')
                                  .doc(routineId)
                                  .set({...data, 'isComplete': false}); // Perbarui isComplete menjadi false
                              await _firestore
                                  .collection('users')
                                  .doc(_user.uid)
                                  .collection('completeRoutines')
                                  .doc(routineId)
                                  .delete(); // Hapus dari 'completeRoutines'
                            }
                          },
                        ),

                          ],
                        ),
                        subtitle: Text(
                          'Hari: ${daysInIndonesian.join(", ")}\nWaktu: ${formatTime(time)}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
