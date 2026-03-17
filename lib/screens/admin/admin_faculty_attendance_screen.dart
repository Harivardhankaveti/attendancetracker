import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';

class AdminFacultyAttendanceScreen extends StatefulWidget {
  const AdminFacultyAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AdminFacultyAttendanceScreen> createState() => _AdminFacultyAttendanceScreenState();
}

class _AdminFacultyAttendanceScreenState extends State<AdminFacultyAttendanceScreen> {
  List<FacultyAttendanceData> _faculty = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacultyAttendance();
  }

  Future<void> _loadFacultyAttendance() async {
    try {
      final facultySnapshot = await FirebaseConfig.firestore
          .collection('users')
          .where('role', isEqualTo: 'faculty')
          .get();

      List<FacultyAttendanceData> facultyList = [];

      for (var facultyDoc in facultySnapshot.docs) {
        final facultyData = facultyDoc.data();
        
        // Get courses taught
        final coursesSnapshot = await FirebaseConfig.firestore
            .collection('courses')
            .where('facultyId', isEqualTo: facultyDoc.id)
            .get();

        int totalCourses = coursesSnapshot.docs.length;
        int totalSessions = 0;

        for (var courseDoc in coursesSnapshot.docs) {
          final attendanceSnapshot = await FirebaseConfig.firestore
              .collection('attendance')
              .where('courseId', isEqualTo: courseDoc.id)
              .get();
          
          totalSessions += attendanceSnapshot.docs.length;
        }

        facultyList.add(FacultyAttendanceData(
          name: facultyData['name'] ?? 'Unknown',
          email: facultyData['email'] ?? 'N/A',
          department: facultyData['department'] ?? 'N/A',
          totalCourses: totalCourses,
          totalSessions: totalSessions,
        ));
      }

      setState(() {
        _faculty = facultyList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading faculty attendance: $e');
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
        backgroundColor: AppColors.adminColor,
        title: const Text('Faculty Attendance', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFacultyAttendance,
              child: _faculty.isEmpty
                  ? const Center(
                      child: Text('No faculty found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _faculty.length,
                      itemBuilder: (context, index) {
                        return _buildFacultyCard(_faculty[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildFacultyCard(FacultyAttendanceData faculty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      faculty.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem('Department', faculty.department),
                    _buildInfoItem('Courses', faculty.totalCourses.toString()),
                    _buildInfoItem('Sessions', faculty.totalSessions.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class FacultyAttendanceData {
  final String name;
  final String email;
  final String department;
  final int totalCourses;
  final int totalSessions;

  FacultyAttendanceData({
    required this.name,
    required this.email,
    required this.department,
    required this.totalCourses,
    required this.totalSessions,
  });
}
