import 'package:flutter/material.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // Sample data - would come from backend in real implementation
  final List<Map<String, dynamic>> _students = [
    {
      'id': 'STU001',
      'name': 'Alice Johnson',
      'email': 'alice@example.com',
      'department': 'Computer Science',
      'year': '3rd Year',
      'status': 'active',
    },
    {
      'id': 'STU002',
      'name': 'Bob Williams',
      'email': 'bob@example.com',
      'department': 'Electrical Engineering',
      'year': '2nd Year',
      'status': 'active',
    },
    {
      'id': 'STU003',
      'name': 'Carol Brown',
      'email': 'carol@example.com',
      'department': 'Mechanical Engineering',
      'year': '4th Year',
      'status': 'graduated',
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
        title: const Text('Manage Students'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add student screen
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
              items: const [
                DropdownMenuItem(value: '', child: Text('All Departments')),
                DropdownMenuItem(value: 'CS', child: Text('Computer Science')),
                DropdownMenuItem(
                    value: 'EE', child: Text('Electrical Engineering')),
                DropdownMenuItem(
                    value: 'ME', child: Text('Mechanical Engineering')),
              ],
              onChanged: (value) {},
              value: '',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(student['name'][0],
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(student['name']),
                            subtitle: Text(
                                '${student['id']} • ${student['department']}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${student['email']}'),
                                    Text('Year: ${student['year']}'),
                                    Text('Status: ${student['status']}'),
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
                                          child: const Text('View Details'),
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
