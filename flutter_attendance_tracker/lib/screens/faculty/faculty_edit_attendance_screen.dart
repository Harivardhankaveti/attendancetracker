import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FacultyEditAttendanceScreen extends StatelessWidget {
  const FacultyEditAttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Attendance',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: const Center(
        child: Text('Edit Attendance - Coming Soon'),
      ),
    );
  }
}
