class TimetableModel {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String dayOfWeek; // 'Monday', 'Tuesday', etc.
  final String startTime; // e.g., '09:00'
  final String endTime; // e.g., '10:00'
  final String? room;
  final String? building;
  final String facultyId;
  final String? facultyName;
  final String? semester;
  final String? section;
  final DateTime? createdAt;

  TimetableModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.building,
    required this.facultyId,
    this.facultyName,
    this.semester,
    this.section,
    this.createdAt,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json, String id) {
    return TimetableModel(
      id: id,
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      courseCode: json['courseCode'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      room: json['room'],
      building: json['building'],
      facultyId: json['facultyId'] ?? '',
      facultyName: json['facultyName'],
      semester: json['semester'],
      section: json['section'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : (json['createdAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      if (room != null) 'room': room,
      if (building != null) 'building': building,
      'facultyId': facultyId,
      if (facultyName != null) 'facultyName': facultyName,
      if (semester != null) 'semester': semester,
      if (section != null) 'section': section,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  String get location {
    if (room != null && building != null) {
      return '$building - $room';
    } else if (room != null) {
      return room!;
    } else if (building != null) {
      return building!;
    }
    return 'TBA';
  }

  String get timeSlot => '$startTime - $endTime';

  @override
  String toString() {
    return 'TimetableModel(id: $id, course: $courseCode, day: $dayOfWeek, time: $timeSlot)';
  }
}
