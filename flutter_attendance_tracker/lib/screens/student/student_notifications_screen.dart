import 'package:flutter/material.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  // Sample notification data - would come from backend in real implementation
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Attendance Reminder',
      'message':
          'You have classes scheduled today. Don\'t forget to mark your attendance.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'attendance',
      'read': false,
    },
    {
      'id': 2,
      'title': 'Exam Schedule Updated',
      'message':
          'The exam schedule for CS101 has been updated. Check your timetable.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'type': 'exam',
      'read': true,
    },
    {
      'id': 3,
      'title': 'Timetable Change',
      'message': 'Your Physics class has been rescheduled to tomorrow.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'timetable',
      'read': true,
    },
    {
      'id': 4,
      'title': 'Low Attendance Alert',
      'message':
          'Your attendance in Mathematics is below 75%. Please attend upcoming classes.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'warning',
      'read': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'mark_all_read') {
                // Mark all notifications as read
                setState(() {
                  for (var notification in _notifications) {
                    notification['read'] = true;
                  }
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
            ],
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll see important updates here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: notification['read'] ? 1 : 3,
                  color:
                      notification['read'] ? Colors.white : Colors.blue.shade50,
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getNotificationColor(notification['type']),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification['type']),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['read']
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: notification['read']
                            ? Colors.black87
                            : Colors.blue[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification['message'],
                          style: TextStyle(
                            color: notification['read']
                                ? Colors.grey[700]
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification['timestamp']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: notification['read']
                        ? null
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                    onTap: () {
                      // Mark as read when tapped
                      setState(() {
                        notification['read'] = true;
                      });

                      // Handle notification tap based on type
                      _handleNotificationTap(notification);
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'attendance':
        return Colors.blue;
      case 'exam':
        return Colors.orange;
      case 'timetable':
        return Colors.green;
      case 'warning':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'attendance':
        return Icons.check_circle;
      case 'exam':
        return Icons.calendar_today;
      case 'timetable':
        return Icons.schedule;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Handle notification based on type
    switch (notification['type']) {
      case 'attendance':
        // Navigate to attendance screen
        break;
      case 'exam':
        // Navigate to exam schedule screen
        break;
      case 'timetable':
        // Navigate to timetable screen
        break;
      case 'warning':
        // Navigate to attendance details screen
        break;
    }
  }
}
