import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final notifications =
        await _db.getNotificationsForUser(userId, 'student');

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
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

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = timestamp is DateTime
          ? timestamp
          : (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

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
                for (var notification in _notifications) {
                  if (notification['read'] != true) {
                    _db.markNotificationAsRead(notification['id']);
                  }
                }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
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
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['read'] == true;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: isRead ? 1 : 3,
                        color: isRead
                            ? Colors.white
                            : Colors.blue.shade50,
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getNotificationColor(
                                  notification['type'] ?? ''),
                            ),
                            child: Icon(
                              _getNotificationIcon(
                                  notification['type'] ?? ''),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: isRead
                                  ? Colors.black87
                                  : Colors.blue[800],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notification['message'] ?? ''),
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
                          trailing: isRead
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
                            if (!isRead) {
                              _db.markNotificationAsRead(
                                  notification['id']);
                              setState(() {
                                notification['read'] = true;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
