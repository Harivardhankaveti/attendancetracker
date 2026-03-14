class CourseModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String facultyId;
  final String? facultyName;
  final List<String> students; // List of student UIDs
  final int? credits;
  final String? semester;
  final String? department;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.facultyId,
    this.facultyName,
    required this.students,
    this.credits,
    this.semester,
    this.department,
    this.createdAt,
    this.metadata,
  });

  // Create CourseModel from Firestore document
  factory CourseModel.fromJson(Map<String, dynamic> json, String id) {
    return CourseModel(
      id: id,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      facultyId: json['facultyId'] ?? '',
      facultyName: json['facultyName'],
      students: (json['students'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      credits: json['credits'] as int?,
      semester: json['semester'],
      department: json['department'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : (json['createdAt'] as dynamic).toDate())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert CourseModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      'facultyId': facultyId,
      if (facultyName != null) 'facultyName': facultyName,
      'students': students,
      if (credits != null) 'credits': credits,
      if (semester != null) 'semester': semester,
      if (department != null) 'department': department,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Create a copy of CourseModel with updated fields
  CourseModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? facultyId,
    String? facultyName,
    List<String>? students,
    int? credits,
    String? semester,
    String? department,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return CourseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      students: students ?? this.students,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get total number of students enrolled
  int get studentCount => students.length;

  // Check if a student is enrolled in this course
  bool isStudentEnrolled(String studentId) => students.contains(studentId);

  @override
  String toString() {
    return 'CourseModel(id: $id, code: $code, name: $name, facultyId: $facultyId, students: ${students.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
