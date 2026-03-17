class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  
  // Student Routes
  static const String studentDashboard = '/student/dashboard';
  static const String studentAttendance = '/student/attendance';
  static const String studentTimetable = '/student/timetable';
  static const String studentProfile = '/student/profile';
  static const String studentSettings = '/student/settings';
  static const String studentCourseDetail = '/student/course/:courseId';
  static const String studentNotifications = '/student/notifications';
  
  // Faculty Routes
  static const String facultyDashboard = '/faculty/dashboard';
  static const String facultyMarkAttendance = '/faculty/mark-attendance';
  static const String facultyMarkAttendanceCourse = '/faculty/mark-attendance/:courseId';
  static const String facultyViewAttendance = '/faculty/view-attendance';
  static const String facultyViewAttendanceCourse = '/faculty/view-attendance/:courseId';
  static const String facultyEditAttendance = '/faculty/edit-attendance';
  static const String facultyAddCourse = '/faculty/add-course';
  static const String facultyProfile = '/faculty/profile';
  static const String facultyTimetable = '/faculty/timetable';
  static const String facultyNotifications = '/faculty/notifications';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminStudents = '/admin/students';
  static const String adminFaculty = '/admin/faculty';
  static const String adminAttendance = '/admin/attendance';
  static const String adminTimetable = '/admin/timetable';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminLoginMonitor = '/admin/login-monitor';
  static const String adminNotifications = '/admin/notifications';
  
  // Helper methods
  static String studentCourseDetailPath(String courseId) => '/student/course/$courseId';
  static String facultyMarkAttendanceCoursePath(String courseId) => '/faculty/mark-attendance/$courseId';
  static String facultyViewAttendanceCoursePath(String courseId) => '/faculty/view-attendance/$courseId';
}
