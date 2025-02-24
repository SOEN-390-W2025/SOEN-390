import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'map_viewmodel_test.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  group('Campus Class Tests', () {
    late MockMapViewModel mapViewModel;

    setUp(() {
      mapViewModel = MockMapViewModel();

      // Arrange
      final mockResponse = {
        'polygons': <Polygon>{const Polygon(polygonId: PolygonId('1'))},
        'labels': <Marker>{const Marker(markerId: MarkerId('1'))},
      };

      const ConcordiaCampus campus = ConcordiaCampus.loy;
      final expectedCameraPosition = CameraPosition(
        target: LatLng(campus.lat, campus.lng),
        zoom: 17.0,
      );

      when(mapViewModel.selectedBuildingNotifier)
          .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));
      when(mapViewModel.loadStaticBusStopMarkers()).thenAnswer((_) async => true);
      when(mapViewModel.startShuttleBusTimer()).thenAnswer((_) async => true);

      when(mapViewModel.getInitialCameraPosition(ConcordiaCampus.loy))
          .thenAnswer((_) async => expectedCameraPosition);

      when(mapViewModel.getCampusPolygonsAndLabels(ConcordiaCampus.loy))
          .thenAnswer((_) async => mockResponse);

      when(mapViewModel.getInitialCameraPosition(ConcordiaCampus.sgw))
          .thenAnswer((_) async => expectedCameraPosition);

      when(mapViewModel.getCampusPolygonsAndLabels(ConcordiaCampus.sgw))
          .thenAnswer((_) async => mockResponse);

      when(mapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

      when(mapViewModel.getAllCampusPolygonsAndLabels())
          .thenAnswer((_) async => {
                "polygons": <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
                "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
              });
    });

    testWidgets('CampusMapPage should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMapPage(
            key: UniqueKey(),
            campus: ConcordiaCampus.loy,
            mapViewModel: mapViewModel,
            buildMapViewModel: mapViewModel,
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Verify that the custom app bar is rendered with the correct title
      expect(find.byType(CampusMapPage), findsOneWidget);

      // swaps campus button exists
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);

      // find current location button
      expect(find.byIcon(Icons.my_location), findsOneWidget);

      // verify that a MapLayout widget exists
      expect(find.byType(MapLayout), findsOneWidget);
    });

    testWidgets('Can swap between campuses', (WidgetTester tester) async {
      // Build the CampusMapPage with the SGW campus
      await tester.pumpWidget(MaterialApp(
          home: CampusMapPage(
              campus: ConcordiaCampus.loy, mapViewModel: mapViewModel, buildMapViewModel: mapViewModel)));
      await tester.pumpAndSettle();

      // Press the button that swaps campus views
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);

      // Verify that it swapped campuses
      expect(find.text('Loyola Campus'), findsOneWidget);

      // swap campus again should view SGW
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      expect(find.text('Sir George Williams Campus'), findsOneWidget);
    });

    testWidgets('current location button works', (WidgetTester tester) async {
      // Build the CampusMapPage with the SGW campus
      await tester.pumpWidget(MaterialApp(
          home: CampusMapPage(
              campus: ConcordiaCampus.sgw, mapViewModel: mapViewModel, buildMapViewModel: mapViewModel)));
      await tester.pumpAndSettle();

      when(mapViewModel
              .checkBuildingAtCurrentLocation(argThat(isA<BuildContext>())))
          .thenAnswer((_) async => true);

      when(mapViewModel.moveToCurrentLocation(argThat(isA<BuildContext>())))
          .thenAnswer((_) async => true);

      // find current location button
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      // tap the current location button
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      expect(find.text('Sir George Williams Campus'), findsOneWidget);
    });

    test('Verify SGW campus properties', () {
      expect(ConcordiaCampus.sgw.name, "Sir George Williams Campus");
      expect(ConcordiaCampus.sgw.abbreviation, "SGW");
      expect(ConcordiaCampus.sgw.lat, 45.49721130711485);
      expect(ConcordiaCampus.sgw.lng, -73.5787529114208);
    });

    test('Verify LOY campus properties', () {
      expect(ConcordiaCampus.loy.name, "Loyola Campus");
      expect(ConcordiaCampus.loy.abbreviation, "LOY");
      expect(ConcordiaCampus.loy.lat, 45.45887506989712);
      expect(ConcordiaCampus.loy.lng, -73.6404461142605);
    });

    test('Campus.fromAbbreviation returns correct campus', () {
      expect(ConcordiaCampus.fromAbbreviation("sgw"), ConcordiaCampus.sgw);
      expect(ConcordiaCampus.fromAbbreviation("loy"), ConcordiaCampus.loy);
    });

    test('Campus.fromAbbreviation throws exception for invalid abbreviation',
        () {
      expect(
          () => ConcordiaCampus.fromAbbreviation("xyz"), throwsArgumentError);
      expect(() => ConcordiaCampus.fromAbbreviation(""), throwsArgumentError);
    });

    test('Campus.campuses contains only predefined campuses', () {
      expect(ConcordiaCampus.campuses.length, 2);
      expect(ConcordiaCampus.campuses, contains(ConcordiaCampus.sgw));
      expect(ConcordiaCampus.campuses, contains(ConcordiaCampus.loy));
      expect(ConcordiaCampus.campuses, isNot(contains(null)));
    });

    test('Can create a campus', () {
      const testCampus = ConcordiaCampus(
          45.52316480127478,
          -73.56082777329514,
          "Cafe Chat Lheureux",
          "1374 Ontario St E",
          "Montreal",
          "QC",
          "H2L 1S1",
          "CCH");
      expect(testCampus.city, "Montreal");
      expect(testCampus.abbreviation, "CCH");
    });

    test('Can create Location', () {
      const testLocation = Location(
          45.52316480127478,
          -73.56082777329514,
          "Cafe Chat Lheureux",
          "1374 Ontario St E",
          "Montreal",
          "QC",
          "H2L 1S1");
      expect(testLocation.city, "Montreal");
      expect(testLocation.name, "Cafe Chat Lheureux");
      expect(testLocation.lat, 45.52316480127478);
    });
  });
}
