import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_view.dart';

void main() {
  group('calendarPage appBar', () {
    testWidgets('appBar should exist with the right title', (WidgetTester tester) async {
      // Build the calendar view widget
      await tester.pumpWidget(const MaterialApp(home: const CalendarView()));
      await tester.pump();

      // Verify that the appBar exist and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Calendar'), findsWidgets);
    });
  });
}