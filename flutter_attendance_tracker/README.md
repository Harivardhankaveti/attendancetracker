# Flutter Attendance Tracker

A comprehensive attendance management system built with Flutter and Firebase for students, faculty, and administrators.

## 🚀 Features

- **Multi-role Authentication**: Student, Faculty, and Admin roles
- **Real-time Attendance Tracking**: Mark and view attendance records
- **Course Management**: Create and manage courses
- **Timetable System**: Schedule and view class timetables
- **User Management**: Admin dashboard for managing users
- **Reports & Analytics**: Attendance statistics and reports
- **Responsive Design**: Works on mobile and tablet devices

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Cloud Storage)
- **State Management**: Provider
- **Navigation**: Go Router
- **UI Components**: Material Design

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # Firebase and app configuration
│   ├── constants/       # App constants and routes
│   └── utils/           # Utility functions
├── models/              # Data models (User, Course, Attendance)
├── providers/           # State management providers
├── screens/             # UI screens organized by role
├── services/            # Business logic and Firebase services
└── widgets/             # Reusable UI components
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio or VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_attendance_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the setup script**
   ```bash
   # Windows
   setup_firebase.bat
   
   # macOS/Linux
   ./setup_firebase.sh
   ```

### Firebase Setup

Follow the detailed guide in [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) to:

1. Create a Firebase project
2. Enable Authentication and Firestore
3. Configure Android and iOS apps
4. Set up security rules
5. Test the application

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## 🎯 User Roles

### Student
- View attendance records
- View timetable
- View course details
- Receive notifications
- Manage profile settings

### Faculty
- Mark attendance
- View attendance records
- Manage courses
- View timetable
- Edit attendance records
- View notifications

### Admin
- Manage all users
- Monitor attendance system
- Generate reports
- Manage timetable
- System settings
- View login monitor

## 🔧 Development

### Code Generation
```bash
flutter pub run build_runner build
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

### Building
```bash
# Android APK
flutter build apk

# iOS IPA
flutter build ios

# Web
flutter build web
```

## 📱 Screenshots

*(Add screenshots of your app here)*

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All the open-source packages used in this project

## 📞 Support

For support, email [your-email@example.com] or open an issue in the repository.

---

**Happy Coding!** 🚀