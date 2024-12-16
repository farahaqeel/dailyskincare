import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';

class EditRoutinePage extends StatefulWidget {
  final String routineId;

  const EditRoutinePage({Key? key, required this.routineId}) : super(key: key);

  @override
  _EditRoutinePageState createState() => _EditRoutinePageState();
}


class _EditRoutinePageState extends State<EditRoutinePage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  String _activityName = '';
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedPeriod;
  List<String> _selectedDays = [];

  final List<String> _periodOptions = ['Pagi', 'Siang', 'Malam'];

   final List<CustomDayInWeek> _days = [
    CustomDayInWeek("Sen", dayKey: "monday"),
    CustomDayInWeek("Sel", dayKey: "tuesday"),
    CustomDayInWeek("Rab", dayKey: "wednesday"),
    CustomDayInWeek("Kam", dayKey: "thursday"),
    CustomDayInWeek("Jum", dayKey: "friday"),
    CustomDayInWeek("Sab", dayKey: "saturday"),
    CustomDayInWeek("Min", dayKey: "sunday"),
  ];

  Future<void> _editRoutine(String routineId) async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('incompleteRoutines')
          .doc(routineId) // ID dokumen untuk edit
          .update({
        'title': _activityName,
        'period': _selectedPeriod ?? 'Custom',
        'time': {
          'hour': _selectedTime.hour,
          'minute': _selectedTime.minute,
        },
        'days': _selectedDays.join(', '),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine updated successfully')),
      );

      Navigator.of(context).pop(); // Kembali ke layar sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating routine: $e')),
      );
    }
  }
}


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onPeriodSelected(String? value) {
    setState(() {
      _selectedPeriod = value;
      if (value == 'Pagi') {
        _selectedTime = const TimeOfDay(hour: 8, minute: 0);
      } else if (value == 'Siang') {
        _selectedTime = const TimeOfDay(hour: 12, minute: 0);
      } else if (value == 'Malam') {
        _selectedTime = const TimeOfDay(hour: 20, minute: 0);
      }
    });
  }

  @override
    @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Rutinitas',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 127, 1, 139),
        ),

        // Wrap the entire body in SingleChildScrollView
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Nama Aktivitas in a box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 246, 215, 252),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nama Aktivitas',
                        labelStyle: const TextStyle(
                          color:  Color.fromARGB(255, 127, 1, 139), // Label color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color:  Color.fromARGB(255, 127, 1, 139), // Border color when focused
                            width: 2.0, // Width of the border
                          ),
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color:  Color.fromARGB(255, 127, 1, 139), // Border color when not focused
                            width: 1.5, // Width of the border
                          ),
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      onSaved: (value) {
                        _activityName = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an activity name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pilih Periode in a box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 246, 215, 252),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      hint: const Text(
                        'Pilih Periode',
                        style: TextStyle(
                          color:  Color.fromARGB(255, 127, 1, 139), // Hint text color
                        ),
                      ),
                      items: _periodOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color:  Color.fromARGB(255, 127, 1, 139), // Dropdown option text color
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _onPeriodSelected,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Waktu Periode',
                        labelStyle: TextStyle(
                          color:  Color.fromARGB(255, 127, 1, 139), // Label text color
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Day Picker
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = MediaQuery.of(context).size.width;
                          double widthFactor = screenWidth * 0.9;
                          double fontSizeFactor = screenWidth * 0.03;
                          
                          return SelectWeekDays(
                            fontSize: fontSizeFactor,
                            fontWeight: FontWeight.w500,
                            days: _days.map((day) => DayInWeek(day.dayName, dayKey: day.dayKey)).toList(),
                            border: false,
                            width: widthFactor,
                            boxDecoration: BoxDecoration(
                              color: const Color.fromARGB(255, 246, 215, 252),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onSelect: (values) {
                              setState(() {
                                _selectedDays = values;
                              });
                              print('Selected days: $values');
                            },
                            selectedDayTextColor: const Color.fromARGB(255, 127, 1, 139),
                            unSelectedDayTextColor: const Color.fromARGB(255, 127, 1, 139),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time Picker
                  Row(
                    children: <Widget>[
                      Text("Waktu yang dipilih: ${_selectedTime.format(context)}"),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          backgroundColor: const Color.fromARGB(255, 246, 215, 252),
                        ),
                        child: const Text(
                          'Pilih Waktu',
                          style: TextStyle(
                            color: Color.fromARGB(255, 127, 1, 139),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _editRoutine(widget.routineId); // Memanggil fungsi dengan ID dokumen
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        backgroundColor: const Color.fromARGB(255, 246, 215, 252),
                      ),
                      child: const Text(
                        'Simpan Rutinitas',
                        style: TextStyle(
                          color: Color.fromARGB(255, 127, 1, 139),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class CustomDayInWeek {
  CustomDayInWeek(
      this.dayName, {
        required this.dayKey,
        this.isSelected = false,
      });

  String dayName;
  String dayKey;
  bool isSelected = false;
}