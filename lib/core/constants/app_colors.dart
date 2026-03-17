import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF4B4B);
  static const Color primaryDark = Color(0xFFFF1744);
  static const Color primaryLight = Color(0xFFFFE5E5);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1976d2);
  static const Color secondaryDark = Color(0xFF0D47A1);
  static const Color secondaryLight = Color(0xFF90CAF9);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5722);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Attendance Status Colors
  static Color getAttendanceColor(double percentage) {
    if (percentage >= 75) return success;
    if (percentage >= 60) return warning;
    return error;
  }
  
  // Role-specific colors
  static const Color studentColor = primary;
  static const Color facultyColor = secondary;
  static const Color adminColor = Color(0xFF8E24AA);
  
  // Quick Action Colors
  static const Color markAttendanceColor = Color(0xFF43a047);
  static const Color viewAttendanceColor = Color(0xFF1976d2);
  static const Color editAttendanceColor = Color(0xFFFF9800);
  static const Color notificationsColor = Color(0xFF8e24aa);
}
