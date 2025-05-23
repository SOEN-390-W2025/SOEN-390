import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:concordia_nav/ui/indoor_map/floor_selection.dart';
import 'package:concordia_nav/utils/building_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('FloorSelection', () {
    testWidgets('should display the correct floors initially',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Test Building';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: FloorSelection(building: building),
        ));

        // Wait for the widget to fully load if necessary
        await tester.pumpAndSettle();

        // Find all the text widgets found
        final allTextWidgets = find.byType(Text);

        // Assert: Check if at least some floors are displayed dynamically
        expect(allTextWidgets, findsWidgets); // Ensures some text widgets exist
      });
    });

    testWidgets('should filter floors based on search input',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: FloorSelection(building: building),
        ));
        await tester.pump();

        // Enter a search term
        await tester.enterText(find.byType(TextField).first, 'Floor 1');
        await tester.pump(); // Rebuild the widget after the text input

        // Assert: Verify the filtered list shows only matching floors
        expect(find.text('Floor 1'), findsAtLeast(2));
        expect(find.text('Floor 2'), findsNothing);
        expect(find.text('Floor 3'), findsNothing);
      });
    });

    testWidgets('should navigate to ClassroomSelection on floor selection',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';

        // Build the widget and wrap it with a MaterialApp
        await tester.pumpWidget(const MaterialApp(
          home: FloorSelection(building: building),
        ));

        // Wait for floors to be rendered if they load dynamically
        await tester.pump();

        // Find the first available floor dynamically
        final floorFinder = find.byType(Text).evaluate().map((element) {
          final textWidget = element.widget as Text;
          return textWidget.data;
        }).where((text) => text != null && text.startsWith('Floor')).toList();

        // Ensure at least one floor is found
        expect(floorFinder, isNotEmpty, reason: 'No floors found in UI');

        // Get the first available floor
        final firstFloor = floorFinder.first!;

        // Simulate selecting the first floor
        await tester.tap(find.text(firstFloor));
        await tester.pumpAndSettle(); // Wait for the navigation

        // Assert: Verify that the ClassroomSelection screen is pushed
        expect(find.byType(ClassroomSelection), findsOneWidget);
        expect(find.text(firstFloor), findsOneWidget);
        expect(find.text(building), findsOneWidget);
      });
    });

    testWidgets('should show no floors when search term does not match any floor',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: FloorSelection(building: building),
        ));

        // Wait for floors to be rendered
        await tester.pump();

        // Ensure floors are displayed before searching
        final initialFloors = find.byType(Text).evaluate().where((element) {
          final textWidget = element.widget as Text;
          return textWidget.data != null && textWidget.data!.startsWith('Floor');
        }).toList();

        expect(initialFloors, isNotEmpty, reason: 'Floors found before searching');

        // Enter a non-matching search term
        await tester.enterText(find.byType(TextField), 'XYZ'); // A term that won't match any floor
        await tester.pump(); // Rebuild the widget after the text input

        // Assert: Verify no floors are shown
        final filteredFloors = find.byType(Text).evaluate().where((element) {
          final textWidget = element.widget as Text;
          return textWidget.data != null && textWidget.data!.startsWith('Floor');
        }).toList();

        expect(filteredFloors, isEmpty, reason: 'Floors are still visible after entering an invalid search term');
      });
    });
  });

  test('getBuildingAbbreviation returns the abbreviation from building name', () {
    // Arrange
    final buildingViewModel = BuildingViewModel();
    const buildingName = 'Hall Building';
    const buildingName2 = 'EV Building';

    // should return H
    var abbreviation = buildingViewModel.getBuildingAbbreviation(buildingName);
    expect(abbreviation, 'H');

    // should return EV
    abbreviation = buildingViewModel.getBuildingAbbreviation(buildingName2);
    expect(abbreviation, 'EV');
  });

  test('getBuildingLocationByAbbreviation returns the location of building', () {
    // Arrange
    final buildingViewModel = BuildingViewModel();
    const abb1 = 'H';
    const abb2 = 'EV';

    // should return H
    var location = buildingViewModel.getBuildingLocationByAbbreviation(abb1);
    expect(location, const LatLng(45.49721130711485, -73.5787529114208));

    // should return EV
    location = buildingViewModel.getBuildingLocationByAbbreviation(abb2);
    expect(location, const LatLng(45.49542095329432, -73.5779627198065));
  });
}
