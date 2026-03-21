import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ✅ FIXED: Use department instead of branch
  String _getBranch() {
    final authProvider = context.read<AuthProvider>();
    return (authProvider.user?.department ?? "cse").toUpperCase();
  }

  // ✅ Section remains same
  String _getSection() {
    final authProvider = context.read<AuthProvider>();
    return authProvider.user?.section ?? "A";
  }

  @override
  Widget build(BuildContext context) {
    String docId = "${_getBranch()}_${_getSection()}";

    print("Fetching timetable for: $docId"); // DEBUG

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Header
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

            // 🔷 Day Selector
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
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔷 Title
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

            // 🔥 TIMETABLE
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseConfig.firestore
                    .collection('timetables')
                    .doc(docId)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text("No timetable found"),
                    );
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var schedule = data['schedule'] as Map<String, dynamic>? ?? {};
                  var daySchedule = schedule[_selectedDay] as Map<String, dynamic>? ?? {};

                  if (daySchedule.isEmpty) {
                    return const Center(
                      child: Text("No classes scheduled for this day"),
                    );
                  }

                  var sortedKeys = daySchedule.keys.toList()
                    ..sort((a, b) => a.compareTo(b));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      String timeSlot = sortedKeys[index];
                      String subject = daySchedule[timeSlot];

                      String startTime = timeSlot;
                      String endTime = '';

                      if (timeSlot.contains('-')) {
                        var parts = timeSlot.split('-');
                        startTime = parts.first.trim();
                        endTime = parts.last.trim();
                      }

                      return _buildScheduleCard(
                        TimetableEntry(
                          courseCode: subject,
                          courseName: '',
                          faculty: 'Instructor',
                          room: 'TBD',
                          startTime: startTime,
                          endTime: endTime,
                          dayOfWeek: _selectedDay,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔷 UI Card
  Widget _buildScheduleCard(TimetableEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ⏰ Time Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                const SizedBox(height: 4),
                Text(
                  entry.startTime,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (entry.endTime.isNotEmpty) ...[
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
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 📚 Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.courseCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: const [
                    Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text("Instructor", style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: const [
                    Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text("Room TBD", style: TextStyle(color: AppColors.textSecondary)),
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

// 📦 Model
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