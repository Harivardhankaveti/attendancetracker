import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  bool get isLoggedIn => user != null;

  // ==============================
  // 🔹 SIGN UP
  // ==============================
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? studentId,
    String? facultyId,
    String? department,
    String? year,
    String? designation,
  }) async {
    try {
      // STEP 1 — Create Firebase Auth user
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // STEP 2 — Build Firestore user data
      final Map<String, dynamic> userData = {
        "uid": uid,
        "name": name,
        "email": email,
        "role": role,
        "studentId": studentId,
        "facultyId": facultyId,
        "department": department,
        "year": year,
        "designation": designation,
        "phoneNumber": "",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // STEP 3 — Save user document (ONLY ONCE)
      await _firestore.collection("users").doc(uid).set(userData);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Email already registered";
      }
      if (e.code == 'weak-password') {
        return "Password should be at least 6 characters";
      }
      if (e.code == 'invalid-email') {
        return "Invalid email format";
      }
      return e.message ?? "Signup failed";
    } catch (e) {
      return "Registration failed: $e";
    }
  }

  // ==============================
  // 🔹 LOGIN
  // ==============================
  Future<String?> signIn(
    String email,
    String password,
    String selectedRole,
  ) async {
    try {
      print("LOGIN EMAIL: $email");

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      print("LOGIN UID: $uid");

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        print("FIRESTORE DOC NOT FOUND");
        return "User record not found";
      }

      final data = doc.data()!;
      final dbRole = data['role'];

      print("ROLE IN DB: $dbRole");
      print("ROLE SELECTED: $selectedRole");

      if (dbRole != selectedRole) {
        return "Login role mismatch. Select $dbRole";
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      print("LOGIN ERROR: ${e.code}");
      if (e.code == 'user-not-found') {
        return "No user found with this email";
      }
      if (e.code == 'wrong-password') {
        return "Incorrect password";
      }
      return e.message ?? "Login failed";
    } catch (e) {
      print("LOGIN CRASH: $e");
      return "Login error: $e";
    }
  }

  // ==============================
  // 🔹 GET USER ROLE
  // ==============================
  Future<String?> getUserRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return 'student';

      return doc.data()?['role'] ?? 'student';
    } catch (e) {
      print("ROLE FETCH ERROR: $e");
      return 'student';
    }
  }

  // ==============================
  // 🔹 DASHBOARD ROUTE
  // ==============================
  String getDashboardRoute(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return '/admin-dashboard';
      case 'faculty':
        return '/faculty-dashboard';
      default:
        return '/student-dashboard';
    }
  }

  // ==============================
  // 🔹 LOGOUT
  // ==============================
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
