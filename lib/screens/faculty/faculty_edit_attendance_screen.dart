import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import '../../core/utils/logger.dart';
import 'package:provider/provider.dart';

class FacultyEditAttendanceScreen extends StatefulWidget {
  const FacultyEditAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<FacultyEditAttendanceScreen> createState() =>
      _FacultyEditAttendanceScreenState();
}

class _FacultyEditAttendanceScreenState
    extends State<FacultyEditAttendanceScreen> {
  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  List<Map<String, dynamic>> _attendanceRecords = [];
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

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final coursesSnapshot = await FirebaseConfig.firestore
          .collection('courses')
          .where('facultyId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> courses = [];
      for (var doc in coursesSnapshot.docs) {
        final data = doc.data();
        courses.add({
          'id': doc.id,
          'code': data['code'] ?? '',
          'name': data['name'] ?? '',
        });
      }

      setState(() {
        _courses = courses;
        if (courses.isNotEmpty) {
          _selectedCourseId = courses[0]['id'];
          _loadAttendanceRecords();
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      Logger.error('Error loading courses: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendanceRecords() async {
    if (_selectedCourseId == null) return;

    setState(() => _isLoading = true);

    try {
      final attendanceSnapshot = await FirebaseConfig.firestore
          .collection('attendance')
          .where('courseId', isEqualTo: _selectedCourseId)
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> records = [];
      for (var doc in attendanceSnapshot.docs) {
        final data = doc.data();
        final dateStr = data['date']?.toString() ?? '';
        final students = data['students'] as List<dynamic>? ?? [];
        int present = students.where((s) => s['isPresent'] == true).length;

        records.add({
          'id': doc.id,
          'date': dateStr,
          'totalStudents': students.length,
          'presentStudents': present,
          'students': students,
        });
      }

      setState(() {
        _attendanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading attendance records: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editAttendanceRecord(Map<String, dynamic> record) async {
    final students = List<Map<String, dynamic>>.from(record['students']);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditAttendanceDialog(
        recordId: record['id'],
        date: record['date'],
        students: students,
      ),
    );

    if (result == true) {
      _loadAttendanceRecords();
    }
  }

  Future<void> _deleteAttendanceRecord(String recordId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this attendance record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseConfig.firestore
            .collection('attendance')
            .doc(recordId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted')),
        );
        _loadAttendanceRecords();
      } catch (e) {
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
          'Edit Attendance',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? const Center(
                  child: Text('No courses available',
                      style: TextStyle(fontSize: 16)),
                )
              : Column(
                  children: [
                    // Course selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Course',
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
                              final isSelected =
                                  course['id'] == _selectedCourseId;
                              return ChoiceChip(
                                label: Text(course['code']),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCourseId = course['id'];
                                    });
                                    _loadAttendanceRecords();
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
                        ],
                      ),
                    ),

                    // Attendance records list
                    Expanded(
                      child: _attendanceRecords.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('No attendance records found',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _attendanceRecords.length,
                              itemBuilder: (context, index) {
                                final record = _attendanceRecords[index];
                                return _buildRecordCard(record);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final present = record['presentStudents'] as int;
    final total = record['totalStudents'] as int;
    double percentage = total > 0 ? (present / total) * 100 : 0;
    final color = AppColors.getAttendanceColor(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['date'].isNotEmpty
                      ? record['date'].substring(0, 10)
                      : 'Unknown date',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Present: $present / $total',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => _editAttendanceRecord(record),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _deleteAttendanceRecord(record['id']),
          ),
        ],
      ),
    );
  }
}

class _EditAttendanceDialog extends StatefulWidget {
  final String recordId;
  final String date;
  final List<Map<String, dynamic>> students;

  const _EditAttendanceDialog({
    required this.recordId,
    required this.date,
    required this.students,
  });

  @override
  State<_EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<_EditAttendanceDialog> {
  late List<Map<String, dynamic>> _students;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _students = List.from(widget.students);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      await FirebaseConfig.firestore
          .collection('attendance')
          .doc(widget.recordId)
          .update({
        'students': _students,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Attendance - ${widget.date.substring(0, 10)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: _students.isEmpty
            ? const Center(child: Text('No students in this record'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final isPresent = student['isPresent'] == true;
                  return SwitchListTile(
                    title: Text(student['studentId'] ?? 'Unknown'),
                    value: isPresent,
                    onChanged: (value) {
                      setState(() {
                        _students[index]['isPresent'] = value;
                      });
                    },
                    activeColor: AppColors.success,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
