import 'package:flutter/material.dart';
import 'package:dailyskincare/screens/add_routine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // late String _task;
  late User? _user;

  final List<Map<String, dynamic>> _incompleteRoutines = [
    {'title': 'Cleanser ', 'Period': ' Pagi', 'time': TimeOfDay(hour: 8, minute: 0), 'days': 'Senin'},
    {'title': 'Moisturizer ', 'Period': ' Pagi', 'time': const TimeOfDay(hour: 8, minute: 30), 'days': 'Selasa'}
  ];
  final List<Map<String, dynamic>> _completeRoutines = [
    {'title': 'Sunscreen ', 'Period': ' Pagi', 'time': TimeOfDay(hour: 9, minute: 0), 'days': 'Senin'},
    {'title': 'Serum ', 'Period': 'Malam', 'time': TimeOfDay(hour: 21, minute: 0), 'days': 'Minggu'}
  ];

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _activityName = ''; // Declare _activityName
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedPeriod; // For period selection
  String? _selectedDay; // For day selection

  TabController? _tabController;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }



  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

     Future<void> _signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      setState(() {
        _user = userCredential.user;
      });
    } catch (e) {
      print("Error signing in anonymously: $e");
    }
  }

  // Membaca data dari Firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> _getRoutines(bool isComplete) {
    return _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection(isComplete ? 'completeRoutines' : 'incompleteRoutines')
        .snapshots();
  }

 // Fungsi untuk menambahkan rutinitas ke Firestore
  Future<void> _addRoutine(String title, String period, TimeOfDay time, String days, bool isComplete) async {
    await _firestore.collection('users').doc(_user?.uid).collection(isComplete ? 'completeRoutines' : 'incompleteRoutines').add({
      'title': title,
      'period': period,
      'time': {'hour': time.hour, 'minute': time.minute},
      'days': days,
    });
  }

 // Mengedit data di Firestore
  Future<void> _updateRoutine(
      String docId, String title, String period, TimeOfDay time, String day, bool isComplete) async {
    await _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection(isComplete ? 'completeRoutines' : 'incompleteRoutines')
        .doc(docId)
        .update({
      'title': title,
      'period': period,
      'time': {'hour': time.hour, 'minute': time.minute},
      'days': day,
    });
  }

// Menghapus data dari Firestore
  Future<void> _removeRoutine(String docId, bool isComplete) async {
    await _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection(isComplete ? 'completeRoutines' : 'incompleteRoutines')
        .doc(docId)
        .delete();
  }

  // Tampilan daftar rutinitas
  Widget _buildRoutineList(bool isComplete) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _getRoutines(isComplete),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada rutinitas.'));
        }

        final routines = snapshot.data!.docs;

        return ListView.builder(
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final routine = routines[index];
            final data = routine.data();
            final time = TimeOfDay(
              hour: data['time']['hour'],
              minute: data['time']['minute'],
            );

            return ListTile(
              title: Text('${data['title']} - ${data['period']}'),
              subtitle: Text(
                'Hari: ${data['days']}\nWaktu: ${formatTime(time)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Edit logic here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removeRoutine(routine.id, isComplete);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  void _editRoutine(int index, bool isComplete) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _textController = TextEditingController();
        _textController.text = isComplete
            ? _completeRoutines[index]['title']
            : _incompleteRoutines[index]['title'];

        return AlertDialog(
          title: const Text('Edit Rutinitas'),
          backgroundColor: const Color.fromARGB(255, 241, 208, 247),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aktivitas',
                ),
                onChanged: (value) {
                  _activityName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an activity name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10), // Add spacing

              // Dropdown for selecting the period (Morning, Noon, Night)
              DropdownButton<String>(
                value: _selectedPeriod,
                hint: const Text('Pilih Periode'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPeriod = newValue!;
                  });
                },
                items: <String>['Pagi', 'Siang', 'Malam']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10), // Add spacing

              // Dropdown for selecting the day
              DropdownButton<String>(
                value: _selectedDay,
                hint: const Text('Pilih Hari'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDay = newValue!;
                  });
                },
                items: <String>[
                  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20), // Add some spacing

              ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 175, 116, 185),
                ),
                child: const Text(
                  'Pilih Waktu',
                  style: TextStyle(
                    color: Color.fromARGB(255, 250, 247, 250),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _activityName = _textController.text;

                  // Update routine with activity name, time, period, and day
                  if (isComplete) {
                    _completeRoutines[index]['title'] = _activityName;
                    _completeRoutines[index]['time'] = _selectedTime;
                    _completeRoutines[index]['period'] = _selectedPeriod;
                    _completeRoutines[index]['days'] = _selectedDay;
                  } else {
                    _incompleteRoutines[index]['title'] = _activityName;
                    _incompleteRoutines[index]['time'] = _selectedTime;
                    _incompleteRoutines[index]['period'] = _selectedPeriod;
                    _incompleteRoutines[index]['days'] = _selectedDay;
                  }
                });
                Navigator.of(context).pop(); // Close the dialog after saving
              },
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: Color.fromARGB(255, 75, 1, 82),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // void _removeRoutine(int index, bool isComplete) {
  //   setState(() {
  //     if (isComplete) {
  //       _completeRoutines.removeAt(index);
  //     } else {
  //       _incompleteRoutines.removeAt(index);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Daftar List Rutinitas",
          style: TextStyle(color: Color.fromARGB(255, 253, 252, 253)),
        ),
        backgroundColor: const Color.fromARGB(255, 195, 3, 229),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: "Incomplete"),
            Tab(text: "Complete"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildRoutineList(false), // For Incomplete Routines
              _buildRoutineList(true), // For Complete Routines
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRoutinePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 20), // Padding
                  backgroundColor: const Color.fromARGB(255, 246, 215, 252),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 75, 1, 82),
                    ),
                    SizedBox(width: 10), // Space between button and text
                    Text(
                      'Tambah Rutinitas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 75, 1, 82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoutineContainer(bool isComplete) {
    final routines = isComplete ? _completeRoutines : _incompleteRoutines;
    return ListView.builder(
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        final now = TimeOfDay.now();
        final routineTime = routine['time'];
        final remainingTime = Duration(
          hours: routineTime.hour - now.hour,
          minutes: routineTime.minute - now.minute,
        );

        // Display in minutes left or past
        String remainingTimeText;
        if (remainingTime.isNegative) {
          remainingTimeText = '${remainingTime.inMinutes.abs()} menit lalu';
        } else {
          remainingTimeText = '${remainingTime.inMinutes} menit tersisa';
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Margin for spacing
          padding: const EdgeInsets.all(12.0), // Padding inside the container
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 246, 215, 252), // Background color
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Shadow color
                spreadRadius: 2, // How much the shadow spreads
                blurRadius: 5, // Blurring of the shadow
                offset: const Offset(0, 3), // Offset for the shadow position
              ),
            ],
          ),
          child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${routine['title']} - ${routine['Period']}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4), 
            Text(
              'Hari: ${routine['days']}\nWaktu: ${formatTime(routine['time'])} ($remainingTimeText)',
              style: const TextStyle(
                color: Color.fromARGB(255, 78, 76, 76),
              ),
            ),
          ],
        ),
      ),
    ),
    
    // Row untuk ikon edit dan delete
    Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 66, 64, 66)),
          onPressed: () => _editRoutine(index, isComplete),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeRoutine(index, isComplete),,
        ),
      ],
    ),
  ],
),
        );
      },
    );
  }
}