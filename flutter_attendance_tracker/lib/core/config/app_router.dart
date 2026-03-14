import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/student/student_dashboard_screen.dart';
import '../../screens/student/student_attendance_screen.dart';
import '../../screens/student/student_settings_screen.dart';
import '../../screens/student/student_notifications_screen.dart';
import '../../screens/student/student_course_detail_screen.dart';
import '../../screens/faculty/faculty_dashboard_screen.dart';
import '../../screens/faculty/faculty_mark_attendance_screen.dart';
import '../../screens/faculty/faculty_view_attendance_screen.dart';
import '../../screens/faculty/faculty_edit_attendance_screen.dart';
import '../../screens/faculty/faculty_notifications_screen.dart';
import '../../screens/faculty/faculty_profile_screen.dart';
import '../../screens/faculty/faculty_add_course_screen.dart';
import '../../screens/faculty/faculty_timetable_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_student_attendance_screen.dart';
import '../../screens/admin/admin_faculty_attendance_screen.dart';
import '../../screens/admin/admin_events_screen.dart';
import '../../screens/admin/admin_exam_schedule_screen.dart';
import '../../screens/admin/admin_post_timetable_screen.dart';
import '../../screens/admin/admin_feedback_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/admin/admin_students_screen.dart';
import '../../screens/admin/admin_faculty_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authProvider,

    // ✅ FIXED ASYNC REDIRECT
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuthenticated = authProvider.isAuthenticated;
      final isInitialized = authProvider.isInitialized;

      // Wait until auth initializes
      if (!isInitialized) return null;

      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');

      // Not logged in → redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Logged in but trying to access login/register → redirect to dashboard
      if (isAuthenticated && isAuthRoute) {
        final role = await authProvider.getUserRole();
        return authProvider.getDashboardRoute(role);
      }

      // Role-based protection
      if (isAuthenticated) {
        final currentRoute = state.matchedLocation;
        final role = await authProvider.getUserRole();

        // Student restrictions
        if (role == 'student' && !currentRoute.startsWith('/student')) {
          return AppRoutes.studentDashboard;
        }

        // Faculty restrictions
        if (role == 'faculty' && !currentRoute.startsWith('/faculty')) {
          return AppRoutes.facultyDashboard;
        }

        // Admin restrictions
        if (role == 'admin' && !currentRoute.startsWith('/admin')) {
          return AppRoutes.adminDashboard;
        }
      }

      return null;
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Student Routes
      GoRoute(
        path: AppRoutes.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAttendance,
        builder: (context, state) => const StudentAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentTimetable,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Student Timetable'),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Student Profile'),
      ),
      GoRoute(
        path: AppRoutes.studentSettings,
        builder: (context, state) => const StudentSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentNotifications,
        builder: (context, state) => const StudentNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCourseDetail,
        builder: (context, state) => StudentCourseDetailScreen(
            courseId: state.pathParameters['courseId']),
      ),

      // Faculty Routes
      GoRoute(
        path: AppRoutes.facultyDashboard,
        builder: (context, state) => const FacultyDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyMarkAttendance,
        builder: (context, state) => const FacultyMarkAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyViewAttendance,
        builder: (context, state) => const FacultyViewAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyEditAttendance,
        builder: (context, state) => const FacultyEditAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyNotifications,
        builder: (context, state) => const FacultyNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyProfile,
        builder: (context, state) => const FacultyProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyAddCourse,
        builder: (context, state) => const FacultyAddCourseScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyTimetable,
        builder: (context, state) => const FacultyTimetableScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminStudents,
        builder: (context, state) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminFaculty,
        builder: (context, state) => const AdminFacultyScreen(),
      ),
      GoRoute(
        path: '/admin/student-attendance',
        builder: (context, state) => const AdminStudentAttendanceScreen(),
      ),
      GoRoute(
        path: '/admin/faculty-attendance',
        builder: (context, state) => const AdminFacultyAttendanceScreen(),
      ),
      GoRoute(
        path: '/admin/events',
        builder: (context, state) => const AdminEventsScreen(),
      ),
      GoRoute(
        path: '/admin/exam-schedule',
        builder: (context, state) => const AdminExamScheduleScreen(),
      ),
      GoRoute(
        path: '/admin/post-timetable',
        builder: (context, state) => const AdminPostTimetableScreen(),
      ),
      GoRoute(
        path: '/admin/feedback',
        builder: (context, state) => const AdminFeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAttendance,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Attendance Management'),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (context, state) => const PlaceholderScreen(title: 'Reports'),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}

// Placeholder screen
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'This screen is under construction',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
