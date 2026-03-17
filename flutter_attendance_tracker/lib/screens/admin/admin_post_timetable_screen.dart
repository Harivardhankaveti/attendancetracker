import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';

class AdminPostTimetableScreen extends StatefulWidget {
  const AdminPostTimetableScreen({Key? key}) : super(key: key);

  @override
  State<AdminPostTimetableScreen> createState() => _AdminPostTimetableScreenState();
}

class _AdminPostTimetableScreenState extends State<AdminPostTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _facultyNameController = TextEditingController();
  final _roomController = TextEditingController();
  String? _selectedBranch;
  String? _selectedSection;
  String? _selectedDay;
  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _facultyNameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _postTimetable() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null || _selectedSection == null || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await FirebaseConfig.firestore.collection('timetable').add({
        'branch': _selectedBranch,
        'section': _selectedSection,
        'dayOfWeek': _selectedDay,
        'courseCode': _courseCodeController.text,
        'courseName': _courseNameController.text,
        'facultyName': _facultyNameController.text,
        'room': _roomController.text,
        'startTime': '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
        'endTime': '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable posted successfully')),
      );

      // Clear form
      _courseCodeController.clear();
      _courseNameController.clear();
      _facultyNameController.clear();
      _roomController.clear();
      setState(() {
        _selectedBranch = null;
        _selectedSection = null;
        _selectedDay = null;
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 10, minute: 0);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.adminColor,
        title: const Text('Post Timetable', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post New Timetable Entry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Branch & Section Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Branch & Section',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: const InputDecoration(
                          labelText: 'Branch',
                          border: OutlineInputBorder(),
                        ),
                        items: _branches.map((branch) {
                          return DropdownMenuItem(value: branch, child: Text(branch));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedSection,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          border: OutlineInputBorder(),
                        ),
                        items: _sections.map((section) {
                          return DropdownMenuItem(value: section, child: Text('Section $section'));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSection = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Course Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Course Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _courseCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Course Code (e.g., CS101)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter course code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _courseNameController,
                        decoration: const InputDecoration(
                          labelText: 'Course Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter course name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _facultyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Faculty Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter faculty name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(
                          labelText: 'Room Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter room number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Day & Time Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDay,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          border: OutlineInputBorder(),
                        ),
                        items: _days.map((day) {
                          return DropdownMenuItem(value: day, child: Text(day));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDay = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _startTime,
                                );
                                if (time != null) {
                                  setState(() {
                                    _startTime = time;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Time',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(_startTime.format(context)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _endTime,
                                );
                                if (time != null) {
                                  setState(() {
                                    _endTime = time;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Time',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(_endTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _postTimetable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Post Timetable',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
