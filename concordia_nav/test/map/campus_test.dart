import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MapViewModel])
import 'campus_test.mocks.dart';

void main() {
  group('Campus Class Tests', () {
    late MockMapViewModel mockMapViewModel;
    late CampusMapPageState state;

    setUp(() {
      mockMapViewModel = MockMapViewModel();
      state = CampusMapPageState(mapViewModel: mockMapViewModel);
    });

    testWidgets('should load map data and update state',
        (WidgetTester tester) async {
      // Arrange
      const campus = ConcordiaCampus(
        45.4582,
        -73.6405,
        'Loyola Campus',
        '7141 Sherbrooke St W',
        'Montreal',
        'QC',
        'H4B 1R6',
        'LOY',
      );
      final mockResponse = {
        'polygons': <Polygon>{const Polygon(polygonId: PolygonId('1'))},
        'labels': <Marker>{const Marker(markerId: MarkerId('1'))},
      };

      when(mockMapViewModel.getCampusPolygonsAndLabels(campus)).thenAnswer(
        (_) async => mockResponse,
      );

      final expectedCameraPosition =
          CameraPosition(target: LatLng(campus.lat, campus.lng), zoom: 17.0);

      when(mockMapViewModel.getInitialCameraPosition(campus)).thenAnswer(
        (_) async => expectedCameraPosition,
      );

      // Act
      await tester.pumpWidget(MaterialApp(
        home: CampusMapPage(
          campus: campus,
          customState: state,
        ),
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(state.polygons, equals(mockResponse['polygons']));
      expect(state.labelMarkers, equals(mockResponse['labels']));
    });

    testWidgets('CampusMapPage should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMapPage(
            key: UniqueKey(),
            campus: ConcordiaCampus.loy,
          ),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.byType(CampusMapPage), findsOneWidget);

      // swaps campus button exists
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('Can swap between campuses', (WidgetTester tester) async {
      // Build the CampusMapPage with the SGW campus
      await tester.pumpWidget(const MaterialApp(
          home: const CampusMapPage(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Press the button that swaps campus views
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();

      // Verify that it swapped campuses
      expect(find.text('Loyola Campus'), findsOneWidget);

      // swap campus again should view SGW
      await tester.tap(find.byIcon(Icons.swap_horiz));
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
