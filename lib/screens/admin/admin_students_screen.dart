import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/user.dart' as app_model;

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = true;
  List<app_model.User> _students = [];
  List<app_model.User> _filteredStudents = [];
  String? _selectedDepartment;

  final List<String> _departments = [
    'All',
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'IT',
    'CSDS',
    'CSM',
    'CSBS',
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final students = await _db.getAllStudents();
    setState(() {
      _students = students;
      _filteredStudents = students;
      _isLoading = false;
    });
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        final matchesQuery = student.name.toLowerCase().contains(query) ||
            (student.studentId ?? '').toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query);

        final matchesDept = _selectedDepartment == null ||
            _selectedDepartment == 'All' ||
            (student.department ?? '').toUpperCase() ==
                _selectedDepartment.toUpperCase();

        return matchesQuery && matchesDept;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filter by Department',
                border: OutlineInputBorder(),
              ),
              value: _selectedDepartment ?? 'All',
              items: _departments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                });
                _filterStudents();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? const Center(child: Text('No students found'))
                      : RefreshIndicator(
                          onRefresh: _loadStudents,
                          child: ListView.builder(
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
              final student = _filteredStudents[index];
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(student.name),
                  subtitle: Text(
                      '${student.studentId ?? 'N/A'} • ${student.department ?? 'N/A'}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${student.email}'),
                          Text('Year: ${student.year ?? 'N/A'}'),
                          Text('Section: ${student.section ?? 'N/A'}'),
                          Text('Branch: ${student.department ?? 'N/A'}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _showEditDialog(student),
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(app_model.User student) async {
    final nameController = TextEditingController(text: student.name);
    final deptController = TextEditingController(text: student.department ?? '');
    final yearController = TextEditingController(text: student.year ?? '');
    final sectionController =
        TextEditingController(text: student.section ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Branch')),
              TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year')),
              TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _db.updateUser(student.uid, {
        'name': nameController.text.trim(),
        'department': deptController.text.trim(),
        'year': yearController.text.trim(),
        'section': sectionController.text.trim(),
      });
      _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated')),
        );
      }
    }
  }
}
