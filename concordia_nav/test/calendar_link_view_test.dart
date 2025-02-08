import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_view.dart';

void main() {
  group('CalendarView Widget Tests', () {
    testWidgets('renders CalendarView with custom AppBar and correct body text',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarView(),
        ),
      );

      // Assert
      expect(find.text('Calendar').first, findsOneWidget);
    });

    testWidgets('renders correctly with a non-constant key',
        (WidgetTester tester) async {
      // Arrange & Act
      final key = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(key: key),
        ),
      );

      // Assert
      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('renders correctly with a constant key',
        (WidgetTester tester) async {
      // Arrange & Act
      const key = ValueKey<String>('constant_key');
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarView(key: key),
        ),
      );

      // Assert
      expect(find.byKey(key), findsOneWidget);
    });
  });
}
