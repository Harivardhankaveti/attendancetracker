import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';

class AdminStudentAttendanceScreen extends StatefulWidget {
  const AdminStudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AdminStudentAttendanceScreen> createState() => _AdminStudentAttendanceScreenState();
}

class _AdminStudentAttendanceScreenState extends State<AdminStudentAttendanceScreen> {
  String? _selectedBranch;
  String? _selectedSection;
  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  List<StudentAttendanceData> _students = [];
  bool _isLoading = false;

  Future<void> _loadStudentAttendance() async {
    if (_selectedBranch == null || _selectedSection == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch students by branch and section
      final studentsSnapshot = await FirebaseConfig.firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('department', isEqualTo: _selectedBranch)
          .where('section', isEqualTo: _selectedSection)
          .get();

      List<StudentAttendanceData> studentsList = [];

      for (var studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        
        // Calculate attendance
        int totalClasses = 0;
        int attendedClasses = 0;

        final attendanceSnapshot = await FirebaseConfig.firestore
            .collection('attendance')
            .get();

        for (var attDoc in attendanceSnapshot.docs) {
          final students = attDoc.data()['students'] as List<dynamic>?;
          if (students != null) {
            final studentRecord = students.firstWhere(
              (s) => s['studentId'] == studentDoc.id,
              orElse: () => null,
            );
            if (studentRecord != null) {
              totalClasses++;
              if (studentRecord['isPresent'] == true) {
                attendedClasses++;
              }
            }
          }
        }

        double percentage = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

        studentsList.add(StudentAttendanceData(
          name: studentData['name'] ?? 'Unknown',
          rollNumber: studentData['rollNumber'] ?? 'N/A',
          totalClasses: totalClasses,
          attendedClasses: attendedClasses,
          percentage: percentage,
        ));
      }

      setState(() {
        _students = studentsList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading attendance: $e');
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
        title: const Text('Student Attendance', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters
              const Text(
                'Select Branch & Section',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Branch Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedBranch,
                    hint: const Text('Select Branch'),
                    items: _branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBranch = value;
                        _students = [];
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Section Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSection,
                    hint: const Text('Select Section'),
                    items: _sections.map((section) {
                      return DropdownMenuItem(
                        value: section,
                        child: Text('Section $section'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSection = value;
                        _students = [];
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Load Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loadStudentAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Load Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Results
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_students.isEmpty && _selectedBranch != null && _selectedSection != null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No students found'),
                  ),
                )
              else if (_students.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._students.map((student) => _buildStudentCard(student)).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentAttendanceData student) {
    final color = AppColors.getAttendanceColor(student.percentage);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.rollNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${student.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', student.totalClasses.toString()),
              Container(height: 30, width: 1, color: Colors.grey.shade300),
              _buildStatItem('Present', student.attendedClasses.toString()),
              Container(height: 30, width: 1, color: Colors.grey.shade300),
              _buildStatItem('Absent', (student.totalClasses - student.attendedClasses).toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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

class StudentAttendanceData {
  final String name;
  final String rollNumber;
  final int totalClasses;
  final int attendedClasses;
  final double percentage;

  StudentAttendanceData({
    required this.name,
    required this.rollNumber,
    required this.totalClasses,
    required this.attendedClasses,
    required this.percentage,
  });
}
