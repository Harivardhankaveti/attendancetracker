import 'package:flutter/material.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final String? courseId;

  const StudentCourseDetailScreen({super.key, this.courseId});

  @override
  State<StudentCourseDetailScreen> createState() =>
      _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> {
  // Sample course data - would come from backend in real implementation
  Map<String, dynamic> _course = {
    'id': 'CS101',
    'code': 'CS101',
    'name': 'Introduction to Computer Science',
    'description':
        'Learn the fundamentals of computer science and programming concepts.',
    'credits': 3,
    'semester': 'Fall 2023',
    'instructor': 'Dr. John Smith',
    'schedule': 'Mon, Wed 10:00 AM - 11:30 AM',
    'location': 'Room 205, Building A',
    'attendanceStats': {
      'totalClasses': 30,
      'classesAttended': 25,
      'attendancePercentage': 83.3,
    },
    'upcomingClasses': [
      {'date': '2023-09-25', 'topic': 'Object-Oriented Programming'},
      {'date': '2023-09-27', 'topic': 'Data Structures Basics'},
    ],
    'resources': [
      {'name': 'Lecture Notes Chapter 1', 'type': 'PDF'},
      {'name': 'Assignment 1', 'type': 'Document'},
      {'name': 'Quiz 1', 'type': 'Online Quiz'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_course['code']} - ${_course['name']}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _course['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _course['code'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_course['credits']} Credits',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _course['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          Icons.person, 'Instructor', _course['instructor']),
                      _buildInfoRow(
                          Icons.access_time, 'Schedule', _course['schedule']),
                      _buildInfoRow(
                          Icons.location_on, 'Location', _course['location']),
                      _buildInfoRow(
                          Icons.school, 'Semester', _course['semester']),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Attendance Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_course['attendanceStats']['attendancePercentage']}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text(
                                  'Attendance Rate',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${_course['attendanceStats']['classesAttended']}/${_course['attendanceStats']['totalClasses']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Classes',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _course['attendanceStats']
                                ['attendancePercentage'] /
                            100,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _getStatusChip(75, 'Good', Colors.green),
                          _getStatusChip(60, 'Average', Colors.orange),
                          _getStatusChip(0, 'Poor', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Upcoming Classes
              const Text(
                'Upcoming Classes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._course['upcomingClasses'].map((classInfo) => Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade100,
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(classInfo['date']),
                      subtitle: Text(classInfo['topic']),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  )),

              const SizedBox(height: 16),

              // Resources
              const Text(
                'Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._course['resources'].map((resource) => Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                        ),
                        child: Icon(
                          _getResourceIcon(resource['type']),
                          color: Colors.grey[700],
                        ),
                      ),
                      title: Text(resource['name']),
                      subtitle: Text(resource['type']),
                      trailing: const Icon(Icons.download),
                      onTap: () {
                        // Handle resource download/open
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusChip(double threshold, String label, Color color) {
    final currentPercentage =
        _course['attendanceStats']['attendancePercentage'];
    final isActive = currentPercentage >= threshold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isActive ? color : Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? color : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Document':
        return Icons.insert_drive_file;
      case 'Online Quiz':
        return Icons.quiz;
      default:
        return Icons.insert_drive_file;
    }
  }
}
