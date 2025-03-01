import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:concordia_nav/ui/indoor_map/floor_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloorSelection', () {
    testWidgets('should display the correct floors initially',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: FloorSelection(building: building),
      ));

      // Assert: Verify the initial list of floors is displayed
      expect(find.text('Floor 1'), findsOneWidget);
      expect(find.text('Floor 2'), findsOneWidget);
      expect(find.text('Floor 3'), findsOneWidget);
    });

    testWidgets('should filter floors based on search input',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Hall Building';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: FloorSelection(building: building),
      ));

      // Enter a search term
      await tester.enterText(find.byType(TextField).first, 'Floor 1');
      await tester.pump(); // Rebuild the widget after the text input

      // Assert: Verify the filtered list shows only matching floors
      expect(find.text('Floor 1'), findsAtLeast(2));
      expect(find.text('Floor 2'), findsNothing);
      expect(find.text('Floor 3'), findsNothing);
    });

    testWidgets('should navigate to ClassroomSelection on floor selection',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';
      const floor = 'Floor 1';

      // Build the widget and wrap it with a MaterialApp
      await tester.pumpWidget(const MaterialApp(
        home: FloorSelection(building: building),
      ));

      // Simulate selecting a floor
      await tester.tap(find.text(floor));
      await tester.pumpAndSettle(); // Wait for the navigation

      // Assert: Verify that the ClassroomSelection screen is pushed
      expect(find.byType(ClassroomSelection), findsOneWidget);
      expect(find.text(floor), findsOneWidget);
      expect(find.text(building), findsOneWidget);
    });

    testWidgets(
        'should show no floors when search term does not match any floor',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: FloorSelection(building: building),
      ));

      // Enter a non-matching search term
      await tester.enterText(find.byType(TextField), 'Floor 4');
      await tester.pump(); // Rebuild the widget after the text input

      // Assert: Verify no floors are shown
      expect(find.text('Floor 1'), findsNothing);
      expect(find.text('Floor 2'), findsNothing);
      expect(find.text('Floor 3'), findsNothing);
    });
  });
}
