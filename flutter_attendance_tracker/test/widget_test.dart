import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_attendance_tracker/main.dart';
import 'package:flutter_attendance_tracker/providers/auth_provider.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
          ),
        ],
        child: MyApp(authProvider: authProvider),
      ),
    );

    // Check if MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
