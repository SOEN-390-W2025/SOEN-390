import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/repositories/map_repository.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'map_viewmodel_test.mocks.dart';

@GenerateMocks([MapRepository, MapService])
void main() {
  late MapViewModel mapViewModel;
  late MockMapRepository mockMapRepository;
  late MockMapService mockMapService;

  setUp(() {
    mockMapRepository = MockMapRepository();
    mockMapService = MockMapService();
    mapViewModel = MapViewModel(
        mapRepository: mockMapRepository, mapService: mockMapService);
  });

  group('Campus Class Tests', () {
    testWidgets('CampusMapPage should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Arrange
      final buildingLocations = [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.7849, -122.4294),
      ];
      final expectedMarkers = {
        Marker(
            markerId: MarkerId(const LatLng(37.7749, -122.4194).toString()),
            position: buildingLocations[0]),
        Marker(
            markerId: MarkerId(const LatLng(37.7849, -122.4294).toString()),
            position: buildingLocations[1]),
      };
      when(mockMapService.getCampusMarkers([])).thenReturn(expectedMarkers);
      when(mockMapRepository.getCameraPosition(ConcordiaCampus.loy)).thenReturn(CameraPosition(target: LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng), zoom: 17.0));
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission()).thenAnswer((_) async => true);
      when(mapViewModel.checkLocationAccess()).thenAnswer((_) async => true);
      
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMapPage(
            key: UniqueKey(),
            campus: ConcordiaCampus.loy,
            mapViewModel: mapViewModel,
          ),
        ),
      );

      await tester.pump();
      // Verify that the custom app bar is rendered with the correct title
      expect(find.byType(CampusMapPage), findsOneWidget);

      // swaps campus button exists
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);

      // verify that a MapLayout widget exists
      expect(find.byType(MapLayout), findsOneWidget);
    });

    testWidgets('Can swap between campuses', (WidgetTester tester) async {
      // Arrange
      final buildingLocations = [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.7849, -122.4294),
      ];
      final expectedMarkers = {
        Marker(
            markerId: MarkerId(const LatLng(37.7749, -122.4194).toString()),
            position: buildingLocations[0]),
        Marker(
            markerId: MarkerId(const LatLng(37.7849, -122.4294).toString()),
            position: buildingLocations[1]),
      };
      when(mockMapService.getCampusMarkers([])).thenReturn(expectedMarkers);
      when(mockMapRepository.getCameraPosition(ConcordiaCampus.sgw)).thenReturn(CameraPosition(target: LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng), zoom: 17.0));
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission()).thenAnswer((_) async => true);
      when(mapViewModel.checkLocationAccess()).thenAnswer((_) async => true);
      
      // Build the CampusMapPage with the SGW campus
      await tester.pumpWidget(MaterialApp(home: CampusMapPage(campus: ConcordiaCampus.sgw, mapViewModel: mapViewModel)));
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

    testWidgets('CampusMapPage displays error when cameraposition not provided',
        (WidgetTester tester) async {
      // Arrange
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission()).thenAnswer((_) async => true);
      when(mapViewModel.checkLocationAccess()).thenAnswer((_) async => true);
      
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMapPage(
            key: UniqueKey(),
            campus: ConcordiaCampus.loy,
            mapViewModel: mapViewModel,
          ),
        ),
      );

      await tester.pump();
      // Verify that the custom app bar is rendered with the correct title
      expect(find.byType(CampusMapPage), findsOneWidget);

      // Error message is displayed
      expect(find.text('Error loading campus map'), findsOneWidget);
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
      const testCampus = ConcordiaCampus(45.52316480127478, -73.56082777329514, 
        "Cafe Chat Lheureux", "1374 Ontario St E", "Montreal", "QC", "H2L 1S1", "CCH");
      expect(testCampus.city, "Montreal");
      expect(testCampus.abbreviation, "CCH");
    });

    test('Can create Location', () {
      const testLocation = Location(45.52316480127478, -73.56082777329514, 
        "Cafe Chat Lheureux", "1374 Ontario St E", "Montreal", "QC", "H2L 1S1");
      expect(testLocation.city, "Montreal");
      expect(testLocation.name, "Cafe Chat Lheureux");
      expect(testLocation.lat, 45.52316480127478);
    });
  });
}
