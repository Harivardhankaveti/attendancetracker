import 'package:flutter/material.dart';

class FacultyTimetableScreen extends StatefulWidget {
  const FacultyTimetableScreen({super.key});

  @override
  State<FacultyTimetableScreen> createState() => _FacultyTimetableScreenState();
}

class _FacultyTimetableScreenState extends State<FacultyTimetableScreen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  
  // Sample timetable data - would come from backend in real implementation
  final Map<String, List<Map<String, dynamic>>> _timetable = {
    'Mon': [
      {
        'time': '09:00 - 10:30',
        'course': 'CS101',
        'subject': 'Introduction to Programming',
        'room': 'Lab 1',
        'students': 45,
      },
      {
        'time': '11:00 - 12:30',
        'course': 'CS301',
        'subject': 'Data Structures',
        'room': 'Room 205',
        'students': 38,
      },
    ],
    'Tue': [
      {
        'time': '10:00 - 11:30',
        'course': 'CS501',
        'subject': 'Advanced Algorithms',
        'room': 'Room 301',
        'students': 25,
      },
    ],
    'Wed': [
      {
        'time': '09:00 - 10:30',
        'course': 'CS101',
        'subject': 'Introduction to Programming',
        'room': 'Lab 1',
        'students': 45,
      },
    ],
    'Thu': [
      {
        'time': '14:00 - 15:30',
        'course': 'CS301',
        'subject': 'Data Structures',
        'room': 'Room 205',
        'students': 38,
      },
    ],
    'Fri': [
      {
        'time': '10:00 - 11:30',
        'course': 'CS501',
        'subject': 'Advanced Algorithms',
        'room': 'Room 301',
        'students': 25,
      },
    ],
    'Sat': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: _days.length,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: _days.map((day) => Tab(text: day)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: _days.map((day) => _buildDaySchedule(day)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    final classes = _timetable[day] ?? [];
    
    if (classes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No classes scheduled',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            Text(
              'Enjoy your free day!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classInfo = classes[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              classInfo['subject'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${classInfo['time']} | ${classInfo['room']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${classInfo['course']} • ${classInfo['students']} students',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit class screen
              },
            ),
          ),
        );
      },
    );
  }
}