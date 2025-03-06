import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/indoor_map/building_selection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  group('ClassroomSelection', () {
    testWidgets('should display the correct classrooms initially',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';
        const floor = 'Floor 1';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: ClassroomSelection(building: building, floor: floor),
        ));

        // Wait for classrooms to be rendered
        await tester.pumpAndSettle();

        // Find all rendered text widgets
        final allTextWidgets = find.byType(Text);

        // Find all classrooms dynamically
        final classrooms = allTextWidgets
            .evaluate()
            .map((element) {
              final textWidget = element.widget as Text;
              return textWidget.data;
            })
            .where((text) => text != null)
            .toList();

        // Ensure at least some classrooms are displayed
        expect(classrooms, isNotEmpty, reason: 'No classrooms found in UI');
      });
    });

    testWidgets('should filter classrooms based on search input',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';
        const floor = 'Floor 9';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: ClassroomSelection(building: building, floor: floor),
        ));

        // Wait for classrooms to be rendered
        await tester.pumpAndSettle();

        // Enter a search term
        await tester.enterText(find.byType(TextField), '9000');
        await tester.pump(); // Rebuild the widget after the text input

        // Find all rendered text widgets
        final allTextWidgets = find.byType(Text);

        // Find classrooms based on the search term dynamically
        final classrooms = allTextWidgets
            .evaluate()
            .map((element) {
              final textWidget = element.widget as Text;
              return textWidget.data;
            })
            .where((text) => text != null)
            .toList();

        // Assert: Verify the filtered list shows only matching classrooms
        expect(classrooms, contains('90001'),
            reason: 'Room 101 should be found');
        expect(classrooms, contains('90002'),
            reason: 'Room 102 should be found');
        expect(classrooms, isNot(contains('93')),
            reason: 'Room 3 should not be found');
        expect(classrooms, isNot(contains('920')),
            reason: 'Room 20 should not be found');
      });
    });

    testWidgets('should display floor information correctly',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
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
    });

    testWidgets(
        'should show no classrooms when search term does not match any classroom',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
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
    });

    testWidgets('should trigger classroom selection on tapping a classroom',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';
        const floor = 'Floor 1';
        const classroom = '110';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: ClassroomSelection(building: building, floor: floor),
        ));
        await tester.pumpAndSettle();

        // Make sure the element is visible before tapping
        await tester.ensureVisible(find.text(classroom));
        await tester.pumpAndSettle();

        // Simulate tapping on a classroom
        expect(find.text('110'), findsOneWidget);
        await tester.tap(find.text(classroom));
        await tester
            .pumpAndSettle(); // Wait for any potential UI updates (though there’s no actual navigation here)

        // Assert: Verify that the classroom was selected (you may want to handle selection logic)
        // For now, we expect no action since the classroom selection logic is not implemented.
        // You can later add a callback or test the side effects of classroom selection.
      });
    });
  });

  group('IndoorMapView Widget Tests', () {
    testWidgets('IndoorMapView should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: BuildingSelection(key: UniqueKey()),
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
          home: BuildingSelection(),
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
          home: BuildingSelection(),
        ),
      );

      // Verify that the custom app bar has the correct title
      expect(find.text('Indoor Directions'), findsOneWidget);
    });
  });
}
