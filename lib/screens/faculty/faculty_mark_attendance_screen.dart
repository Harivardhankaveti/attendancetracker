import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import '../../core/utils/logger.dart';

class FacultyMarkAttendanceScreen extends StatefulWidget {
  const FacultyMarkAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<FacultyMarkAttendanceScreen> createState() =>
      _FacultyMarkAttendanceScreenState();
}

class _FacultyMarkAttendanceScreenState
    extends State<FacultyMarkAttendanceScreen> {
  String? _selectedCourse;
  List<Course> _courses = [];
  List<StudentAttendanceItem> _students = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) return;

    try {
      final coursesSnapshot = await FirebaseConfig.firestore
          .collection('courses')
          .where('facultyId', isEqualTo: userId)
          .get();

      List<Course> courses = [];
      for (var doc in coursesSnapshot.docs) {
        final data = doc.data();
        courses.add(Course(
          id: doc.id,
          code: data['code'] ?? '',
          name: data['name'] ?? '',
        ));
      }

      setState(() {
        _courses = courses;
        if (courses.isNotEmpty) {
          _selectedCourse = courses[0].code;
          _loadStudents(courses[0].id);
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      Logger.error('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudents(String courseId) async {
    try {
      final courseDoc = await FirebaseConfig.firestore
          .collection('courses')
          .doc(courseId)
          .get();

      final studentIds = courseDoc.data()?['students'] as List<dynamic>? ?? [];

      List<StudentAttendanceItem> students = [];
      for (var studentId in studentIds) {
        final userDoc = await FirebaseConfig.firestore
            .collection('users')
            .doc(studentId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          students.add(StudentAttendanceItem(
            id: studentId,
            name: userData['name'] ?? 'Unknown',
            rollNumber: userData['rollNumber'] ?? 'N/A',
            status: AttendanceStatus.present,
          ));
        }
      }

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading students: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAttendance() async {
    try {
      final course = _courses.firstWhere((c) => c.code == _selectedCourse);

      await FirebaseConfig.firestore.collection('attendance').add({
        'courseId': course.id,
        'date': _selectedDate.toIso8601String(),
        'students': _students
            .map((s) => {
                  'studentId': s.id,
                  'isPresent': s.status == AttendanceStatus.present,
                  'status': s.status.toString().split('.').last,
                })
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance submitted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      Logger.error('Error submitting attendance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mark Attendance',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark Attendance',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Class/Section Selector
                    const Text(
                      'Class/Section',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _courses.map((course) {
                        final isSelected = course.code == _selectedCourse;
                        return ChoiceChip(
                          label: Text(course.code),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCourse = course.code;
                                _isLoading = true;
                              });
                              _loadStudents(course.id);
                            }
                          },
                          backgroundColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Date Selector
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Students List
                    if (_students.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No students enrolled'),
                        ),
                      )
                    else
                      ..._students.map((student) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                student.rollNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatusButton(
                                      student,
                                      AttendanceStatus.present,
                                      'Present',
                                      AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatusButton(
                                      student,
                                      AttendanceStatus.absent,
                                      'Absent',
                                      AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatusButton(
                                      student,
                                      AttendanceStatus.leave,
                                      'Leave',
                                      AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Submit Attendance',
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
    );
  }

  Widget _buildStatusButton(
    StudentAttendanceItem student,
    AttendanceStatus status,
    String label,
    Color color,
  ) {
    final isSelected = student.status == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          student.status = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Course {
  final String id;
  final String code;
  final String name;

  Course({required this.id, required this.code, required this.name});
}

enum AttendanceStatus { present, absent, leave }

class StudentAttendanceItem {
  final String id;
  final String name;
  final String rollNumber;
  AttendanceStatus status;

  StudentAttendanceItem({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.status,
  });
}
