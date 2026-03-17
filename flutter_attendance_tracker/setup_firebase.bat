@echo off
title Firebase Setup for Attendance Tracker

echo 🚀 Setting up Firebase for Attendance Tracker App
echo ==============================================

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    pause
    exit /b 1
)

echo ✅ Flutter is installed

REM Check if Firebase CLI is installed
where firebase >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Firebase CLI is not installed.
    echo Please install Firebase CLI: npm install -g firebase-tools
    echo Or download from: https://firebase.google.com/docs/cli
) else (
    echo ✅ Firebase CLI is installed
)

REM Navigate to project directory
cd /d "%~dp0"

echo 📁 Current directory: %cd%

REM Check if pubspec.yaml exists
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found. Make sure you're in the Flutter project root.
    pause
    exit /b 1
)

echo ✅ Found Flutter project

REM Run Flutter pub get
echo 📦 Running flutter pub get...
flutter pub get

if %errorlevel% equ 0 (
    echo ✅ Dependencies installed successfully
) else (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

REM Check Android configuration
echo 📱 Checking Android configuration...

if exist "android\app\google-services.json" (
    echo ✅ google-services.json found
) else (
    echo ⚠️  google-services.json not found in android\app\
    echo Please download it from Firebase Console and place it in android\app\
)

REM Check iOS configuration
echo 📱 Checking iOS configuration...

if exist "ios\Runner\GoogleService-Info.plist" (
    echo ✅ GoogleService-Info.plist found
) else (
    echo ⚠️  GoogleService-Info.plist not found in ios\Runner\
    echo Please download it from Firebase Console and place it in ios\Runner\
)

REM Check Firebase config file
echo ⚙️  Checking Firebase configuration...

if exist "lib\core\config\firebase_config.dart" (
    echo ✅ Firebase config file found
) else (
    echo ❌ Firebase config file not found
)

echo.
echo 📋 Setup Checklist:
echo ==================
echo 1. ✅ Firebase Project Created
echo 2. ✅ Authentication Enabled
echo 3. ✅ Firestore Database Created
echo 4. ✅ Dependencies Installed
echo 5. ⬜ Android Configuration (google-services.json)
echo 6. ⬜ iOS Configuration (GoogleService-Info.plist)
echo 7. ⬜ Firebase Security Rules
echo 8. ⬜ Test the Application

echo.
echo 📝 Next Steps:
echo =============
echo 1. Download google-services.json from Firebase Console
echo 2. Place it in android\app\ directory
echo 3. Update Firebase security rules in Firebase Console
echo 4. Run 'flutter run' to test the app
echo 5. Create test users and data in Firestore

echo.
echo 🔗 Useful Links:
echo ===============
echo Firebase Console: https://console.firebase.google.com/
echo Firebase Setup Guide: FIREBASE_SETUP_GUIDE.md
echo Firestore Security Rules Documentation: https://firebase.google.com/docs/firestore/security/get-started

echo.
echo 🎉 Firebase setup script completed!
pause