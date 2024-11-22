import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';

void main() => runApp(AddRoutineApp());

class AddRoutineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tambah Rutinitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddRoutinePage(),
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

class AddRoutinePage extends StatefulWidget {
  @override
  _AddRoutinePageState createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends State<AddRoutinePage> {
  final _formKey = GlobalKey<FormState>();
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

  void _addRoutine() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String routineTime = _selectedPeriod != null 
          ? '$_selectedPeriod (${_selectedTime.format(context)})' 
          : _selectedTime.format(context);

      print('Activity: $_activityName, Time: $routineTime, Days: $_selectedDays');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Routine added: $_activityName at $routineTime on ${_selectedDays.join(", ")}')),
      );
    }
  }

  void _onPeriodSelected(String? value) {
    setState(() {
      _selectedPeriod = value;
      if (value == 'Pagi') {
        _selectedTime = TimeOfDay(hour: 8, minute: 0);
      } else if (value == 'Siang') {
        _selectedTime = TimeOfDay(hour: 12, minute: 0);
      } else if (value == 'Malam') {
        _selectedTime = TimeOfDay(hour: 20, minute: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tambah Rutinitas',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 195, 3, 229),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromARGB(255, 250, 246, 246),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
                      onPressed: _addRoutine,
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
