import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_model;
import '../core/config/firebase_config.dart';

class AdminAccountSetup {
  static final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  static final FirebaseAuth _auth = FirebaseConfig.auth;

  /// Creates a sample admin account for testing purposes
  static Future<void> createSampleAdminAccount() async {
    try {
      // Create a test admin user
      final email = 'admin@test.com';
      final password = 'admin123';
      final name = 'Admin User';

      print('Creating admin account...');

      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = app_model.User(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          role: 'admin',
          studentId: null,
          facultyId: null,
          department: 'Administration',
          year: null,
          designation: 'System Administrator',
          createdAt: DateTime.now(),
        );

        // Create the user document in Firestore
        await _firestore.collection('users').doc(user.uid).set(user.toMap());
        print('Admin account created successfully!');
        print('Email: $email');
        print('Password: $password');
        print('Role: admin');

        print('Admin account created successfully!');
        print('Email: $email');
        print('Password: $password');
        print('Role: admin');
      }
    } catch (e) {
      print('Error creating admin account: $e');
    }
  }
}
