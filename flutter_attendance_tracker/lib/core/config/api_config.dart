class ApiConfig {
  // Base URL for the Node.js backend
  // Change this to your actual server URL in production
  static const String baseUrl = 'http://localhost:3000/api';
  
  // API Endpoints
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  
  // User endpoints
  static const String usersEndpoint = '/users';
  static String userByIdEndpoint(String userId) => '/users/$userId';
  
  // Student endpoints
  static const String studentsEndpoint = '/students';
  static String studentsByClassEndpoint(String className) => '/students/class/$className';
  static String studentAttendanceEndpoint(String studentId) => '/students/$studentId/attendance';
  
  // Attendance endpoints
  static const String attendanceEndpoint = '/attendance';
  static String attendanceStatsEndpoint(String studentId) => '/attendance/stats/$studentId';
  
  // Timetable endpoints
  static String timetableByClassEndpoint(String className) => '/timetable/$className';
  static const String timetableEndpoint = '/timetable';
  
  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
