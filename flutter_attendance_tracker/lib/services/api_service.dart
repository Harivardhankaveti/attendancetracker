import 'package:dio/dio.dart';
import '../core/config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

  // Initialize Dio
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  // Set auth token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Handle errors
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          throw ApiException('Unauthorized. Please login again.');
        } else if (statusCode == 404) {
          throw ApiException('Resource not found.');
        } else if (statusCode == 500) {
          throw ApiException('Server error. Please try again later.');
        }
        throw ApiException('Request failed with status: $statusCode');
      case DioExceptionType.cancel:
        throw ApiException('Request cancelled.');
      default:
        throw ApiException('Network error. Please check your connection.');
    }
  }

  // Auth APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // User APIs
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(ApiConfig.userByIdEndpoint(userId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        ApiConfig.usersEndpoint,
        data: userData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Student APIs
  Future<List<dynamic>> getAllStudents() async {
    try {
      final response = await _dio.get(ApiConfig.studentsEndpoint);
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<List<dynamic>> getStudentsByClass(String className) async {
    try {
      final response = await _dio.get(ApiConfig.studentsByClassEndpoint(className));
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudentAttendance(String studentId, String date) async {
    try {
      final response = await _dio.get(
        ApiConfig.studentAttendanceEndpoint(studentId),
        queryParameters: {'date': date},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _dio.post(
        ApiConfig.studentsEndpoint,
        data: studentData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Attendance APIs
  Future<Map<String, dynamic>> markAttendance(Map<String, dynamic> attendanceData) async {
    try {
      final response = await _dio.post(
        ApiConfig.attendanceEndpoint,
        data: attendanceData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<List<dynamic>> getAttendanceByDate(String date, String? className) async {
    try {
      final response = await _dio.get(
        ApiConfig.attendanceEndpoint,
        queryParameters: {
          'date': date,
          if (className != null) 'class': className,
        },
      );
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAttendanceStats(
    String studentId,
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.attendanceStatsEndpoint(studentId),
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Timetable APIs
  Future<List<dynamic>> getTimetableByClass(String className) async {
    try {
      final response = await _dio.get(ApiConfig.timetableByClassEndpoint(className));
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTimetable(Map<String, dynamic> timetableData) async {
    try {
      final response = await _dio.put(
        ApiConfig.timetableEndpoint,
        data: timetableData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
