import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String code;
  final String name;
  final String description;
  final String department;
  final int credits;
  final String facultyId;
  final String facultyName;
  final List<String> students;
  final CourseSchedule schedule;
  final String semester;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.department,
    required this.credits,
    required this.facultyId,
    required this.facultyName,
    required this.students,
    required this.schedule,
    required this.semester,
    required this.createdAt,
  });

  // Create Course from Firestore document
  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      department: data['department'] ?? '',
      credits: data['credits'] ?? 0,
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      students: List<String>.from(data['students'] ?? []),
      schedule: CourseSchedule.fromMap(data['schedule'] ?? {}),
      semester: data['semester'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert Course to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'department': department,
      'credits': credits,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'students': students,
      'schedule': schedule.toMap(),
      'semester': semester,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with method for updates
  Course copyWith({
    String? code,
    String? name,
    String? description,
    String? department,
    int? credits,
    String? facultyId,
    String? facultyName,
    List<String>? students,
    CourseSchedule? schedule,
    String? semester,
  }) {
    return Course(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      department: department ?? this.department,
      credits: credits ?? this.credits,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      students: students ?? this.students,
      schedule: schedule ?? this.schedule,
      semester: semester ?? this.semester,
      createdAt: createdAt,
    );
  }
}

class CourseSchedule {
  final List<String> days;
  final String time;
  final String room;

  CourseSchedule({
    required this.days,
    required this.time,
    required this.room,
  });

  // Create CourseSchedule from Map
  factory CourseSchedule.fromMap(Map<String, dynamic> data) {
    return CourseSchedule(
      days: List<String>.from(data['days'] ?? []),
      time: data['time'] ?? '',
      room: data['room'] ?? '',
    );
  }

  // Convert CourseSchedule to Map
  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'time': time,
      'room': room,
    };
  }

  // Copy with method for updates
  CourseSchedule copyWith({
    List<String>? days,
    String? time,
    String? room,
  }) {
    return CourseSchedule(
      days: days ?? this.days,
      time: time ?? this.time,
      room: room ?? this.room,
    );
  }

  // Get formatted schedule string
  String get formattedSchedule {
    return '${days.join(', ')} • $time • $room';
  }
}
