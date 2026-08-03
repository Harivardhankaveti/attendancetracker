import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';
import '../../services/database_service.dart';

class AdminNotificationsView extends StatefulWidget {
  const AdminNotificationsView({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsView> createState() => _AdminNotificationsViewState();
}

class _AdminNotificationsViewState extends State<AdminNotificationsView> {
  int _activeTabIndex = 0;
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseConfig.firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      List<Map<String, dynamic>> notifications = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        notifications.add({'id': doc.id, ...data});
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedTarget = 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Notification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTarget,
                  decoration: const InputDecoration(
                    labelText: 'Send To',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Everyone')),
                    DropdownMenuItem(
                        value: 'student', child: Text('All Students')),
                    DropdownMenuItem(
                        value: 'faculty', child: Text('All Faculty')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTarget = value ?? 'all';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    messageController.text.trim().isEmpty) return;

                await _db.createNotification(
                  title: titleController.text.trim(),
                  message: messageController.text.trim(),
                  type: 'general',
                  targetRole: selectedTarget == 'all' ? null : selectedTarget,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Notification sent successfully')),
                  );
                  _loadNotifications();
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await FirebaseConfig.firestore
          .collection('notifications')
          .doc(id)
          .delete();
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = timestamp is DateTime
          ? timestamp
          : (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return '';
    }
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'attendance':
        return Icons.check_circle;
      case 'exam':
        return Icons.calendar_month;
      case 'timetable':
        return Icons.schedule;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.campaign;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'attendance':
        return Colors.blue;
      case 'exam':
        return Colors.red;
      case 'timetable':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      default:
        return AppColors.adminColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Notification\nManagement',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.adminColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create, track, and manage all school-wide broadcasts.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _showCreateNotificationDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Create New Notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_notifications.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.notifications_none,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No notifications yet',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._notifications.map((notification) {
                      return _buildNotificationCard(
                        notification: notification,
                      );
                    }).toList(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'admin_notifications_fab',
              onPressed: _showCreateNotificationDialog,
              backgroundColor: AppColors.adminColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required Map<String, dynamic> notification,
  }) {
    final type = notification['type'] as String?;
    final iconColor = _getIconColor(type);
    final targetRole = notification['targetRole'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(type), color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification['title'] ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () => _deleteNotification(notification['id']),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification['message'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatTime(notification['timestamp']),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                targetRole == null
                    ? 'Everyone'
                    : targetRole == 'student'
                        ? 'Students'
                        : 'Faculty',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
