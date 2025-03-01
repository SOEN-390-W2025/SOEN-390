import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/indoor_map/indoor_map_view.dart';

void main() {
  group('ClassroomSelection', () {
    testWidgets('should display the correct classrooms initially',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';
      const floor = 'Floor 1';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: ClassroomSelection(building: building, floor: floor),
      ));

      // Assert: Verify the list of classrooms is displayed
      expect(find.text('Classroom 101'), findsOneWidget);
      expect(find.text('Classroom 102'), findsOneWidget);
      expect(find.text('Classroom 103'), findsOneWidget);
    });

    testWidgets('should filter classrooms based on search input',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';
      const floor = 'Floor 1';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: ClassroomSelection(building: building, floor: floor),
      ));

      // Enter a search term
      await tester.enterText(find.byType(TextField), '101');
      await tester.pump(); // Rebuild the widget after the text input

      // Assert: Verify the filtered list shows only matching classrooms
      expect(find.text('Classroom 101'), findsOneWidget);
      expect(find.text('Classroom 102'), findsNothing);
      expect(find.text('Classroom 103'), findsNothing);
    });

    testWidgets('should display floor information correctly',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';
      const floor = 'Floor 1';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: ClassroomSelection(building: building, floor: floor),
      ));

      // Assert: Verify the floor information text is displayed
      expect(find.text(floor), findsOneWidget);
    });

    testWidgets(
        'should show no classrooms when search term does not match any classroom',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';
      const floor = 'Floor 1';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: ClassroomSelection(building: building, floor: floor),
      ));

      // Enter a non-matching search term
      await tester.enterText(find.byType(TextField), '104');
      await tester.pump(); // Rebuild the widget after the text input

      // Assert: Verify no classrooms are shown
      expect(find.text('Classroom 101'), findsNothing);
      expect(find.text('Classroom 102'), findsNothing);
      expect(find.text('Classroom 103'), findsNothing);
    });

    testWidgets('should trigger classroom selection on tapping a classroom',
        (WidgetTester tester) async {
      // Arrange
      const building = 'Test Building';
      const floor = 'Floor 1';
      const classroom = 'Classroom 101';

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: ClassroomSelection(building: building, floor: floor),
      ));

      // Simulate tapping on a classroom
      await tester.tap(find.text(classroom));
      await tester
          .pumpAndSettle(); // Wait for any potential UI updates (though there’s no actual navigation here)

      // Assert: Verify that the classroom was selected (you may want to handle selection logic)
      // For now, we expect no action since the classroom selection logic is not implemented.
      // You can later add a callback or test the side effects of classroom selection.
    });
  });

  group('IndoorMapView Widget Tests', () {
    testWidgets('IndoorMapView should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: IndoorMapView(key: UniqueKey()),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.text('Indoor Directions'), findsOneWidget);
    });

    testWidgets('IndoorMapView should render correctly',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorMapView(),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.text('Indoor Directions'), findsOneWidget);
    });

    testWidgets('CustomAppBar should have the correct title',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorMapView(),
        ),
      );

      // Verify that the custom app bar has the correct title
      expect(find.text('Indoor Directions'), findsOneWidget);
    });
  });
}
