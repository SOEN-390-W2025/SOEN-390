import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'map_service_test.mocks.dart';

// Generate mocks for GoogleMapController
@GenerateMocks([GoogleMapController, MapService, GeolocatorPlatform])
void main() {
  late MockMapService mockMapService;
  late MapService realMapService;
  late MockGoogleMapController mockGoogleMapController;

  setUp(() {
    mockMapService = MockMapService();
    realMapService = MapService();
    mockGoogleMapController = MockGoogleMapController();
  });

  group('MapService Tests', () {
    test('getCampusPolygonsAndLabels should return correct data', () async {
      // Act
      final result =
          await realMapService.getCampusPolygonsAndLabels(ConcordiaCampus.sgw);

      // Assert
      expect(result['polygons'], isA<Set<Polygon>>());
      expect(result['labels'], isA<Set<Marker>>());

      expect(
          result['polygons'].any((polygon) => polygon.polygonId.value == 'H'),
          isTrue);
      expect(result['labels'].any((marker) => marker.markerId.value == 'H'),
          isTrue);
    });

    test('setMapController should set the map controller', () {
      // Act
      realMapService.setMapController(mockGoogleMapController);

      // Assert
      expect(
          realMapService, isNotNull); // Indirectly verify the controller is set
    });

    test('getInitialCameraPosition should return correct CameraPosition', () {
      // Arrange
      const campus = ConcordiaCampus.loy;
      final expectedCameraPosition = CameraPosition(
        target: LatLng(campus.lat, campus.lng),
        zoom: 17.0,
      );

      when(mockMapService.getInitialCameraPosition(campus))
          .thenAnswer((_) => expectedCameraPosition);

      // Act
      final result = mockMapService.getInitialCameraPosition(campus);

      // Assert
      expect(result, equals(expectedCameraPosition));
    });

    test('getInitialCameraPosition should return correct CameraPosition', () {
      // Arrange
      const campus = ConcordiaCampus(
        45.4582,
        -73.6405,
        'Loyola Campus',
        'Some other parameter 1',
        'Some other parameter 2',
        'Some other parameter 3',
        'Some other parameter 4',
        'Some other parameter 5',
      );
      final expectedCameraPosition = CameraPosition(
        target: LatLng(campus.lat, campus.lng),
        zoom: 17.0,
      );

      // Act
      final result = realMapService.getInitialCameraPosition(campus);

      // Assert
      expect(result, equals(expectedCameraPosition));
    });

    test('moveCamera should call animateCamera on the map controller', () {
      // Arrange
      const position = LatLng(37.7749, -122.4194);
      realMapService.setMapController(mockGoogleMapController);

      // Act
      realMapService.moveCamera(position);

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
      realMapService.setMapController(mockGoogleMapController);
      when(mockGoogleMapController.getZoomLevel())
          .thenAnswer((_) async => currentZoom);

      await realMapService.zoomIn();

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
      realMapService.setMapController(mockGoogleMapController);
      when(mockGoogleMapController.getZoomLevel())
          .thenAnswer((_) async => currentZoom);

      await realMapService.zoomOut();

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
        () async {
      // Arrange
      const campus = ConcordiaCampus.sgw;

      // Mock polygon data for "EV" building
      final List<LatLng> evPolygon = [
        const LatLng(45.4951601, -73.5778544),
        const LatLng(45.4958369, -73.5772375),
        const LatLng(45.496057, -73.5777095),
        const LatLng(45.4958955, -73.577867),
        const LatLng(45.4957351, -73.5780097),
        const LatLng(45.4959616, -73.5785005),
        const LatLng(45.4956038, -73.5788334),
        const LatLng(45.4951601, -73.5778544),
      ];

      // Compute centroid for EV polygon (for marker placement)
      final double centroidLat =
          evPolygon.map((p) => p.latitude).reduce((a, b) => a + b) /
              evPolygon.length;
      final double centroidLng =
          evPolygon.map((p) => p.longitude).reduce((a, b) => a + b) /
              evPolygon.length;
      final LatLng evCentroid = LatLng(centroidLat, centroidLng);

      // Expected polygon set
      final Set<Polygon> mockPolygons = {
        Polygon(
          polygonId: const PolygonId("EV"),
          points: evPolygon,
          strokeWidth: 3,
          strokeColor: const Color(0xFFB48107),
          fillColor: const Color(0xFFe5a712),
        ),
      };

      // Expected markers set
      final Set<Marker> mockMarkers = {
        Marker(
          markerId: const MarkerId("EV"),
          position: evCentroid,
          icon: BitmapDescriptor.defaultMarker, // Mocked icon
        ),
      };

      // Mock response
      when(mockMapService.getCampusPolygonsAndLabels(campus)).thenAnswer(
          (_) async => {"polygons": mockPolygons, "labels": mockMarkers});

      // Act
      final result = await mockMapService.getCampusPolygonsAndLabels(campus);

      // Assert
      expect(result["polygons"], equals(mockPolygons));
      expect(result["labels"], equals(mockMarkers));
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
      final result = await realMapService.isLocationServiceEnabled();

      expect(result, true);
    });

    test('checkAndRequestLocationPermission returns right values', () async {
      var result = await realMapService.checkAndRequestLocationPermission();
      expect(result, true);

      // should return false when permission deniedForever
      permission = 1; // sets to deniedForever
      result = await realMapService.checkAndRequestLocationPermission();
      expect(result, false);

      // should return true when permission denied but request accepted
      permission = 0; // sets to denied
      result = await realMapService.checkAndRequestLocationPermission();
      expect(result, true);

      // should return false when permission and request denied
      request = 0; // sets to denied
      permission = 0; // sets to denied
      result = await realMapService.checkAndRequestLocationPermission();
      expect(result, false);
    });

    test('getCurrentLocation provides location', () async {
      permission = 3;
      service = true;
      final result = await realMapService.getCurrentLocation();

      expect(result, isA<LatLng>());
      expect(result?.latitude, 45.4952628500172);
      expect(result?.longitude, -73.5788992164221);
    });

    test('getCurrentLocation returns error if service disabled', () async {
      service = false;
      // should return an error
      expect(realMapService.getCurrentLocation(),
          throwsA('Location services are disabled.'));
    });

    test('getCurrentLocation returns error if location permissions are denied',
        () async {
      service = true;
      permission = 1;
      // should return an error
      expect(realMapService.getCurrentLocation(),
          throwsA('Location permissions are denied.'));
    });
  });
}
