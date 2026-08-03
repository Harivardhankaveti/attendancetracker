import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import '../../core/utils/logger.dart';

class FacultyTimetableScreen extends StatefulWidget {
  const FacultyTimetableScreen({super.key});

  @override
  State<FacultyTimetableScreen> createState() =>
      _FacultyTimetableScreenState();
}

class _FacultyTimetableScreenState extends State<FacultyTimetableScreen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  Map<String, List<Map<String, dynamic>>> _timetable = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    try {
      final coursesSnapshot = await FirebaseConfig.firestore
          .collection('courses')
          .where('facultyId', isEqualTo: userId)
          .get();

      Map<String, List<Map<String, dynamic>>> timetable = {
        for (var day in _days) day: <Map<String, dynamic>>[]
      };

      for (var courseDoc in coursesSnapshot.docs) {
        final data = courseDoc.data();
        final schedule = data['schedule'] as Map<String, dynamic>?;

        if (schedule != null) {
          final days = schedule['days'] as List<dynamic>? ?? [];
          final time = schedule['time'] as String? ?? '';
          final room = schedule['room'] as String? ?? '';

          for (var day in days) {
            final dayStr = day.toString();
            final shortDay = _mapDayToShort(dayStr);
            if (timetable.containsKey(shortDay)) {
              timetable[shortDay]!.add({
                'time': time,
                'course': data['code'] ?? '',
                'subject': data['name'] ?? '',
                'room': room,
                'students': (data['students'] as List<dynamic>?)?.length ?? 0,
              });
            }
          }
        }
      }

      // Also check timetable collection for faculty-specific entries
      final timetableSnapshot = await FirebaseConfig.firestore
          .collection('timetable')
          .where('facultyId', isEqualTo: userId)
          .get();

      for (var doc in timetableSnapshot.docs) {
        final data = doc.data();
        final day = data['dayOfWeek'] as String? ?? '';
        final shortDay = _mapDayToShort(day);
        if (timetable.containsKey(shortDay)) {
          timetable[shortDay]!.add({
            'time':
                '${data['startTime'] ?? ''} - ${data['endTime'] ?? ''}',
            'course': data['courseCode'] ?? '',
            'subject': data['courseName'] ?? '',
            'room': data['room'] ?? '',
            'students': 0,
          });
        }
      }

      // Sort each day's classes by time
      for (var day in timetable.keys) {
        timetable[day]!.sort((a, b) =>
            (a['time'] as String).compareTo(b['time'] as String));
      }

      setState(() {
        _timetable = timetable;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading timetable: $e');
      setState(() => _isLoading = false);
    }
  }

  String _mapDayToShort(String day) {
    final map = {
      'Monday': 'Mon',
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat',
      'Mon': 'Mon',
      'Tue': 'Tue',
      'Wed': 'Wed',
      'Thu': 'Thu',
      'Fri': 'Fri',
      'Sat': 'Sat',
    };
    return map[day] ?? day.substring(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
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
                      children:
                          _days.map((day) => _buildDaySchedule(day)).toList(),
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
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No classes scheduled',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text('Enjoy your free day!',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classInfo = classes[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          ),
        );
      },
    );
  }
}
