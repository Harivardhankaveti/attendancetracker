# Firebase and Backend Setup Guide

## Overview
This guide will help you set up Firebase for your Flutter Attendance Tracker application, including authentication, Firestore database, and all required configurations.

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Firebase account
- Google account

## Step 1: Firebase Project Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "Attendance Tracker"
4. Enable Google Analytics (optional but recommended)
5. Choose your Analytics account or create a new one
6. Click "Create project"

### 1.2 Enable Firebase Services

#### Authentication Setup
1. In Firebase Console, click "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable these providers:
   - **Email/Password** - For user registration and login
   - **Google** - For Google sign-in (optional)

#### Firestore Database Setup
1. Click "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (you can change rules later)
4. Select a location closest to your users
5. Click "Enable"

#### Storage Setup (Optional)
1. Click "Storage" in the left sidebar
2. Click "Get started"
3. Follow the setup wizard

## Step 2: Android Configuration

### 2.1 Add Android App to Firebase
1. In Firebase Console, click the gear icon → "Project settings"
2. Under "Your apps", click the Android icon
3. Enter package name: `com.attendance.flutter_attendance_tracker`
4. Enter App nickname: "Attendance Tracker"
5. Debug signing certificate SHA-1 (optional for development)
6. Click "Register app"

### 2.2 Download and Add Config File
1. Download the `google-services.json` file
2. Place it in `android/app/` directory (replace existing one if needed)
3. The file should already be there from your current setup

### 2.3 Update Android Build Configuration

#### Update `android/build.gradle`:
```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.3.15'  // Add this line
    }
}
```

#### Update `android/app/build.gradle`:
```gradle
android {
    namespace "com.attendance.flutter_attendance_tracker"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.attendance.flutter_attendance_tracker"
        minSdkVersion 21  // Changed from flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation platform('com.google.firebase:firebase-bom:32.7.0')  // Add this line
    implementation 'com.google.firebase:firebase-analytics'  // Add this line
}

// Add this at the bottom
apply plugin: 'com.google.gms.google-services'
```

## Step 3: iOS Configuration (Optional)

### 3.1 Add iOS App to Firebase
1. In Firebase Console, click the iOS icon under "Your apps"
2. Enter bundle ID: `com.attendance.flutterAttendanceTracker`
3. Download `GoogleService-Info.plist`
4. Add it to your iOS project in Xcode

### 3.2 Update iOS Configuration
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.attendance.flutterAttendanceTracker</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>app-1-176485801513-ios-XXXXXXXXXXXXXXXX</string> <!-- Replace with your REVERSED_CLIENT_ID -->
        </array>
    </dict>
</array>
```

## Step 4: Firestore Database Structure

### 4.1 Create Database Collections

Run these commands in Firebase Console or use the Firebase CLI:

#### Users Collection Structure
```javascript
// Collection: users
{
  "userId": {
    "uid": "user_uid",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "student", // or "faculty", "admin"
    "studentId": "STU001", // for students
    "facultyId": "FAC001", // for faculty
    "department": "Computer Science",
    "year": "3rd Year", // for students
    "designation": "Professor", // for faculty
    "createdAt": "timestamp",
    "lastLogin": "timestamp"
  }
}
```

#### Courses Collection Structure
```javascript
// Collection: courses
{
  "courseId": {
    "id": "courseId",
    "code": "CS101",
    "name": "Introduction to Computer Science",
    "description": "Learn fundamental programming concepts",
    "department": "Computer Science",
    "credits": 3,
    "facultyId": "FAC001",
    "facultyName": "Dr. John Smith",
    "students": ["STU001", "STU002", "STU003"], // array of student IDs
    "schedule": {
      "days": ["Monday", "Wednesday"],
      "time": "10:00-11:30",
      "room": "Room 205"
    },
    "semester": "Fall 2023",
    "createdAt": "timestamp"
  }
}
```

#### Attendance Collection Structure
```javascript
// Collection: attendance
{
  "attendanceId": {
    "id": "attendanceId",
    "courseId": "CS101",
    "date": "2023-09-25",
    "facultyId": "FAC001",
    "totalStudents": 45,
    "presentStudents": 38,
    "students": [
      {
        "studentId": "STU001",
        "isPresent": true,
        "timestamp": "timestamp"
      },
      {
        "studentId": "STU002", 
        "isPresent": false,
        "timestamp": "timestamp"
      }
    ],
    "createdAt": "timestamp"
  }
}
```

#### Timetable Collection Structure
```javascript
// Collection: timetable
{
  "timetableId": {
    "id": "timetableId",
    "facultyId": "FAC001",
    "courseId": "CS101",
    "day": "Monday",
    "startTime": "10:00",
    "endTime": "11:30",
    "room": "Room 205",
    "semester": "Fall 2023",
    "createdAt": "timestamp"
  }
}
```

## Step 5: Firebase Security Rules

### 5.1 Firestore Security Rules

In Firebase Console → Firestore Database → Rules, add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Students can only read courses they're enrolled in
    match /courses/{courseId} {
      allow read: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'faculty' ||
         request.auth.uid in get(/databases/$(database)/documents/courses/$(courseId)).data.students);
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'faculty');
    }
    
    // Attendance records - faculty and admin can write, students can read their own
    match /attendance/{attendanceId} {
      allow read: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'faculty' ||
         request.auth.uid in get(/databases/$(database)/documents/attendance/$(attendanceId)).data.students.map(s => s.studentId));
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'faculty');
    }
    
    // Timetable - all authenticated users can read, only faculty/admin can write
    match /timetable/{timetableId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'faculty');
    }
  }
}
```

## Step 6: Update Flutter Configuration

### 6.1 Verify Firebase Options
Your `firebase_config.dart` file already has the configuration. Make sure the credentials match your Firebase project.

### 6.2 Add Required Dependencies
Your `pubspec.yaml` already includes the required Firebase dependencies:
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
```

### 6.3 Run Flutter Pub Get
```bash
cd flutter_attendance_tracker
flutter pub get
```

## Step 7: Test the Setup

### 7.1 Run the Application
```bash
flutter run
```

### 7.2 Test Authentication Flow
1. Try to register a new user
2. Check if the user is created in Firebase Authentication
3. Verify the user document is created in Firestore

### 7.3 Test Database Operations
1. Create a course as faculty/admin
2. Enroll students in courses
3. Mark attendance and verify data in Firestore

## Step 8: Environment Configuration

### 8.1 Create Environment Files
Create a `.env` file in your project root (add to `.gitignore`):
```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

### 8.2 Update Firebase Config to Use Environment Variables
```dart
// In firebase_config.dart, you can modify to use environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      ),
    );
  }
}
```

## Troubleshooting

### Common Issues:

1. **Firebase not initializing**: Check if `google-services.json` is in the correct location
2. **Authentication errors**: Verify Firebase Auth is enabled and rules are correct
3. **Firestore permission denied**: Check security rules and user authentication status
4. **Android build errors**: Make sure minSdkVersion is 21 or higher
5. **iOS build errors**: Ensure proper signing and provisioning profiles

### Debug Commands:
```bash
# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter build

# Check Firebase configuration
flutter pub run flutter_launcher_icons:main
```

## Next Steps

1. Implement the complete authentication flow in your app
2. Create CRUD operations for all data models
3. Add real-time listeners for attendance updates
4. Implement proper error handling
5. Add offline support with local caching
6. Set up Firebase Cloud Functions for complex operations
7. Configure Firebase Analytics for tracking usage

This setup provides a solid foundation for your attendance tracking application with Firebase as the backend.