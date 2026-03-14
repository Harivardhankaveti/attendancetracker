import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? studentId;
  final String? facultyId;
  final String? department;
  final String? year;
  final String? designation;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.studentId,
    this.facultyId,
    this.department,
    this.year,
    this.designation,
    required this.createdAt,
    this.lastLogin,
  });

  /// 🔹 FROM FIRESTORE
  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      studentId: data['studentId'],
      facultyId: data['facultyId'],
      department: data['department'],
      year: data['year'],
      designation: data['designation'],

      /// ✅ SAFE createdAt (never null)
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      /// ✅ SAFE lastLogin
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  /// 🔹 TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'studentId': studentId,
      'facultyId': facultyId,
      'department': department,
      'year': year,
      'designation': designation,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  /// 🔹 COPY WITH
  User copyWith({
    String? email,
    String? name,
    String? role,
    String? studentId,
    String? facultyId,
    String? department,
    String? year,
    String? designation,
    DateTime? lastLogin,
  }) {
    return User(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      facultyId: facultyId ?? this.facultyId,
      department: department ?? this.department,
      year: year ?? this.year,
      designation: designation ?? this.designation,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
