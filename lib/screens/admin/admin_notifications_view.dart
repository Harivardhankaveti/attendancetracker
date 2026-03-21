import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AdminNotificationsView extends StatefulWidget {
  const AdminNotificationsView({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsView> createState() => _AdminNotificationsViewState();
}

class _AdminNotificationsViewState extends State<AdminNotificationsView> {
  int _activeTabIndex = 0;

  void _showCreateNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notification'),
        content: const Text('Backend integration pending. This will open a form to compose a new notification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                        backgroundColor: const Color(0xFFFF5C2C), // Orange color from design
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search and Filters
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by title, teacher, or branch',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.shade400, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_list,
                                        size: 18, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Branch: All',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 18, color: AppColors.adminColor),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Date Range',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tabs
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _activeTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTabIndex == 0 ? AppColors.adminColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: _activeTabIndex == 0 ? null : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'All Updates',
                            style: TextStyle(
                              color: _activeTabIndex == 0 ? Colors.white : AppColors.textPrimary,
                              fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setState(() => _activeTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTabIndex == 1 ? AppColors.adminColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: _activeTabIndex == 1 ? null : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'Teacher Feedback',
                            style: TextStyle(
                              color: _activeTabIndex == 1 ? Colors.white : AppColors.textPrimary,
                              fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notification Cards
                  if (_activeTabIndex == 0) ...[
                    _buildNotificationCard(
                      iconBgColor: const Color(0xFFFFEBEB),
                      iconColor: const Color(0xFFD32F2F),
                      icon: Icons.calendar_month,
                      labels: [
                        _buildChip('HIGH PRIORITY', const Color(0xFFD32F2F),
                            const Color(0xFFFFEBEB)),
                        _buildChip('EXAM REMINDERS', Colors.grey.shade700,
                            Colors.transparent),
                      ],
                      title: 'Final Semester Examinations - Schedule Update',
                      description: 'Revised dates for the Engineering...',
                      leftFooterIcon: Icons.access_time,
                      leftFooterText: 'Sent 2h ago',
                      rightFooterIcon: Icons.visibility,
                      rightFooterText: '1,240 Seen',
                    ),
                    const SizedBox(height: 16),
                    _buildNotificationCard(
                      iconBgColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF2E7D32),
                      icon: Icons.celebration,
                      labels: [
                        _buildChip('SCHEDULED', const Color(0xFF2E7D32),
                            const Color(0xFFE8F5E9)),
                        _buildChip('HOLIDAY ANNOUNCEMENTS', Colors.grey.shade700,
                            Colors.transparent),
                      ],
                      title: 'Spring Break Closure Notice',
                      description: 'Campus will remain closed from April 1st to...',
                      leftFooterIcon: Icons.calendar_today,
                      leftFooterText: 'Sept 15, 2023',
                      rightFooterIcon: Icons.people,
                      rightFooterText: 'All Branches',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_activeTabIndex == 0 || _activeTabIndex == 1) ...[
                    _buildNotificationCard(
                      iconBgColor: AppColors.adminColor.withValues(alpha: 0.1),
                      iconColor: AppColors.adminColor,
                      icon: Icons.chat_bubble_rounded,
                      labels: [
                        _buildChip('TEACHER FEEDBACK', Colors.grey.shade700,
                            Colors.transparent),
                      ],
                      title: 'Weekly Performance Analysis - Section B',
                      description: 'Personalized feedback for the Physics mid...',
                      leftFooterIcon: Icons.person,
                      leftFooterText: 'Prof. Sarah Miller',
                      rightFooterIcon: Icons.location_on,
                      rightFooterText: 'West Wing Campus',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_activeTabIndex == 0) ...[
                    _buildNotificationCard(
                      iconBgColor: Colors.grey.shade200,
                      iconColor: Colors.grey.shade700,
                      icon: Icons.campaign,
                      labels: [
                        _buildChip(
                            'GENERAL', Colors.grey.shade700, Colors.transparent),
                      ],
                      title: 'New Digital Library Credentials',
                      description: 'Access to JSTOR and Elsevier journals...',
                      leftFooterIcon: Icons.calendar_today,
                      leftFooterText: 'Sept 12, 2023',
                      rightFooterIcon: Icons.visibility,
                      rightFooterText: '3,410 Seen',
                    ),
                  ],

                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View Archived Notifications',
                        style: TextStyle(
                          color: AppColors.adminColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // Extra space for FAB
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

  Widget _buildChip(String text, Color textColor, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required List<Widget> labels,
    required String title,
    required String description,
    required IconData leftFooterIcon,
    required String leftFooterText,
    required IconData rightFooterIcon,
    required String rightFooterText,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Row(children: labels),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(leftFooterIcon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                leftFooterText,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(rightFooterIcon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                rightFooterText,
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
