import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import '../../core/utils/logger.dart';

class FacultyViewAttendanceScreen extends StatefulWidget {
  const FacultyViewAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<FacultyViewAttendanceScreen> createState() =>
      _FacultyViewAttendanceScreenState();
}

class _FacultyViewAttendanceScreenState
    extends State<FacultyViewAttendanceScreen> {
  String? _selectedCourse;
  List<Course> _courses = [];
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

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
          _loadAttendance(courses[0].id);
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

  Future<void> _loadAttendance(String courseId) async {
    try {
      // Get course students
      final courseDoc = await FirebaseConfig.firestore
          .collection('courses')
          .doc(courseId)
          .get();

      final studentIds = courseDoc.data()?['students'] as List<dynamic>? ?? [];

      // Get student details
      Map<String, Map<String, dynamic>> studentMap = {};
      for (var studentId in studentIds) {
        final userDoc = await FirebaseConfig.firestore
            .collection('users')
            .doc(studentId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          studentMap[studentId] = {
            'name': userData['name'] ?? 'Unknown',
            'rollNumber': userData['rollNumber'] ?? 'N/A',
          };
        }
      }

      // Get attendance records
      final attendanceSnapshot = await FirebaseConfig.firestore
          .collection('attendance')
          .where('courseId', isEqualTo: courseId)
          .get();

      // Group by date
      Map<String, Map<String, String>> dateAttendanceMap = {};
      Set<String> allDates = {};

      for (var attDoc in attendanceSnapshot.docs) {
        final attData = attDoc.data();
        final date = attData['date']?.toString().substring(0, 10) ?? '';
        allDates.add(date);

        final students = attData['students'] as List<dynamic>? ?? [];
        for (var student in students) {
          final studentId = student['studentId'];
          final status = student['isPresent'] == true ? 'Present' : 'Absent';

          if (!dateAttendanceMap.containsKey(studentId)) {
            dateAttendanceMap[studentId] = {};
          }
          dateAttendanceMap[studentId]![date] = status;
        }
      }

      // Create attendance records
      List<String> datesList = allDates.toList()..sort();
      List<AttendanceRecord> records = [];

      for (var entry in studentMap.entries) {
        final studentId = entry.key;
        final studentData = entry.value;

        Map<String, String> attendance = {};
        for (var date in datesList) {
          attendance[date] = dateAttendanceMap[studentId]?[date] ?? 'Absent';
        }

        records.add(AttendanceRecord(
          name: studentData['name'],
          rollNumber: studentData['rollNumber'],
          attendance: attendance,
        ));
      }

      setState(() {
        _attendanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading attendance: $e');
      setState(() {
        _isLoading = false;
      });
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
          'View Attendance',
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
                              _loadAttendance(course.id);
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

                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _fromDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _fromDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    '${_fromDate.year}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.day.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _toDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _toDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    '${_toDate.year}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.day.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Attendance Table
                    if (_attendanceRecords.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No attendance records found'),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              AppColors.primary.withOpacity(0.1),
                            ),
                            columns: [
                              const DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'Roll No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              ..._attendanceRecords.first.attendance.keys
                                  .map((date) => DataColumn(
                                        label: Text(
                                          date.substring(5),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      )),
                            ],
                            rows: _attendanceRecords.map((record) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(record.name)),
                                  DataCell(Text(record.rollNumber)),
                                  ...record.attendance.values
                                      .map((status) => DataCell(
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: status == 'Present'
                                                    ? AppColors.success
                                                    : AppColors.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
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

class AttendanceRecord {
  final String name;
  final String rollNumber;
  final Map<String, String> attendance;

  AttendanceRecord({
    required this.name,
    required this.rollNumber,
    required this.attendance,
  });
}
