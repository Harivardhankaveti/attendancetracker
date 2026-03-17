import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  // Firebase configuration - using the same credentials from React Native app
  static const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyA1qAk9VcQuMJtgB7wt5kjNo329oxpzYJU",
    authDomain: "my-app-2e5e9.firebaseapp.com",
    projectId: "my-app-2e5e9",
    storageBucket: "my-app-2e5e9.firebasestorage.app",
    messagingSenderId: "176485801513",
    appId: "1:176485801513:web:7b66ccdc78885267a1c638",
    
    // Platform-specific IDs (add these if needed)
    // iosBundleId: 'com.attendance.flutterAttendanceTracker',
    // androidPackageName: 'com.attendance.flutter_attendance_tracker',
  );
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  }
  
  // Get Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;
  
  // Get Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

// Singleton service class for Firebase operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  
  FirebaseAuth get auth => FirebaseConfig.auth;
  FirebaseFirestore get firestore => FirebaseConfig.firestore;
  
  // Collection references
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get coursesCollection => firestore.collection('courses');
  CollectionReference get attendanceCollection => firestore.collection('attendance');
  CollectionReference get timetableCollection => firestore.collection('timetable');
  
  // Initialize Firebase
  Future<void> initialize() async {
    await FirebaseConfig.initialize();
  }
  
  // Helper method to check if user is signed in
  bool get isSignedIn => auth.currentUser != null;
  
  // Get current user ID
  String? get currentUserId => auth.currentUser?.uid;
  
  // Get current user email
  String? get currentUserEmail => auth.currentUser?.email;
}
