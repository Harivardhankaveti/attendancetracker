import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/course.dart';
import '../../models/attendance.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final String? courseId;

  const StudentCourseDetailScreen({super.key, this.courseId});

  @override
  State<StudentCourseDetailScreen> createState() =>
      _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> {
  final DatabaseService _db = DatabaseService();
  Course? _course;
  bool _isLoading = true;
  int _totalClasses = 0;
  int _classesAttended = 0;
  double _attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    if (widget.courseId == null || widget.courseId!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    try {
      final course = await _db.getCourseById(widget.courseId!);

      if (course != null) {
        final attendanceRecords = await _db.getAttendanceByCourse(course.id);

        int total = attendanceRecords.length;
        int attended = 0;

        if (userId != null) {
          for (var record in attendanceRecords) {
            if (record.isStudentPresent(userId)) {
              attended++;
            }
          }
        }

        double percentage = total > 0 ? (attended / total) * 100 : 0.0;

        setState(() {
          _course = course;
          _totalClasses = total;
          _classesAttended = attended;
          _attendancePercentage = percentage;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_course != null
            ? '${_course!.code} - ${_course!.name}'
            : 'Course Details'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _course == null
              ? const Center(child: Text('Course not found'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Info Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _course!.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _course!.code,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${_course!.credits} Credits',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _course!.description.isEmpty
                                      ? 'No description available'
                                      : _course!.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(Icons.person, 'Instructor',
                                    _course!.facultyName),
                                _buildInfoRow(Icons.school, 'Department',
                                    _course!.department),
                                _buildInfoRow(Icons.calendar_month, 'Semester',
                                    _course!.semester),
                                _buildInfoRow(Icons.people, 'Enrolled Students',
                                    '${_course!.students.length}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Attendance Stats
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Attendance',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_attendancePercentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors
                                                  .getAttendanceColor(
                                                      _attendancePercentage),
                                            ),
                                          ),
                                          const Text(
                                            'Attendance Rate',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '$_classesAttended/$_totalClasses',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'Classes',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: _attendancePercentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.getAttendanceColor(
                                          _attendancePercentage)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
