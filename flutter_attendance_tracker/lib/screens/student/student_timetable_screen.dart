import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import '../../core/utils/logger.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({Key? key}) : super(key: key);

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  String _selectedDay = 'Monday';
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  List<TimetableEntry> _schedule = [];
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
      // Fetch student's courses
      final coursesSnapshot = await FirebaseConfig.firestore
          .collection('courses')
          .where('students', arrayContains: userId)
          .get();

      List<TimetableEntry> allEntries = [];

      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();

        // Fetch timetable for each course
        final timetableSnapshot = await FirebaseConfig.firestore
            .collection('timetable')
            .where('courseId', isEqualTo: courseDoc.id)
            .get();

        for (var ttDoc in timetableSnapshot.docs) {
          final ttData = ttDoc.data();
          allEntries.add(TimetableEntry(
            courseCode: courseData['code'] ?? '',
            courseName: courseData['name'] ?? '',
            faculty: ttData['facultyName'] ??
                'Dr.${courseData['facultyName'] ?? 'Faculty'}',
            room: ttData['room'] ?? '1357',
            startTime: ttData['startTime'] ?? '9:00',
            endTime: ttData['endTime'] ?? '10:00',
            dayOfWeek: ttData['dayOfWeek'] ?? 'Monday',
          ));
        }
      }

      setState(() {
        _schedule = allEntries;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading timetable: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TimetableEntry> get _todaySchedule {
    return _schedule.where((entry) => entry.dayOfWeek == _selectedDay).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: const Text(
                'Timetable',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Day Selector
            Container(
              height: 60,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = day == _selectedDay;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Schedule Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "$_selectedDay's Schedule",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Schedule List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _todaySchedule.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.calendar_today,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No classes scheduled',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _todaySchedule.length,
                          itemBuilder: (context, index) {
                            final entry = _todaySchedule[index];
                            return _buildScheduleCard(entry);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(TimetableEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time,
                    color: AppColors.primary, size: 20),
                const SizedBox(height: 4),
                Text(
                  entry.startTime,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Text('-', style: TextStyle(fontSize: 10)),
                Text(
                  entry.endTime,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Course details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.courseCode} (${entry.courseName})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      entry.faculty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      entry.room,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimetableEntry {
  final String courseCode;
  final String courseName;
  final String faculty;
  final String room;
  final String startTime;
  final String endTime;
  final String dayOfWeek;

  TimetableEntry({
    required this.courseCode,
    required this.courseName,
    required this.faculty,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
  });
}
