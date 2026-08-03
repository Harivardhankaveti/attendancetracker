import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/user.dart' as app_model;

class AdminFacultyScreen extends StatefulWidget {
  const AdminFacultyScreen({super.key});

  @override
  State<AdminFacultyScreen> createState() => _AdminFacultyScreenState();
}

class _AdminFacultyScreenState extends State<AdminFacultyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = true;
  List<app_model.User> _faculty = [];
  List<app_model.User> _filteredFaculty = [];
  String? _selectedDepartment;

  final List<String> _departments = [
    'All',
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'IT',
  ];

  @override
  void initState() {
    super.initState();
    _loadFaculty();
    _searchController.addListener(_filterFaculty);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFaculty() async {
    setState(() => _isLoading = true);
    final faculty = await _db.getAllFaculty();
    setState(() {
      _faculty = faculty;
      _filteredFaculty = faculty;
      _isLoading = false;
    });
  }

  void _filterFaculty() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaculty = _faculty.where((f) {
        final matchesQuery = f.name.toLowerCase().contains(query) ||
            f.email.toLowerCase().contains(query);

        final matchesDept = _selectedDepartment == null ||
            _selectedDepartment == 'All' ||
            (f.department ?? '').toUpperCase() ==
                _selectedDepartment.toUpperCase();

        return matchesQuery && matchesDept;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Faculty'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search faculty...',
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
                _filterFaculty();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFaculty.isEmpty
                      ? const Center(child: Text('No faculty found'))
                      : RefreshIndicator(
                          onRefresh: _loadFaculty,
                          child: ListView.builder(
                            itemCount: _filteredFaculty.length,
                            itemBuilder: (context, index) {
              final faculty = _filteredFaculty[index];
              return Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      faculty.name.isNotEmpty
                          ? faculty.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(faculty.name),
                  subtitle: Text(
                      '${faculty.designation ?? 'Faculty'} • ${faculty.department ?? 'N/A'}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${faculty.facultyId ?? 'N/A'}'),
                          Text('Email: ${faculty.email}'),
                          Text('Department: ${faculty.department ?? 'N/A'}'),
                          Text(
                              'Designation: ${faculty.designation ?? 'N/A'}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _showEditDialog(faculty),
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

  Future<void> _showEditDialog(app_model.User faculty) async {
    final nameController = TextEditingController(text: faculty.name);
    final deptController =
        TextEditingController(text: faculty.department ?? '');
    final designationController =
        TextEditingController(text: faculty.designation ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Faculty'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department')),
              TextField(
                  controller: designationController,
                  decoration:
                      const InputDecoration(labelText: 'Designation')),
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
      await _db.updateUser(faculty.uid, {
        'name': nameController.text.trim(),
        'department': deptController.text.trim(),
        'designation': designationController.text.trim(),
      });
      _loadFaculty();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty updated')),
        );
      }
    }
  }
}
