import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_location_view.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:concordia_nav/widgets/floor_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../settings/preferences_view_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  const ConcordiaCampus campus = ConcordiaCampus(
    45.49721130711485,
    -73.5787529114208,
    "Sir George Williams Campus",
    "1455 boul. de Maisonneuve O",
    "Montreal",
    "QC",
    "H3G 1M8",
    "SGW"
  );

  const ConcordiaBuilding building = ConcordiaBuilding(
    45.49721130711485,
    -73.5787529114208,
    "Hall Building",
    "1455 boul. de Maisonneuve O",
    "Montreal",
    "QC",
    "H3G 1M8",
    "H",
    campus
  );

  group('IndoorLocationView', () {

    testWidgets('Directions button is not present in IndoorLocationView if room is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorLocationView(building: building,),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Directions'), findsNothing);
    });

    testWidgets('FloorButton exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorLocationView(building: building, floor: '1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloorButton), findsOneWidget);
    });

    testWidgets('Tapping FloorButton triggers floor selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorLocationView(building: building, floor: '1'),
        ),
      );
      await tester.pump();

      // tap the floorbutton
      await tester.tap(find.byType(FloorButton));
      await tester.pumpAndSettle();

      expect(find.text('Select a floor'), findsOneWidget);
    });

    testWidgets('Tapping Directions button navigates to IndoorDirectionsView',
        (WidgetTester tester) async {
      final mockPreferencesModel = MockPreferencesModel();
      when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
      when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');

      // define routes needed for this test
      final routes = {
        '/': (context) => const IndoorLocationView(building: building, room: 'H 110'),
        'IndoorDirectionsView': (context) => IndoorDirectionsView(
          sourceRoom: 'Your Location', building: building.name, 
          endRoom: 'H 110')
      };

      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  initialRoute: '/',
                  routes: routes,
                ),
        )
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Directions'));
      await tester.pumpAndSettle();
      expect(find.byType(IndoorDirectionsView), findsOneWidget);
    });

    testWidgets('renders correctly with a non-constant key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IndoorLocationView(
            building: building,
            key: UniqueKey(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(building.name), findsOneWidget);
    });
  });

  group('indoor location appBar', () {
    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the indoor location view widget
      await tester.pumpWidget(const MaterialApp(
          home: IndoorLocationView(building: building)));
      await tester.pumpAndSettle();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(building.name), findsOneWidget);
    });
  });

  group('indoor location view page', () {
    testWidgets('mapLayout widget exists', (WidgetTester tester) async {
      // Build the indoor location view widget
      await tester.pumpWidget(const MaterialApp(
          home: IndoorLocationView(building: building)));
      await tester.pumpAndSettle();

      // Verify that MapLayout widget exists
      expect(find.byType(Stack), findsAtLeast(2));
    });
  });
}
