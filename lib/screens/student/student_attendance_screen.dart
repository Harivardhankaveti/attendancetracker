import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart' as app_model;
import '../../core/constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/course.dart';
import '../../models/attendance.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  String _selectedFilter = 'monthly';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<Course> _courses = [];
  List<Map<String, dynamic>> _subjectAttendance = [];
  int _totalClasses = 0;
  int _classesAttended = 0;
  double _overallPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final courses = await _db.getCoursesByStudent(userId);

      List<Map<String, dynamic>> subjectAttendance = [];
      int totalAll = 0;
      int attendedAll = 0;

      for (var course in courses) {
        final attendanceRecords = await _db.getAttendanceByCourse(course.id);

        int total = attendanceRecords.length;
        int attended = 0;

        for (var record in attendanceRecords) {
          if (record.isStudentPresent(userId)) {
            attended++;
          }
        }

        double percentage = total > 0 ? (attended / total) * 100 : 0.0;

        subjectAttendance.add({
          'code': course.code,
          'name': course.name,
          'total': total,
          'attended': attended,
          'percentage': percentage,
        });

        totalAll += total;
        attendedAll += attended;
      }

      setState(() {
        _courses = courses;
        _subjectAttendance = subjectAttendance;
        _totalClasses = totalAll;
        _classesAttended = attendedAll;
        _overallPercentage =
            totalAll > 0 ? (attendedAll / totalAll) * 100 : 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final app_model.User? user = authProvider.user;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // A. Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF7A00),
                  Color(0xFFFF007A),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Attendance Report',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? 'Student Name',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // B. Filter Section Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterOption('Monthly', 'monthly'),
                    _buildFilterOption('Period', 'period'),
                    _buildFilterOption('Till Now', 'till_now'),
                  ],
                ),
                if (_selectedFilter == 'period')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectStartDate(context),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_formatDate(_startDate)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('to'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectEndDate(context),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_formatDate(_endDate)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAttendanceData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // C. Student Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.badge, 'Roll Number',
                              user?.studentId ?? 'N/A'),
                          _buildInfoRow(
                              Icons.person, 'Name', user?.name ?? 'Student'),
                          _buildInfoRow(Icons.school, 'Course', 'B.Tech'),
                          _buildInfoRow(Icons.apartment, 'Branch',
                              user?.department ?? 'N/A'),
                          _buildInfoRow(
                              Icons.calendar_month, 'Year', user?.year ?? 'N/A'),
                          _buildInfoRow(Icons.group, 'Section',
                              user?.section ?? 'N/A'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // D. Overall Attendance Analytics
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Overall Attendance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: _overallPercentage / 100,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF7A00),
                                  ),
                                ),
                              ),
                              Text(
                                '${_overallPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                  _totalClasses.toString(), 'Total'),
                              _buildStatCard(
                                  _classesAttended.toString(), 'Attended'),
                              _buildStatCard(
                                  (_totalClasses - _classesAttended)
                                      .toString(),
                                  'Missed'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // E. Subject-wise Attendance Card
                    if (_subjectAttendance.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subject-wise Attendance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _subjectAttendance.isEmpty
                                ? const Center(
                                    child: Text('No attendance records yet'))
                                : Column(
                                    children: _subjectAttendance.map((subject) {
                                      double pct = subject['percentage'];
                                      Color color =
                                          AppColors.getAttendanceColor(pct);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                '${subject['code']}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                  '${subject['total']}',
                                                  textAlign:
                                                      TextAlign.center),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                  '${subject['attended']}',
                                                  textAlign:
                                                      TextAlign.center),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                '${pct.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text('Subject',
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold))),
                                  Expanded(
                                      flex: 1,
                                      child: Text('Total',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold))),
                                  Expanded(
                                      flex: 1,
                                      child: Text('Attended',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold))),
                                  Expanded(
                                      flex: 1,
                                      child: Text('%',
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // G. Alerts Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._buildAlerts(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlerts() {
    List<Widget> alerts = [];
    for (var subject in _subjectAttendance) {
      double pct = subject['percentage'];
      if (pct < 75 && subject['total'] > 0) {
        alerts.add(_buildAlertCard(
          Icons.warning,
          '${subject['code']} attendance is low (${pct.toStringAsFixed(1)}%)',
          Colors.orange,
        ));
        alerts.add(const SizedBox(height: 8));
      }
    }
    if (alerts.isEmpty) {
      alerts.add(_buildAlertCard(
        Icons.check_circle,
        'Your attendance is good. Keep it up!',
        Colors.green,
      ));
    }
    return alerts;
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF7A00)),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAlertCard(IconData icon, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
