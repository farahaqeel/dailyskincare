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

  DateTime _selectedDate = DateTime.now(); // Track selected date

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

      // Filter routines based on the selected date
      return allRoutines.where((routineDoc) {
        final data = routineDoc.data();
        final days = data['days'] is List<dynamic>
            ? (data['days'] as List<dynamic>)
                .map<String>((day) => convertToIndonesianDay(day as String))
                .toList()
            : [convertToIndonesianDay(data['days'] as String)];

        // Check if the selected date matches any of the routine days
        return days.contains(DateFormat('EEEE', 'id_ID').format(_selectedDate));
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
            child: StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _getAllRoutines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada rutinitas.'));
                }

                final routines = snapshot.data!;

                return ListView.builder(
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final data = routines[index].data();
                    final time = data['time'] as Map<String, dynamic>? ?? {};
                    final isComplete = data['isComplete'] as bool? ??
                        false; // Default ke false

                    final daysInIndonesian = data['days'] is List<dynamic>
                        ? (data['days'] as List<dynamic>)
                            .map<String>(
                                (day) => convertToIndonesianDay(day as String))
                            .toList()
                        : data['days'] is String
                            ? [convertToIndonesianDay(data['days'] as String)]
                            : [];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
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
                              value: isComplete,
                              onChanged: (bool? value) async {
                                if (value == null || _user == null) return;

                                final routineDoc = _firestore
                                    .collection('users')
                                    .doc(_user.uid)
                                    .collection('incompleteRoutines')
                                    .doc(routines[index].id);

                                if (value) {
                                  // Pindahkan dokumen ke completeRoutines
                                  final routineData = await routineDoc.get();
                                  await _firestore
                                      .collection('users')
                                      .doc(_user.uid)
                                      .collection('completeRoutines')
                                      .doc(routines[index].id)
                                      .set(routineData.data()!);

                                  // Hapus dari incompleteRoutines
                                  await routineDoc.delete();
                                } else {
                                  // Update isComplete jika dibatalkan
                                  await routineDoc
                                      .update({'isComplete': value});
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
