import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import 'student_timetable_screen.dart';
import 'student_profile_screen.dart';
import 'student_attendance_screen.dart';
import '../../core/utils/logger.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<CourseAttendance> _courses = [];
  double _overallPercentage = 0.0;
  int _totalClasses = 0;
  int _classesAttended = 0;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) return;

    try {
      // Fetch courses where student is enrolled
      final coursesSnapshot = await FirebaseConfig.firestore
          .collection('courses')
          .where('students', arrayContains: userId)
          .get();

      List<CourseAttendance> coursesList = [];
      int totalPresent = 0;
      int totalClasses = 0;

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();

        // Fetch attendance for this course
        final attendanceSnapshot = await FirebaseConfig.firestore
            .collection('attendance')
            .where('courseId', isEqualTo: courseDoc.id)
            .get();

        int present = 0;
        int total = attendanceSnapshot.docs.length;

        for (var attDoc in attendanceSnapshot.docs) {
          final students = attDoc.data()['students'] as List<dynamic>?;
          if (students != null) {
            final studentRecord = students.firstWhere(
              (s) => s['studentId'] == userId,
              orElse: () => null,
            );
            if (studentRecord != null && studentRecord['isPresent'] == true) {
              present++;
            }
          }
        }

        double percentage = total > 0 ? (present / total) * 100 : 0.0;

        coursesList.add(CourseAttendance(
          code: courseData['code'] ?? '',
          name: courseData['name'] ?? '',
          classesHeld: total,
          classesAttended: present,
          percentage: percentage,
        ));

        totalPresent += present;
        totalClasses += total;
      }

      setState(() {
        _courses = coursesList;
        _classesAttended = totalPresent;
        _totalClasses = totalClasses;
        _overallPercentage =
            totalClasses > 0 ? (totalPresent / totalClasses) * 100 : 0.0;
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
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildDashboard();
    } else if (_selectedIndex == 1) {
      return _buildAttendanceView();
    } else if (_selectedIndex == 2) {
      return _buildTimetableView();
    } else {
      return _buildProfileView();
    }
  }

  Widget _buildDashboard() {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? 'Student';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your Attendance Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, size: 28),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Overall Attendance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF5E35B1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_overallPercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total Classes', _totalClasses.toString()),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white38,
                      ),
                      _buildStatItem(
                          'Classes Attended', _classesAttended.toString()),
                    ],
                  ),
                ],
              ),
            ),

            // Subject-wise Attendance
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subject-wise Attendance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_courses.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No courses enrolled yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._courses.map((course) => _buildCourseCard(course)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(CourseAttendance course) {
    final color = AppColors.getAttendanceColor(course.percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course.code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${course.percentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Classes Held',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Classes Attended',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.classesHeld.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                course.classesAttended.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceView() {
    // Detailed attendance view - now using the new attendance screen
    return const StudentAttendanceScreen();
  }

  Widget _buildTimetableView() {
    return const StudentTimetableScreen();
  }

  Widget _buildProfileView() {
    return const StudentProfileScreen();
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Timetable',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class CourseAttendance {
  final String code;
  final String name;
  final int classesHeld;
  final int classesAttended;
  final double percentage;

  CourseAttendance({
    required this.code,
    required this.name,
    required this.classesHeld,
    required this.classesAttended,
    required this.percentage,
  });
}
