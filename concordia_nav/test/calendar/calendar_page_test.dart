// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_view.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  group('calendarPage appBar', () {
    testWidgets('appBar should exist with the right title',
        (WidgetTester tester) async {
      // Build the calendar view widget
      await tester.pumpWidget(const MaterialApp(home: const CalendarView()));
      await tester.pump();

      // Verify that the appBar exist and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Calendar'), findsWidgets);
    });
  });
}
