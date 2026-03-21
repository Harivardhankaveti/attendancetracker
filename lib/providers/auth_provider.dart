import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user.dart' as app_model;
import '../core/utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = false;
  String? _error;
  String? _role;
  app_model.User? _currentUser;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  app_model.User? get user => _currentUser;
  bool get isInitialized => _isInitialized;
  String? get role => _role;

  StreamSubscription<User?>? _authStateSubscription;

  /// INIT AUTH STATE
  Future<void> checkAuthState() async {
    await _loadCurrentUser();
    _isInitialized = true;
    notifyListeners();
  }

  /// LISTEN FOR LOGIN / LOGOUT
  void listenToAuthChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadCurrentUser();
      } else {
        _currentUser = null;
        _role = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// LOAD USER FROM FIRESTORE
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _databaseService.getCurrentUser();
      _role = _currentUser?.role;
    } catch (e) {
      Logger.error("Error loading user: $e");
    }
  }

  /// ROLE BASED ROUTE
  String getDashboardRoute(String? role) {
    return _authService.getDashboardRoute(role);
  }

  /// LOGIN FUNCTION
  Future<String?> signIn(String email, String password, String role) async {
    _setLoading(true);
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
        expectedRole: role,
      );

      if (result.success) {
        // Always reload from Firestore to be sure data is correct
        await _loadCurrentUser();

        if (_currentUser == null) {
          return "User data not found in database";
        }

        if (_currentUser!.role != role) {
          await _authService.signOut();
          return "You are registered as ${_currentUser!.role}, not $role";
        }

        return null;
      } else {
        return result.message;
      }
    } finally {
      _setLoading(false);
    }
  }

  /// SIGNUP FUNCTION
  Future<String?> signUp({
    required String email,
    required String password,
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
    _setLoading(true);
    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
        name: name,
        role: role,
        studentId: studentId,
        facultyId: facultyId,
        department: department,
        year: year,
        branch: branch,
        section: section,
        designation: designation,
      );

      if (result.success) {
        await _loadCurrentUser();

        if (_currentUser == null) {
          return "Account created but profile missing";
        }

        return null;
      } else {
        return result.message;
      }
    } finally {
      _setLoading(false);
    }
  }

  /// RESET PASSWORD
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      return await _authService.sendPasswordResetEmail(email);
    } finally {
      _setLoading(false);
    }
  }

  /// VERIFY OTP (FOR PASSWORD RESET)
  Future<bool> verifyOtp(String otp) async {
    // In a real implementation, you would verify the OTP with your backend
    // For now, we'll just simulate a successful verification
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// LOGOUT
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _role = null;
    notifyListeners();
  }

  /// FETCH ROLE (FOR ROUTER)
  Future<String?> getUserRole() async {
    if (_currentUser != null) return _currentUser!.role;

    await _loadCurrentUser();
    return _currentUser?.role;
  }

  /// UPDATE USER PROFILE
  Future<bool> updateProfile({
    String? name,
    String? department,
    String? year,
    String? designation,
  }) async {
    _setLoading(true);
    try {
      return await _authService.updateProfile(
        name: name,
        department: department,
        year: year,
        designation: designation,
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
