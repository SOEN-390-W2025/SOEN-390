import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/indoor_map/building_selection.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../settings/preferences_view_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  group('BuildingSelection Widget Tests', () {
    testWidgets('Selecting a building brings to FloorSelection',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingSelection(),
        ),
      );
      await tester.pumpAndSettle();

      // tap on a building
      expect(find.text("Hall Building"), findsOneWidget);
      await tester.tap(find.text("Hall Building"));
      await tester.pumpAndSettle();

      expect(find.text("Hall Building"), findsOneWidget);
      expect(find.text("Floor 1"), findsOneWidget);
    });

    testWidgets('BuildingSelection should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Build the BuildingSelection widget
      await tester.pumpWidget(
        MaterialApp(
          home: BuildingSelection(key: UniqueKey()),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.text('Floor Navigation'), findsOneWidget);
    });

    testWidgets('BuildingSelection should render correctly',
        (WidgetTester tester) async {
      // Build the BuildingSelection widget
      await tester.pumpWidget(
        const MaterialApp(
          home: BuildingSelection(),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.text('Floor Navigation'), findsOneWidget);
    });
  });

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
        await tester.pump();

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
        await tester.pump();

        // Enter a search term
        await tester.enterText(find.byType(TextField), '90');
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
        expect(classrooms, contains('903'),
            reason: 'Room 3 should be found');
        expect(classrooms, contains('904'),
            reason: 'Room 4 should be found');
        expect(classrooms, isNot(contains('911')),
            reason: 'Room 11 should not be found');
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
        await tester.pump();

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
        await tester.pump();

        // Enter a non-matching search term
        await tester.enterText(find.byType(TextField), '104');
        await tester.pumpAndSettle(); // Rebuild the widget after the text input

        // Assert: Verify no classrooms are shown
        expect(find.text('Classroom 101'), findsNothing);
        expect(find.text('Classroom 102'), findsNothing);
        expect(find.text('Classroom 103'), findsNothing);
      });
    });

    testWidgets('should display IndoorLocationView on tapping a classroom with isSearch on',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';
        const floor = 'Floor 1';
        const classroom = '102-3';

        // Build the widget
        await tester.pumpWidget(const MaterialApp(
          home: ClassroomSelection(building: building, floor: floor, isSearch: true,),
        ));
        await tester.pump();

        // Make sure the element is visible before tapping
        await tester.ensureVisible(find.text(classroom));
        await tester.pumpAndSettle();

        // Simulate tapping on a classroom
        expect(find.text('102-3'), findsOneWidget);
        await tester.tap(find.text(classroom));
        await tester.pumpAndSettle(); 

        expect(find.text('H 102-3'), findsOneWidget);
        expect(find.text('Hall Building'), findsOneWidget);
      });
    });

    testWidgets('should display IndoorDirectionsView on tapping a classroom',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Arrange
        const building = 'Hall Building';
        const floor = 'Floor 1';
        const classroom = '102-3';
        final mockPreferencesModel = MockPreferencesModel();
        when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
        when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');

        // define routes needed for this test
        final routes = {
          '/': (context) => const ClassroomSelection(building: building, floor: floor),
          'IndoorDirectionsView': (context) => IndoorDirectionsView(
            sourceRoom: 'Your Location', building: building, 
            endRoom: classroom)
        };

        // Build the widget
        await tester.pumpWidget(
          ChangeNotifierProvider<PreferencesModel>(
            create: (BuildContext context) => mockPreferencesModel,
            child: MaterialApp(
                    initialRoute: '/',
                    routes: routes,
                  ),
          )
        );
        await tester.pump();

        // Make sure the element is visible before tapping
        await tester.ensureVisible(find.text(classroom));
        await tester.pump();

        // Simulate tapping on a classroom
        expect(find.text('102-3'), findsOneWidget);
        await tester.tap(find.text(classroom));
        await tester.pumpAndSettle(); 

        expect(find.text('From: Your Location'), findsOneWidget);
        expect(find.text('To: H 102-3'), findsOneWidget);
      });
    });
  });
}
