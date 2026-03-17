import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? rollNumber;
  final String? department;
  final String? phoneNumber;
  final String? employeeId;
  final String? qualification;
  final String? joiningDate;
  final Timestamp? createdAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.rollNumber,
    this.department,
    this.phoneNumber,
    this.employeeId,
    this.qualification,
    this.joiningDate,
    this.createdAt,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      rollNumber: json['rollNumber'],
      department: json['department'],
      phoneNumber: json['phoneNumber'], // ✅ FIXED
      employeeId: json['employeeId'],
      qualification: json['qualification'],
      joiningDate: json['joiningDate'],
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] : null,
      metadata:
          json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "rollNumber": rollNumber,
      "department": department,
      "phoneNumber": phoneNumber,
      "employeeId": employeeId,
      "qualification": qualification,
      "joiningDate": joiningDate,
      "createdAt": createdAt,
      "metadata": metadata,
    };
  }

  bool get isStudent => role.toLowerCase() == 'student';
  bool get isFaculty => role.toLowerCase() == 'faculty';
  bool get isAdmin => role.toLowerCase() == 'admin';
}
