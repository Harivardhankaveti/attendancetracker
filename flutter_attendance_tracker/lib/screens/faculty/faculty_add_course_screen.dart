import 'package:flutter/material.dart';

class FacultyAddCourseScreen extends StatefulWidget {
  const FacultyAddCourseScreen({super.key});

  @override
  State<FacultyAddCourseScreen> createState() => _FacultyAddCourseScreenState();
}

class _FacultyAddCourseScreenState extends State<FacultyAddCourseScreen> {
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate course addition - replace with actual implementation
    await Future.delayed(const Duration(seconds: 1));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _courseCodeController.clear();
    _courseNameController.clear();
    _courseDescriptionController.clear();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Course'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  hintText: 'e.g., CS101',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'e.g., Introduction to Computer Science',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the course',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _addCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Add Course',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),
              // Course List Section
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'My Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.book_outlined),
                ),
                title: Text('CS101 - Introduction to Computer Science'),
                subtitle: Text('Basic programming concepts'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: null, // Would navigate to course details
              ),
              const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.book_outlined),
                ),
                title: Text('CS201 - Data Structures'),
                subtitle: Text('Advanced data organization'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: null, // Would navigate to course details
              ),
            ],
          ),
        ),
      ),
    );
  }
}
