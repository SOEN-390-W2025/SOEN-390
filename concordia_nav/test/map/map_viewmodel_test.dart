import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/services/helpers/icon_loader.dart';
import 'package:concordia_nav/data/services/outdoor_directions_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:concordia_nav/data/repositories/map_repository.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'map_viewmodel_test.mocks.dart';

class MockIconLoader extends Mock implements IconLoader {}

@GenerateMocks([MapRepository, MapService, MapViewModel, ODSDirectionsService])
void main() {
  late MapViewModel mapViewModel;
  late MockMapRepository mockMapRepository;
  late MockMapService mockMapService;
  late MockODSDirectionsService mockODSDirectionsService;

  setUp(() {
    mockMapRepository = MockMapRepository();
    mockMapService = MockMapService();
    mockODSDirectionsService = MockODSDirectionsService();
    mapViewModel = MapViewModel(
        mapRepository: mockMapRepository, mapService: mockMapService, odsDirectionsService: mockODSDirectionsService);
  });

  group('fetchRoute', () {
    test('throws exception when destinationAddress is empty', () async {
      // Arrange
      const originAddress = 'origin';
      const destinationAddress = '';
      
      when(mockODSDirectionsService.fetchRouteResult(
        originAddress: originAddress, destinationAddress: destinationAddress, travelMode: gda.TravelMode.driving,
        polylineId: any, color: any, width: any))
        .thenThrow(Exception('Failed to fetch route'));

      // Act & Assert
      expect(
          () async =>
              await mapViewModel.fetchRoutesForAllModes(originAddress, destinationAddress),
          throwsException);
    });

    test(
        'successfully fetches route and creates polyline and destination marker',
        () async {
      // Arrange
      const originAddress = 'origin';
      const destinationAddress = 'destination';

      final routePoints = <LatLng>[
        const LatLng(45.4215, -75.6972),
        const LatLng(45.4216, -75.6969),
      ];

      final polyline = Polyline(polylineId: const PolylineId('2'), points: routePoints);
      when(mockODSDirectionsService.fetchRouteResult(
        originAddress: originAddress, destinationAddress: destinationAddress, travelMode: gda.TravelMode.driving, polylineId: any, color: any, width: any))
        .thenAnswer((_) async => OutdoorRouteResult(polyline: polyline, travelTime: '2'));
      when(mockODSDirectionsService.fetchRouteResult(
        originAddress: originAddress, destinationAddress: destinationAddress, travelMode: gda.TravelMode.walking, polylineId: any, color: any, width: any))
        .thenAnswer((_) async => OutdoorRouteResult(polyline: polyline, travelTime: '2'));
      when(mockODSDirectionsService.fetchRouteResult(
        originAddress: originAddress, destinationAddress: destinationAddress, travelMode: gda.TravelMode.bicycling, polylineId: any, color: any, width: any))
        .thenAnswer((_) async => OutdoorRouteResult(polyline: polyline, travelTime: '2'));
      when(mockODSDirectionsService.fetchRouteResult(
        originAddress: originAddress, destinationAddress: destinationAddress, travelMode: gda.TravelMode.transit, polylineId: any, color: any, width: any))
        .thenAnswer((_) async => OutdoorRouteResult(polyline: polyline, travelTime: '2'));

      when(mockMapService.adjustCameraForPath(routePoints)).thenAnswer((_) => true);

      // Mock getRoutePath to return the routePoints
      when(mockMapService.getRoutePath(originAddress, destinationAddress))
          .thenAnswer((_) async => routePoints);

      // Act
      await mapViewModel.fetchRoutesForAllModes(originAddress, destinationAddress);

      // Assert
      expect(mapViewModel.activePolylines.isNotEmpty, true);
      expect(mapViewModel.destinationMarker, isNotNull);
      expect(
          mapViewModel.destinationMarker?.position, equals(routePoints.last));
    });

    test('throws exception when route fetching fails', () async {
      // Arrange
      const originAddress = 'origin';
      const destinationAddress = 'destination';

      when(mockODSDirectionsService.fetchRouteResult(
        originAddress: originAddress, destinationAddress: destinationAddress, travelMode: gda.TravelMode.driving, polylineId: any, color: any, width: any))
        .thenThrow(Exception('Failed to fetch route'));

      // Mock getRoutePath to throw an exception
      when(mockMapService.getRoutePath(originAddress, destinationAddress))
          .thenThrow(Exception('Failed to fetch route'));

      // Act & Assert
      expect(
        () async =>
            await mapViewModel.fetchRoutesForAllModes(originAddress, destinationAddress),
        throwsException,
      );
    });
  });

  group('MapViewModel Tests', () {
    test(
        'getInitialCameraPosition should return CameraPosition from repository',
        () async {
      // Arrange
      const campus = ConcordiaCampus.sgw;
      final expectedCameraPosition =
          CameraPosition(target: LatLng(campus.lat, campus.lng), zoom: 17.0);

      when(mockMapRepository.getCameraPosition(campus))
          .thenReturn(expectedCameraPosition);

      // Act
      final result = await mapViewModel.getInitialCameraPosition(campus);

      // Assert
      expect(result, equals(expectedCameraPosition));
    });

    test('checkLocationAccess should return permission accepted', () async {
      // Arrange
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      // Act
      final result = await mapViewModel.checkLocationAccess();

      // Assert
      expect(result, true);
    });

    test('checkLocationAccess should return false when denied', () async {
      // Arrange
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      // Act
      final result = await mapViewModel.checkLocationAccess();

      // Assert
      expect(result, false);
    });

    test('getCurrentLocation provides a LatLng', () async {
      // Arrange
      when(mockMapService.getCurrentLocation()).thenAnswer(
          (_) async => const LatLng(45.4952628500172, -73.5788992164221));

      // Act
      final result = await mapViewModel.fetchCurrentLocation();

      // Assert
      expect(result, isA<LatLng>());
      expect(result?.latitude, 45.4952628500172);
    });

    testWidgets("moveToCurrentLocation returns true with accesses",
        (WidgetTester tester) async {
      // Build a material app and fetch its build context
      await tester.pumpWidget(MaterialApp(home: Material(child: Container())));
      final BuildContext context = tester.element(find.byType(Container));

      // Arrange
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);
      when(mockMapService.getCurrentLocation()).thenAnswer(
          (_) async => const LatLng(45.4952628500172, -73.5788992164221));

      // Act
      final result = await mapViewModel.moveToCurrentLocation(context);

      // Assert
      expect(result, true);
    });

    test(
        'moveToLocation should call moveCamera on MapService with correct LatLng',
        () {
      // Arrange
      const LatLng testLocation = LatLng(45.5017, -73.5673);

      // Act
      mapViewModel.moveToLocation(testLocation);

      // Assert
      verify(mockMapService.moveCamera(testLocation)).called(1);
    });

    testWidgets(
        "moveToCurrentLocation returns false with snackbar when locationService disabled",
        (WidgetTester tester) async {
      // Build a material app and fetch its build context
      await tester
          .pumpWidget(const MaterialApp(home: Material(child: Scaffold())));
      final BuildContext context = tester.element(find.byType(Scaffold));

      // Arrange
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      // Act
      final result = await mapViewModel.moveToCurrentLocation(context);

      // Assert
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(result, false);
    });

    testWidgets("moveToCurrentLocation returns false when location null",
        (WidgetTester tester) async {
      // Build a material app and fetch its build context
      await tester
          .pumpWidget(const MaterialApp(home: Material(child: Scaffold())));
      final BuildContext context = tester.element(find.byType(Scaffold));

      // Arrange
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => false);
      when(mockMapService.getCurrentLocation())
          .thenAnswer((_) async => const LatLng(100.0, 100.0));

      // Act
      final result = await mapViewModel.moveToCurrentLocation(context);

      // Assert
      expect(result, false);
    });

    testWidgets('checkBuildingAtCurrentLocation unselects building if far',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Build a material app and fetch its build context
        await tester
            .pumpWidget(const MaterialApp(home: Material(child: Scaffold())));
        final BuildContext context = tester.element(find.byType(Scaffold));

        // Arrange
        when(mockMapService.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
        when(mockMapService.getCurrentLocation()).thenAnswer((_) async =>
            const LatLng(
                45.53045657870464, -73.60871108784625)); // location in hall

        // Act
        await mapViewModel.checkBuildingAtCurrentLocation(context);

        // Assert
        expect(mapViewModel.selectedBuildingNotifier.value, null);
      });
    });

    testWidgets('checkBuildingAtCurrentLocation select building if in',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Build a material app and fetch its build context
        await tester
            .pumpWidget(const MaterialApp(home: Material(child: Scaffold())));
        final BuildContext context = tester.element(find.byType(Scaffold));

        // Arrange
        when(mockMapService.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
        when(mockMapService.getCurrentLocation()).thenAnswer((_) async =>
            const LatLng(
                45.49716269198435, -73.5791585092084)); // location in hall

        // Act
        await mapViewModel.checkBuildingAtCurrentLocation(context);

        // Assert
        expect(
            mapViewModel.selectedBuildingNotifier.value, BuildingRepository.h);
      });
    });

    test('onMapCreated should set map controller in map service', () {
      // Arrange
      final mockController = MockGoogleMapController();

      // Act
      mapViewModel.onMapCreated(mockController);

      // Assert
      verify(mockMapService.setMapController(mockController)).called(1);
    });

    test('zoomIn should be called', () async {
      // Act
      await mapViewModel.zoomIn();

      // Assert
      verify(mockMapService.zoomIn()).called(1);
    });

    test('zoomOut should be called', () async {
      // Act
      await mapViewModel.zoomOut();

      // Assert
      verify(mockMapService.zoomOut()).called(1);
    });

    test('getCampusPolygonsAndLabels should return values from map service',
        () async {
      // Arrange
      const campus = ConcordiaCampus.sgw;
      final Future<BitmapDescriptor> bitmapDescriptor =
          IconLoader.loadBitmapDescriptor('assets/icons/H.png');

      when(mockMapService.getCustomIcon(any))
          .thenAnswer((_) async => bitmapDescriptor);

      // Act
      final result = await mapViewModel.getCampusPolygonsAndLabels(campus);

      // Assert
      expect(result.length, 2);
      expect(result["polygons"].elementAt(0), isA<Polygon>());
      expect(result["labels"].elementAt(0), isA<Marker>());
    });

    test('getAllCampusPolygonsAndLabels should return right value', () async {
      // Arrange
      final Future<BitmapDescriptor> bitmapDescriptor =
          IconLoader.loadBitmapDescriptor('assets/icons/H.png');
      when(mockMapService.getCustomIcon(any))
          .thenAnswer((_) async => bitmapDescriptor);

      // Act
      final result = await mapViewModel.getAllCampusPolygonsAndLabels();

      // Assert
      expect(result.length, 2);
      expect(result["polygons"].elementAt(0), isA<Polygon>());
      expect(result["labels"].elementAt(0), isA<Marker>());
    });

    test('selectBuilding should change selectedBuildingNotifier value',
        () async {
      // Select MB building
      mapViewModel.selectBuilding(BuildingRepository.mb);

      // should change selectedBuildingNotifier's value
      expect(
          mapViewModel.selectedBuildingNotifier.value, BuildingRepository.mb);
    });

    test(
        'unselectBuilding should change selectedBuildingNotifier value to null',
        () async {
      // Select MB building
      mapViewModel.selectBuilding(BuildingRepository.mb);

      // should change selectedBuildingNotifier's value
      expect(
          mapViewModel.selectedBuildingNotifier.value, BuildingRepository.mb);

      // unselecting changes value to null
      mapViewModel.unselectBuilding();
      expect(mapViewModel.selectedBuildingNotifier.value, null);
    });
  });
}

// Mock class for GoogleMapController
class MockGoogleMapController extends Mock implements GoogleMapController {}
