import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  bool _pushNotifications = true;
  bool _feedbackAlerts = false;
  bool _biometricUnlock = true;

  void _showDummySnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminName = authProvider.user?.name ?? 'Alexander Pierce';
    final adminEmail = authProvider.user?.email ?? 'a.pierce@timelytrack.edu';

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Profile Section
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.adminColor.withValues(alpha: 0.5),
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.adminColor,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showDummySnackbar('Edit profile photo'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5C2C), // Orange color from design
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                adminName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                adminEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.adminColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'SUPER ADMIN',
                  style: TextStyle(
                    color: AppColors.adminColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // School Management
              _buildSectionTitle('School Management'),
              _buildSectionCard([
                _buildListTile(
                  iconBgColor: AppColors.adminColor.withValues(alpha: 0.1),
                  iconColor: AppColors.adminColor,
                  icon: Icons.account_balance,
                  title: 'Branch',
                  subtitle: 'Main Campus - Downtown',
                  onTap: () => _showDummySnackbar('Manage Branch'),
                ),
                const Divider(height: 1, indent: 64),
                _buildListTile(
                  iconBgColor: AppColors.adminColor.withValues(alpha: 0.1),
                  iconColor: AppColors.adminColor,
                  icon: Icons.layers,
                  title: 'Section',
                  subtitle: 'Senior Secondary',
                  onTap: () => _showDummySnackbar('Manage Section'),
                ),
                const Divider(height: 1, indent: 64),
                _buildListTile(
                  iconBgColor: AppColors.adminColor.withValues(alpha: 0.1),
                  iconColor: AppColors.adminColor,
                  icon: Icons.calendar_month,
                  title: 'Academic Session',
                  subtitle: '2023 - 2024 (Current)',
                  onTap: () => _showDummySnackbar('Manage Academic Session'),
                ),
              ]),

              const SizedBox(height: 24),
              // Notifications
              _buildSectionTitle('Notifications'),
              _buildSectionCard([
                _buildSwitchTile(
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  icon: Icons.notifications_active,
                  title: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (val) {
                    setState(() { _pushNotifications = val; });
                    _showDummySnackbar(val ? 'Push Notifications Enabled' : 'Push Notifications Disabled');
                  },
                ),
                const Divider(height: 1, indent: 64),
                _buildSwitchTile(
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  icon: Icons.feedback,
                  title: 'Feedback Alerts',
                  value: _feedbackAlerts,
                  onChanged: (val) {
                    setState(() { _feedbackAlerts = val; });
                    _showDummySnackbar(val ? 'Feedback Alerts Enabled' : 'Feedback Alerts Disabled');
                  },
                ),
              ]),

              const SizedBox(height: 24),
              // Security
              _buildSectionTitle('Security'),
              _buildSectionCard([
                _buildListTile(
                  iconBgColor: const Color(0xFFFFEBEB),
                  iconColor: const Color(0xFFD32F2F),
                  icon: Icons.lock_reset,
                  title: 'Change Password',
                  onTap: () => _showDummySnackbar('Password reset link sent to your email.'),
                ),
                const Divider(height: 1, indent: 64),
                _buildListTile(
                  iconBgColor: const Color(0xFFFFEBEB),
                  iconColor: const Color(0xFFD32F2F),
                  icon: Icons.fingerprint,
                  title: 'Biometric Unlock',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.adminColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _biometricUnlock ? 'ON' : 'OFF',
                      style: const TextStyle(
                        color: AppColors.adminColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() { _biometricUnlock = !_biometricUnlock; });
                    _showDummySnackbar(_biometricUnlock ? 'Biometric Unlock Enabled' : 'Biometric Unlock Disabled');
                  },
                ),
              ]),

              const SizedBox(height: 24),
              // App Info
              _buildSectionTitle('App Info'),
              _buildSectionCard([
                _buildListTile(
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.grey.shade700,
                  icon: Icons.info_outline,
                  title: 'About Timely Track',
                  onTap: () => _showDummySnackbar('Timely Track v2.4.1 - Attendance Management System'),
                ),
                const Divider(height: 1, indent: 64),
                _buildListTile(
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.grey.shade700,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _showDummySnackbar('Navigating to Help Center...'),
                ),
                const Divider(height: 1, indent: 64),
                _buildListTile(
                  iconBgColor: Colors.grey.shade200,
                  iconColor: Colors.grey.shade700,
                  icon: Icons.update,
                  title: 'App Version',
                  trailing: const Text(
                    'v2.4.1-stable',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => _showDummySnackbar('Your app is up to date!'),
                ),
              ]),

              const SizedBox(height: 32),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C2C), // Orange color from design
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.adminColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
