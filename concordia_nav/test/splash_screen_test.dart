import 'package:concordia_nav/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';

void main() {
  testWidgets('SplashScreen navigates to HomePage after 3 seconds',
      (WidgetTester tester) async {
    // Pump SplashScreen
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );

    // Wait for the delay duration (3 seconds in this case)
    await tester.pump(const Duration(seconds: 3));

    // Allow time for animations and navigation
    await tester.pumpAndSettle();

    // Verify navigation to HomePage
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('SplashScreen navigates to HomePage after 3 seconds',
      (WidgetTester tester) async {
    // Pump SplashScreen
    await tester.pumpWidget(
      MaterialApp(key: UniqueKey(), home: const SplashScreen()),
    );

    // Wait for the delay duration (3 seconds in this case)
    await tester.pump(const Duration(seconds: 3));

    // Allow time for animations and navigation
    await tester.pumpAndSettle();

    // Verify navigation to HomePage
    expect(find.byType(HomePage), findsOneWidget);
  });
}
