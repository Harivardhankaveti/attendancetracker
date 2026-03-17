import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String courseId;
  final DateTime date;
  final String facultyId;
  final int totalStudents;
  final int presentStudents;
  final List<AttendanceRecord> students;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.courseId,
    required this.date,
    required this.facultyId,
    required this.totalStudents,
    required this.presentStudents,
    required this.students,
    required this.createdAt,
  });

  // Create Attendance from Firestore document
  factory Attendance.fromMap(Map<String, dynamic> data, String documentId) {
    return Attendance(
      id: documentId,
      courseId: data['courseId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      facultyId: data['facultyId'] ?? '',
      totalStudents: data['totalStudents'] ?? 0,
      presentStudents: data['presentStudents'] ?? 0,
      students: (data['students'] as List<dynamic>?)
              ?.map((e) => AttendanceRecord.fromMap(e))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert Attendance to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'date': Timestamp.fromDate(date),
      'facultyId': facultyId,
      'totalStudents': totalStudents,
      'presentStudents': presentStudents,
      'students': students.map((student) => student.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with method for updates
  Attendance copyWith({
    String? courseId,
    DateTime? date,
    String? facultyId,
    int? totalStudents,
    int? presentStudents,
    List<AttendanceRecord>? students,
  }) {
    return Attendance(
      id: id,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      facultyId: facultyId ?? this.facultyId,
      totalStudents: totalStudents ?? this.totalStudents,
      presentStudents: presentStudents ?? this.presentStudents,
      students: students ?? this.students,
      createdAt: createdAt,
    );
  }

  // Get attendance percentage
  double get attendancePercentage {
    return totalStudents > 0 ? (presentStudents / totalStudents) * 100 : 0;
  }

  // Get student attendance record by student ID
  AttendanceRecord? getStudentRecord(String studentId) {
    try {
      return students.firstWhere((record) => record.studentId == studentId);
    } catch (e) {
      return null;
    }
  }

  // Check if student is present
  bool isStudentPresent(String studentId) {
    final record = getStudentRecord(studentId);
    return record?.isPresent ?? false;
  }
}

class AttendanceRecord {
  final String studentId;
  final bool isPresent;
  final DateTime? timestamp;

  AttendanceRecord({
    required this.studentId,
    required this.isPresent,
    this.timestamp,
  });

  // Create AttendanceRecord from Map
  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      studentId: data['studentId'] ?? '',
      isPresent: data['isPresent'] ?? false,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert AttendanceRecord to Map
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'isPresent': isPresent,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }

  // Copy with method for updates
  AttendanceRecord copyWith({
    String? studentId,
    bool? isPresent,
    DateTime? timestamp,
  }) {
    return AttendanceRecord(
      studentId: studentId ?? this.studentId,
      isPresent: isPresent ?? this.isPresent,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// Helper class for attendance statistics
class AttendanceStats {
  final String courseId;
  final String studentId;
  final int totalClasses;
  final int classesAttended;
  final double attendancePercentage;

  AttendanceStats({
    required this.courseId,
    required this.studentId,
    required this.totalClasses,
    required this.classesAttended,
    required this.attendancePercentage,
  });

  // Create from Firestore data
  factory AttendanceStats.fromMap(Map<String, dynamic> data) {
    return AttendanceStats(
      courseId: data['courseId'] ?? '',
      studentId: data['studentId'] ?? '',
      totalClasses: data['totalClasses'] ?? 0,
      classesAttended: data['classesAttended'] ?? 0,
      attendancePercentage: (data['attendancePercentage'] ?? 0).toDouble(),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'studentId': studentId,
      'totalClasses': totalClasses,
      'classesAttended': classesAttended,
      'attendancePercentage': attendancePercentage,
    };
  }
}
