import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/course.dart';

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
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = false;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    _creditsController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    final courses = await _db.getCoursesByFaculty(userId);
    setState(() {
      _courses = courses;
    });
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    final userName = authProvider.user?.name ?? 'Faculty';

    if (userId == null) return;

    setState(() => _isLoading = true);

    final course = Course(
      id: '',
      code: _courseCodeController.text.trim(),
      name: _courseNameController.text.trim(),
      description: _courseDescriptionController.text.trim(),
      department: authProvider.user?.department ?? '',
      credits: int.tryParse(_creditsController.text.trim()) ?? 3,
      facultyId: userId,
      facultyName: userName,
      students: [],
      schedule: CourseSchedule(days: [], time: '', room: ''),
      semester: _semesterController.text.trim(),
      createdAt: DateTime.now(),
    );

    final courseId = await _db.createCourse(course);

    setState(() => _isLoading = false);

    if (courseId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _courseCodeController.clear();
      _courseNameController.clear();
      _courseDescriptionController.clear();
      _creditsController.clear();
      _semesterController.clear();

      _loadCourses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add course'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  hintText: 'e.g., 3',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  hintText: 'e.g., Fall 2025',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
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
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'My Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              if (_courses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No courses yet. Add your first course above.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ..._courses.map((course) => ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.book_outlined),
                      ),
                      title: Text('${course.code} - ${course.name}'),
                      subtitle: Text(course.description.isEmpty
                          ? 'No description'
                          : course.description),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
