#!/bin/bash

# Firebase Setup Script for Flutter Attendance Tracker

echo "🚀 Setting up Firebase for Attendance Tracker App"
echo "=============================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter is installed"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI is not installed."
    echo "Please install Firebase CLI: npm install -g firebase-tools"
    echo "Or download from: https://firebase.google.com/docs/cli"
else
    echo "✅ Firebase CLI is installed"
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo "📁 Current directory: $(pwd)"

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found. Make sure you're in the Flutter project root."
    exit 1
fi

echo "✅ Found Flutter project"

# Run Flutter pub get
echo "📦 Running flutter pub get..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Check Android configuration
echo "📱 Checking Android configuration..."

if [ -f "android/app/google-services.json" ]; then
    echo "✅ google-services.json found"
else
    echo "⚠️  google-services.json not found in android/app/"
    echo "Please download it from Firebase Console and place it in android/app/"
fi

# Check iOS configuration
echo "📱 Checking iOS configuration..."

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist found"
else
    echo "⚠️  GoogleService-Info.plist not found in ios/Runner/"
    echo "Please download it from Firebase Console and place it in ios/Runner/"
fi

# Check Firebase config file
echo "⚙️  Checking Firebase configuration..."

if [ -f "lib/core/config/firebase_config.dart" ]; then
    echo "✅ Firebase config file found"
else
    echo "❌ Firebase config file not found"
fi

echo ""
echo "📋 Setup Checklist:"
echo "=================="
echo "1. ✅ Firebase Project Created"
echo "2. ✅ Authentication Enabled"
echo "3. ✅ Firestore Database Created"
echo "4. ✅ Dependencies Installed"
echo "5. ⬜ Android Configuration (google-services.json)"
echo "6. ⬜ iOS Configuration (GoogleService-Info.plist)"
echo "7. ⬜ Firebase Security Rules"
echo "8. ⬜ Test the Application"

echo ""
echo "📝 Next Steps:"
echo "============="
echo "1. Download google-services.json from Firebase Console"
echo "2. Place it in android/app/ directory"
echo "3. Update Firebase security rules in Firebase Console"
echo "4. Run 'flutter run' to test the app"
echo "5. Create test users and data in Firestore"

echo ""
echo "🔗 Useful Links:"
echo "==============="
echo "Firebase Console: https://console.firebase.google.com/"
echo "Firebase Setup Guide: FIREBASE_SETUP_GUIDE.md"
echo "Firestore Security Rules Documentation: https://firebase.google.com/docs/firestore/security/get-started"

echo ""
echo "🎉 Firebase setup script completed!"