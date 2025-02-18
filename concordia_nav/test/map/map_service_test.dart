import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';

// Generate mocks for GoogleMapController and Geolocator
@GenerateMocks([GoogleMapController, GeolocatorPlatform])
import 'map_service_test.mocks.dart';

void main() {
  late MapService mapService;
  late MockGoogleMapController mockGoogleMapController;

  setUp(() {
    mapService = MapService();
    mockGoogleMapController = MockGoogleMapController();
  });

  group('MapService Tests', () {
    test('setMapController should set the map controller', () {
      // Act
      mapService.setMapController(mockGoogleMapController);

      // Assert
      expect(mapService, isNotNull); // Indirectly verify the controller is set
    });

    test('getInitialCameraPosition should return correct CameraPosition', () {
      // Arrange
      const campus = ConcordiaCampus.loy;
      final expectedCameraPosition = CameraPosition(
        target: LatLng(campus.lat, campus.lng),
        zoom: 17.0,
      );

      // Act
      final result = mapService.getInitialCameraPosition(campus);

      // Assert
      expect(result, equals(expectedCameraPosition));
    });

    test('moveCamera should call animateCamera on the map controller', () {
      // Arrange
      const position = LatLng(37.7749, -122.4194);
      mapService.setMapController(mockGoogleMapController);

      // Act
      mapService.moveCamera(position);

      // Assert
      verify(mockGoogleMapController.animateCamera(
        argThat(
          isA<CameraUpdate>().having(
            (update) => update.toString(),
            'CameraUpdate',
            CameraUpdate.newCameraPosition(
              const CameraPosition(target: position, zoom: 17.0),
            ).toString(),
          ),
        ),
      )).called(1);
    });

    test('zoomIn should animate camera', () async {
      // Arrange
      const currentZoom = 10.50;
      mapService.setMapController(mockGoogleMapController);
      when(mockGoogleMapController.getZoomLevel()).thenAnswer((_) async => currentZoom);

      await mapService.zoomIn();

      verify(mockGoogleMapController.animateCamera(
        argThat(
          isA<CameraUpdate>().having(
            (update) => update.toString(),
            'CameraUpdate',
            CameraUpdate.zoomTo(
              currentZoom + 1,
            ).toString(),
          ),
        ),
      )).called(1);
    });

    test('zoomOut should animate camera', () async {
      // Arrange
      const currentZoom = 10.50;
      mapService.setMapController(mockGoogleMapController);
      when(mockGoogleMapController.getZoomLevel()).thenAnswer((_) async => currentZoom);

      await mapService.zoomOut();

      verify(mockGoogleMapController.animateCamera(
        argThat(
          isA<CameraUpdate>().having(
            (update) => update.toString(),
            'CameraUpdate',
            CameraUpdate.zoomTo(
              currentZoom - 1,
            ).toString(),
          ),
        ),
      )).called(1);
    });

    test('getCampusMarkers should return a set of markers for given locations',
        () {
      // Arrange
      final buildingLocations = [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.7849, -122.4294),
      ];
      final expectedMarkers = {
        Marker(
          markerId: MarkerId(buildingLocations[0].toString()),
          position: buildingLocations[0],
        ),
        Marker(
          markerId: MarkerId(buildingLocations[1].toString()),
          position: buildingLocations[1],
        ),
      };

      // Act
      final result = mapService.getCampusMarkers(buildingLocations);

      // Assert
      expect(result, equals(expectedMarkers));
    });
  });

  group('test geolocator methods', () {
    // random position far away from campuses
    final testPosition = Position(
        longitude: -73.5788992164221,
        latitude: 45.4952628500172,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 20.0,
        heading: 120,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0);
    // ref to permission integers: https://github.com/Baseflow/flutter-geolocator/blob/main/geolocator_platform_interface/lib/src/extensions/integer_extensions.dart
    var permission = 3; // permission set to accept
    var request = 3; // request permission set to accept
    var service = true; // locationService set to true

    // ensure plugin is initialized
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel locationChannel =
        MethodChannel('flutter.baseflow.com/geolocator');

    Future locationHandler(MethodCall methodCall) async {
      // grants access to location permissions
      if (methodCall.method == 'requestPermission') {
        return request;
      }
      // return testPosition when searching for the current location
      if (methodCall.method == 'getCurrentPosition') {
        return testPosition.toJson();
      }
      // set to true when device tries to check for permissions
      if (methodCall.method == 'isLocationServiceEnabled') {
        return service;
      }
      // returns authorized when checking for location permissions
      if (methodCall.method == 'checkPermission') {
        return permission;
      }
    }

    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(locationChannel, locationHandler);
    });
    
    test('isLocationServiceEnabled checks location services', () async {
      final result = await mapService.isLocationServiceEnabled();
      
      expect(result, true);
    });

    test('checkAndRequestLocationPermission returns right values', () async {
      var result = await mapService.checkAndRequestLocationPermission();
      expect(result, true);

      // should return false when permission deniedForever
      permission = 1; // sets to deniedForever
      result = await mapService.checkAndRequestLocationPermission();
      expect(result, false);

      // should return true when permission denied but request accepted
      permission = 0; // sets to denied
      result = await mapService.checkAndRequestLocationPermission();
      expect(result, true);

      // should return false when permission and request denied
      request = 0; // sets to denied
      permission = 0; // sets to denied
      result = await mapService.checkAndRequestLocationPermission();
      expect(result, false);
    });

    test('getCurrentLocation provides location', () async {
      permission = 3;
      service = true;
      final result = await mapService.getCurrentLocation();

      expect(result, isA<LatLng>());
      expect(result?.latitude, 45.4952628500172);
      expect(result?.longitude, -73.5788992164221);
    });

    test('getCurrentLocation returns error if service disabled', () async {
      service = false;
      // should return an error
      expect(mapService.getCurrentLocation(), throwsA('Location services are disabled.'));
    });

    test('getCurrentLocation returns error if location permissions are denied', () async {
      service = true;
      permission = 1;
      // should return an error
      expect(mapService.getCurrentLocation(), throwsA('Location permissions are denied.'));
    });
  });
}
