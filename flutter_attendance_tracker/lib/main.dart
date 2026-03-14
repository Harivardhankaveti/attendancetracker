import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_config.dart';
import 'core/config/app_theme.dart';
import 'core/config/app_router.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Initialize services
  await StorageService().initialize();
  ApiService().initialize();

  // ✅ Create AuthProvider BEFORE runApp
  final authProvider = AuthProvider();

  // ✅ Initialize auth BEFORE UI builds
  authProvider.listenToAuthChanges();
  await authProvider.checkAuthState();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final appRouter = AppRouter(authProvider);

          return MaterialApp.router(
            title: 'Attendance Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
