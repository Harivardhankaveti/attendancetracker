class AttendanceModel {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final DateTime date;
  final String facultyId;
  final String? facultyName;
  final List<StudentAttendance> students;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  AttendanceModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.date,
    required this.facultyId,
    this.facultyName,
    required this.students,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Create AttendanceModel from Firestore document
  factory AttendanceModel.fromJson(Map<String, dynamic> json, String id) {
    return AttendanceModel(
      id: id,
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      courseCode: json['courseCode'] ?? '',
      date: json['date'] != null
          ? (json['date'] is String
              ? DateTime.parse(json['date'] as String)
              : (json['date'] as dynamic).toDate())
          : DateTime.now(),
      facultyId: json['facultyId'] ?? '',
      facultyName: json['facultyName'],
      students: (json['students'] as List<dynamic>?)
              ?.map((e) => StudentAttendance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : (json['createdAt'] as dynamic).toDate())
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'] as String)
              : (json['updatedAt'] as dynamic).toDate())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert AttendanceModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'date': date.toIso8601String(),
      'facultyId': facultyId,
      if (facultyName != null) 'facultyName': facultyName,
      'students': students.map((s) => s.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Calculate attendance statistics
  AttendanceStats get stats {
    final total = students.length;
    final present = students.where((s) => s.isPresent).length;
    final absent = total - present;
    final percentage = total > 0 ? (present / total) * 100 : 0.0;

    return AttendanceStats(
      totalStudents: total,
      presentStudents: present,
      absentStudents: absent,
      percentage: percentage,
    );
  }

  // Get present students
  List<StudentAttendance> get presentStudents =>
      students.where((s) => s.isPresent).toList();

  // Get absent students
  List<StudentAttendance> get absentStudents =>
      students.where((s) => !s.isPresent).toList();

  @override
  String toString() {
    return 'AttendanceModel(id: $id, courseId: $courseId, date: $date, present: ${stats.presentStudents}/${stats.totalStudents})';
  }
}

// Student attendance record
class StudentAttendance {
  final String studentId;
  final String studentName;
  final String? rollNumber;
  final bool isPresent;
  final String? remarks;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    this.rollNumber,
    required this.isPresent,
    this.remarks,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      rollNumber: json['rollNumber'],
      isPresent: json['isPresent'] ?? false,
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      if (rollNumber != null) 'rollNumber': rollNumber,
      'isPresent': isPresent,
      if (remarks != null) 'remarks': remarks,
    };
  }

  StudentAttendance copyWith({
    String? studentId,
    String? studentName,
    String? rollNumber,
    bool? isPresent,
    String? remarks,
  }) {
    return StudentAttendance(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      isPresent: isPresent ?? this.isPresent,
      remarks: remarks ?? this.remarks,
    );
  }
}

// Attendance statistics helper class
class AttendanceStats {
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;
  final double percentage;

  AttendanceStats({
    required this.totalStudents,
    required this.presentStudents,
    required this.absentStudents,
    required this.percentage,
  });
}
