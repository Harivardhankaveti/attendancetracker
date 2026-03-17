import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';

class AdminExamScheduleScreen extends StatefulWidget {
  const AdminExamScheduleScreen({Key? key}) : super(key: key);

  @override
  State<AdminExamScheduleScreen> createState() => _AdminExamScheduleScreenState();
}

class _AdminExamScheduleScreenState extends State<AdminExamScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedBranch;
  String? _selectedSection;
  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<ExamData> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    try {
      final examsSnapshot = await FirebaseConfig.firestore
          .collection('examSchedule')
          .orderBy('dateTime', descending: false)
          .get();

      List<ExamData> exams = [];
      for (var doc in examsSnapshot.docs) {
        final data = doc.data();
        exams.add(ExamData(
          id: doc.id,
          subject: data['subject'] ?? '',
          code: data['code'] ?? '',
          branch: data['branch'] ?? '',
          section: data['section'] ?? '',
          dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ));
      }

      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exams: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null || _selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select branch and section')),
      );
      return;
    }

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await FirebaseConfig.firestore.collection('examSchedule').add({
        'subject': _subjectController.text,
        'code': _codeController.text,
        'branch': _selectedBranch,
        'section': _selectedSection,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _subjectController.clear();
      _codeController.clear();
      setState(() {
        _selectedBranch = null;
        _selectedSection = null;
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      });

      Navigator.of(context).pop();
      _loadExams();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam scheduled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteExam(String examId) async {
    try {
      await FirebaseConfig.firestore.collection('examSchedule').doc(examId).delete();
      _loadExams();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAddExamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Exam'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter subject name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter subject code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Exam Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Exam Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedTime.format(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addExam,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminColor,
            ),
            child: const Text('Schedule', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.adminColor,
        title: const Text('Exam Schedule', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExams,
              child: _exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.assignment, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No exams scheduled'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        return _buildExamCard(_exams[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExamDialog,
        backgroundColor: AppColors.adminColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Schedule Exam', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildExamCard(ExamData exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppColors.warning, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        exam.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exam.code,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Exam'),
                        content: const Text('Are you sure you want to delete this exam?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteExam(exam.id);
                            },
                            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.school, '${exam.branch} - ${exam.section}'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.calendar_today, '${exam.dateTime.day}/${exam.dateTime.month}/${exam.dateTime.year}'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.access_time, '${exam.dateTime.hour}:${exam.dateTime.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ExamData {
  final String id;
  final String subject;
  final String code;
  final String branch;
  final String section;
  final DateTime dateTime;

  ExamData({
    required this.id,
    required this.subject,
    required this.code,
    required this.branch,
    required this.section,
    required this.dateTime,
  });
}
