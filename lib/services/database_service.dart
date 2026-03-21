import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_model;
import '../models/course.dart';
import '../models/attendance.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get coursesCollection => _firestore.collection('courses');
  CollectionReference get attendanceCollection =>
      _firestore.collection('attendance');
  CollectionReference get timetableCollection =>
      _firestore.collection('timetable');

  // MARK: User Operations

  /// Get current user data from Firestore
  Future<app_model.User?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await usersCollection.doc(user.uid).get();
      if (doc.exists) {
        return app_model.User.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Get user by ID
  Future<app_model.User?> getUserById(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return app_model.User.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  /// Create new user document
  Future<bool> createUserDocument({
  required String uid,
  required String email,
  required String name,
  required String role,
  String? studentId,
  String? facultyId,
  String? department,
  String? year,
  String? branch,
  String? section,
  String? designation,
}) async {
  try {
    await usersCollection.doc(uid).set({
      "uid": uid, // ✅ IMPORTANT
      "email": email,
      "name": name,
      "role": role.toLowerCase(),

      "studentId": studentId,
      "facultyId": facultyId,
      "department": department,
      "year": year,
      "branch": branch,
      "section": section,
      "designation": designation,

      "createdAt": FieldValue.serverTimestamp(), // ✅ FIX
      "lastLogin": FieldValue.serverTimestamp(), // ✅ FIX
    });

    return true;
  } catch (e) {
    print('Error creating user document: $e');
    return false;
  }
}

  /// Update user last login
  Future<void> updateUserLastLogin(String userId) async {
    try {
      await usersCollection.doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  /// Get all users by role
  Future<List<app_model.User>> getUsersByRole(String role) async {
    try {
      final snapshot = await usersCollection
          .where('role', isEqualTo: role)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => app_model.User.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // MARK: Course Operations

  /// Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      final snapshot = await coursesCollection.orderBy('code').get();
      return snapshot.docs
          .map((doc) =>
              Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting all courses: $e');
      return [];
    }
  }

  /// Get courses by faculty ID
  Future<List<Course>> getCoursesByFaculty(String facultyId) async {
    try {
      final snapshot = await coursesCollection
          .where('facultyId', isEqualTo: facultyId)
          .orderBy('code')
          .get();

      return snapshot.docs
          .map((doc) =>
              Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting courses by faculty: $e');
      return [];
    }
  }

  /// Get courses by student ID
  Future<List<Course>> getCoursesByStudent(String studentId) async {
    try {
      final snapshot = await coursesCollection
          .where('students', arrayContains: studentId)
          .orderBy('code')
          .get();

      return snapshot.docs
          .map((doc) =>
              Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting courses by student: $e');
      return [];
    }
  }

  /// Create new course
  Future<String?> createCourse(Course course) async {
    try {
      final docRef = await coursesCollection.add(course.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating course: $e');
      return null;
    }
  }

  /// Update course
  Future<bool> updateCourse(String courseId, Course course) async {
    try {
      await coursesCollection.doc(courseId).update(course.toMap());
      return true;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  /// Delete course
  Future<bool> deleteCourse(String courseId) async {
    try {
      await coursesCollection.doc(courseId).delete();
      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  /// Add student to course
  Future<bool> addStudentToCourse(String courseId, String studentId) async {
    try {
      await coursesCollection.doc(courseId).update({
        'students': FieldValue.arrayUnion([studentId])
      });
      return true;
    } catch (e) {
      print('Error adding student to course: $e');
      return false;
    }
  }

  /// Remove student from course
  Future<bool> removeStudentFromCourse(
      String courseId, String studentId) async {
    try {
      await coursesCollection.doc(courseId).update({
        'students': FieldValue.arrayRemove([studentId])
      });
      return true;
    } catch (e) {
      print('Error removing student from course: $e');
      return false;
    }
  }

  // MARK: Attendance Operations

  /// Get attendance records for a course and date
  Future<Attendance?> getAttendanceByCourseAndDate(
      String courseId, DateTime date) async {
    try {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final snapshot = await attendanceCollection
          .where('courseId', isEqualTo: courseId)
          .where('date',
              isEqualTo: Timestamp.fromDate(DateTime.parse(dateString)))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Attendance.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting attendance by course and date: $e');
      return null;
    }
  }

  /// Get all attendance records for a course
  Future<List<Attendance>> getAttendanceByCourse(String courseId) async {
    try {
      final snapshot = await attendanceCollection
          .where('courseId', isEqualTo: courseId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              Attendance.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting attendance by course: $e');
      return [];
    }
  }

  /// Get student attendance records for a course
  Future<List<Attendance>> getStudentAttendance(
      String studentId, String courseId) async {
    try {
      final snapshot = await attendanceCollection
          .where('courseId', isEqualTo: courseId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              Attendance.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((attendance) => attendance.getStudentRecord(studentId) != null)
          .toList();
    } catch (e) {
      print('Error getting student attendance: $e');
      return [];
    }
  }

  /// Create or update attendance record
  Future<String?> markAttendance(Attendance attendance) async {
    try {
      // Check if attendance already exists for this course and date
      final existingAttendance = await getAttendanceByCourseAndDate(
          attendance.courseId, attendance.date);

      if (existingAttendance != null) {
        // Update existing attendance
        await attendanceCollection
            .doc(existingAttendance.id)
            .update(attendance.toMap());
        return existingAttendance.id;
      } else {
        // Create new attendance record
        final docRef = await attendanceCollection.add(attendance.toMap());
        return docRef.id;
      }
    } catch (e) {
      print('Error marking attendance: $e');
      return null;
    }
  }

  /// Get attendance statistics for a student in a course
  Future<AttendanceStats> getStudentAttendanceStats(
      String studentId, String courseId) async {
    try {
      final attendanceRecords = await getAttendanceByCourse(courseId);

      int totalClasses = attendanceRecords.length;
      int classesAttended = 0;

      for (var record in attendanceRecords) {
        if (record.isStudentPresent(studentId)) {
          classesAttended++;
        }
      }

      double percentage =
          totalClasses > 0 ? (classesAttended / totalClasses) * 100 : 0;

      return AttendanceStats(
        courseId: courseId,
        studentId: studentId,
        totalClasses: totalClasses,
        classesAttended: classesAttended,
        attendancePercentage: percentage,
      );
    } catch (e) {
      print('Error getting attendance stats: $e');
      return AttendanceStats(
        courseId: courseId,
        studentId: studentId,
        totalClasses: 0,
        classesAttended: 0,
        attendancePercentage: 0,
      );
    }
  }

  // MARK: Real-time Listeners

  /// Listen to user changes
  Stream<app_model.User?> userStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return app_model.User.fromMap(
            snapshot.data() as Map<String, dynamic>, snapshot.id);
      }
      return null;
    });
  }

  /// Listen to course changes
  Stream<List<Course>> coursesStream() {
    return coursesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Listen to attendance changes for a course
  Stream<List<Attendance>> attendanceStream(String courseId) {
    return attendanceCollection
        .where('courseId', isEqualTo: courseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Attendance.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
