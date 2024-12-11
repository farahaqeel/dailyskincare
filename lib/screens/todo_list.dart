import 'package:flutter/material.dart';
import 'package:dailyskincare/screens/add_routine.dart';
import 'package:dailyskincare/screens/edit_routine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  late TabController _tabController;

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _removeRoutine(String docId, bool isComplete) async {
    await _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection(isComplete ? 'completeRoutines' : 'incompleteRoutines')
        .doc(docId)
        .delete();
  }

  Future<void> _editRoutine(String docId, bool isComplete, Map<String, dynamic> updatedData) async {
  if (_user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  try {
    // Mengupdate dokumen berdasarkan ID
    await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection(isComplete ? 'completeRoutines' : 'incompleteRoutines')
        .doc(docId)
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Routine updated successfully')),
    );

    Navigator.of(context).pop(); // Kembali ke layar sebelumnya
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating routine: $e')),
    );
  }
}


  Stream<QuerySnapshot<Map<String, dynamic>>> _getRoutines(bool isComplete) {
    return _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection(isComplete ? 'completeRoutines' : 'incompleteRoutines')
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
                      String routineId = routine.id; // Ganti dengan ID rutinitas aktual

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRoutinePage(
                            routineId: routineId, // Berikan nilai routineId
                          ),
                        ),
                      );
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
              _buildRoutineList(false), // Incomplete Routines
              _buildRoutineList(true), // Complete Routines
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
                    MaterialPageRoute(
                      builder: (context) => AddRoutinePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  backgroundColor: const Color.fromARGB(255, 246, 215, 252),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 75, 1, 82),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Tambah Rutinitas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 141, 56, 148),
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
}
