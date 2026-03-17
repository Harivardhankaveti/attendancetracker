import 'package:flutter/material.dart';

class AdminFacultyScreen extends StatefulWidget {
  const AdminFacultyScreen({super.key});

  @override
  State<AdminFacultyScreen> createState() => _AdminFacultyScreenState();
}

class _AdminFacultyScreenState extends State<AdminFacultyScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // Sample data - would come from backend in real implementation
  final List<Map<String, dynamic>> _faculty = [
    {
      'id': 'FAC001',
      'name': 'Dr. Sarah Johnson',
      'email': 'sarah.johnson@university.edu',
      'department': 'Computer Science',
      'designation': 'Professor',
      'courses': ['CS101', 'CS301', 'CS501'],
      'status': 'active',
    },
    {
      'id': 'FAC002',
      'name': 'Dr. Michael Chen',
      'email': 'michael.chen@university.edu',
      'department': 'Mathematics',
      'designation': 'Associate Professor',
      'courses': ['MATH201', 'MATH401'],
      'status': 'active',
    },
    {
      'id': 'FAC003',
      'name': 'Dr. Emily Rodriguez',
      'email': 'emily.rodriguez@university.edu',
      'department': 'Physics',
      'designation': 'Assistant Professor',
      'courses': ['PHYS101', 'PHYS301'],
      'status': 'on leave',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Faculty'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add faculty screen
            },
          ),
        ],
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
              items: const [
                DropdownMenuItem(value: '', child: Text('All Departments')),
                DropdownMenuItem(value: 'CS', child: Text('Computer Science')),
                DropdownMenuItem(value: 'MATH', child: Text('Mathematics')),
                DropdownMenuItem(value: 'PHYS', child: Text('Physics')),
                DropdownMenuItem(value: 'ENG', child: Text('Engineering')),
              ],
              onChanged: (value) {},
              value: '',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _faculty.length,
                      itemBuilder: (context, index) {
                        final faculty = _faculty[index];
                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade100,
                              child: Text(faculty['name'].split(' ')[1][0],
                                  style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(faculty['name']),
                            subtitle: Text(
                                '${faculty['designation']} • ${faculty['department']}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${faculty['id']}'),
                                    Text('Email: ${faculty['email']}'),
                                    Text(
                                        'Courses: ${faculty['courses'].join(', ')}'),
                                    Text('Status: ${faculty['status']}'),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text('Edit'),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text('Assign Courses'),
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
          ],
        ),
      ),
    );
  }
}
