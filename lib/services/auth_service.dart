import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';
import '../models/user.dart' as app_model;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Authentication failed');
      }

      // Get user data from Firestore
      final appUser = await _databaseService.getCurrentUser();

      if (appUser == null) {
        // User document doesn't exist, sign out
        await signOut();
        return AuthResult.failure(
            'User account not found. Please contact administrator.');
      }

      // Check if role matches
      if (appUser.role.toLowerCase() != expectedRole.toLowerCase()) {
        await signOut();
        return AuthResult.failure(
            'Invalid role. You are registered as ${appUser.role}, not $expectedRole.');
      }

      // Update last login
      await _databaseService.updateUserLastLogin(appUser.uid);

      return AuthResult.success(appUser);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed';

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }

      return AuthResult.failure(errorMessage);
    } catch (e) {
      return AuthResult.failure('Authentication failed: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthResult> registerWithEmailAndPassword({
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
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Registration failed');
      }

      // Create user document in Firestore
      final success = await _databaseService.createUserDocument(
        uid: userCredential.user!.uid,
        email: email,
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

      if (!success) {
        // If Firestore creation fails, delete the Firebase Auth user
        await userCredential.user!.delete();
        return AuthResult.failure('Failed to create user account');
      }

      // Get the created user
      final appUser = await _databaseService.getCurrentUser();

      if (appUser == null) {
        return AuthResult.failure('Failed to retrieve user data');
      }

      return AuthResult.success(appUser);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password should be at least 6 characters.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }

      return AuthResult.failure(errorMessage);
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      return false;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get user role
  Future<String?> getUserRole() async {
    try {
      final user = await _databaseService.getCurrentUser();
      return user?.role;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  /// Get dashboard route based on role
  String getDashboardRoute(String? role) {
    switch (role?.toLowerCase()) {
      case 'student':
        return '/student/dashboard';
      case 'faculty':
        return '/faculty/dashboard';
      case 'admin':
        return '/admin/dashboard';
      default:
        return '/login';
    }
  }

  /// Delete current user account
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Delete user document from Firestore first
      await _databaseService.usersCollection.doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? department,
    String? year,
    String? designation,
  }) async {
    try {
      final user = await _databaseService.getCurrentUser();
      if (user == null) return false;

      final updatedUser = user.copyWith(
        name: name,
        department: department,
        year: year,
        designation: designation,
      );

      await _databaseService.usersCollection
          .doc(user.uid)
          .update(updatedUser.toMap());
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool success;
  final String message;
  final app_model.User? user;

  AuthResult._(this.success, this.message, this.user);

  factory AuthResult.success(app_model.User user) {
    return AuthResult._(true, 'Success', user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(false, message, null);
  }
}
