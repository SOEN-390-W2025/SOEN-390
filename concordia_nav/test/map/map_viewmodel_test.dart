import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/repositories/map_repository.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
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
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission()).thenAnswer((_) async => true);

      // Act
      final result = await mapViewModel.checkLocationAccess();

      // Assert
      expect(result, true);
    });

    test('checkLocationAccess should return false when denied', () async {
      // Arrange
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => false);

      // Act
      final result = await mapViewModel.checkLocationAccess();

      // Assert
      expect(result, false);
    });

    test('getCurrentLocation provides a LatLng', () async {
      // Arrange
      when(mockMapService.getCurrentLocation()).thenAnswer((_) async => const LatLng(45.4952628500172, -73.5788992164221));

      // Act
      final result = await mapViewModel.fetchCurrentLocation();

      // Assert
      expect(result, isA<LatLng>());
      expect(result?.latitude, 45.4952628500172);
    });

    testWidgets("moveToCurrentLocation returns true with accesses", (WidgetTester tester) async {
      // Build a material app and fetch its build context
      await tester.pumpWidget(MaterialApp(home: Material(child: Container())));
      final BuildContext context = tester.element(find.byType(Container));

      // Arrange
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission()).thenAnswer((_) async => true);
      when(mockMapService.getCurrentLocation()).thenAnswer((_) async => const LatLng(45.4952628500172, -73.5788992164221));

      // Act
      final result = await mapViewModel.moveToCurrentLocation(context);

      // Assert
      expect(result, true);
    });

    testWidgets("moveToCurrentLocation returns false with snackbar when locationService disabled", (WidgetTester tester) async {
      // Build a material app and fetch its build context
      await tester.pumpWidget(const MaterialApp(home: Material(child: Scaffold())));
      final BuildContext context = tester.element(find.byType(Scaffold));

      // Arrange
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => false);

      // Act
      final result = await mapViewModel.moveToCurrentLocation(context);

      // Assert
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(result, false);
    });  

    testWidgets("moveToCurrentLocation returns false when location null", (WidgetTester tester) async {
      // Build a material app and fetch its build context
      await tester.pumpWidget(const MaterialApp(home: Material(child: Scaffold())));
      final BuildContext context = tester.element(find.byType(Scaffold));

      // Arrange
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => false);
      when(mockMapService.getCurrentLocation()).thenAnswer((_) async => const LatLng(100.0, 100.0));

      // Act
      final result = await mapViewModel.moveToCurrentLocation(context);

      // Assert
      expect(result, false);
    }); 

    test('onMapCreated should set map controller in map service', () {
      // Arrange
      final mockController = MockGoogleMapController();

      // Act
      mapViewModel.onMapCreated(mockController);

      // Assert
      verify(mockMapService.setMapController(mockController)).called(1);
    });

    test('switchCampus should move camera to new campus location', () {
      // Arrange
      const campus = ConcordiaCampus.loy;

      // Act
      mapViewModel.switchCampus(campus);

      // Assert
      verify(mockMapService.moveCamera(LatLng(campus.lat, campus.lng)))
          .called(1);
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

    test('getCampusMarkers should return markers from map service', () {
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

      when(mockMapService.getCampusMarkers(buildingLocations))
          .thenReturn(expectedMarkers);

      // Act
      final result = mapViewModel.getCampusMarkers(buildingLocations);

      // Assert
      expect(result, equals(expectedMarkers));
    });
  });
}

// Mock class for GoogleMapController
class MockGoogleMapController extends Mock implements GoogleMapController {}
