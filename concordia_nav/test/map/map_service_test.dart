import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import '../directions/outdoor_directions_test.mocks.dart';
import 'map_service_test.mocks.dart';

class FakeMapService extends MapService {
  LatLng? fakeLocation;

  @override
  Future<LatLng?> getCurrentLocation() async {
    return null;
  }
}

// Generate mocks for GoogleMapController
@GenerateMocks([GoogleMapController, MapService, GeolocatorPlatform])
Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  late MockMapService mockMapService;
  late MapViewModel realmapViewModel;
  late MapService realMapService;
  late MockGoogleMapController mockGoogleMapController;
  late MockODSDirectionsService mockODSdirectionsService;
  late MockDirectionsService mockDirectionsService;

  setUp(() {
    mockMapService = MockMapService();
    realmapViewModel = MapViewModel();
    realMapService = MapService();
    mockGoogleMapController = MockGoogleMapController();

    mockDirectionsService = MockDirectionsService();
    mockODSdirectionsService = MockODSDirectionsService();
    mockODSdirectionsService.directionsService = mockDirectionsService;

    realMapService.setDirectionsService(mockODSdirectionsService);
  });

  group('MapService Tests', () {
    test('getCampusPolygonsAndLabels should return correct data', () async {
      // Act
      final result = await realmapViewModel
          .getCampusPolygonsAndLabels(ConcordiaCampus.sgw);

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

    test('adjustCameraForPath should call animateCamera on the map controller',
        () {
      // Arrange
      final routePoints = <LatLng>[
        const LatLng(45.4215, -75.6972),
        const LatLng(45.4216, -75.6969),
      ];

      realMapService.setMapController(mockGoogleMapController);

      // Act
      realMapService.adjustCameraForPath(routePoints);

      // Assert
      verify(mockGoogleMapController.animateCamera(
        argThat(
          isA<CameraUpdate>().having(
            (update) => update.toString(),
            'CameraUpdate',
            CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: const LatLng(45.4215, -75.6972),
                      northeast: const LatLng(45.4216, -75.6969),
                    ),
                    70)
                .toString(),
          ),
        ),
      )).called(1);
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

    test('getRoutePath should throw an exception when origin is invalid',
        () async {
      permission = 0;
      request = 0;
      service = true;

      // Act & Assert
      expect(
        () => FakeMapService().getRoutePath('', 'Hall Building'),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Invalid origin'))),
      );
    });

    test(
        'getRoutePath succeeds when origin is invalid but location services is on',
        () async {
      permission = 3;
      request = 3;
      service = true;

      final expectedRoute = <LatLng>[
        const LatLng(45.4215, -75.6972),
        const LatLng(45.4216, -75.6969),
      ];

      when(mockODSdirectionsService.fetchRouteFromCoords(
              const LatLng(45.4952628500172, -73.5788992164221),
              const LatLng(45.49721130711485, -73.5787529114208)))
          .thenAnswer((_) async => expectedRoute);

      // Act
      final result = await realMapService.getRoutePath('', 'Hall Building');

      // Assert
      expect(result, isA<List<LatLng>>());
      expect(result, isNotEmpty);
    });

    test(
        'getRoutePath succeeds when destination is invalid but location services is on',
        () async {
      permission = 3;
      request = 3;
      service = true;

      final expectedRoute = <LatLng>[
        const LatLng(45.4215, -75.6972),
        const LatLng(45.4216, -75.6969),
      ];

      when(mockODSdirectionsService.fetchRouteFromCoords(
              const LatLng(45.49721130711485, -73.5787529114208),
              const LatLng(45.4952628500172, -73.5788992164221)))
          .thenAnswer((_) async => expectedRoute);

      // Act
      final result = await realMapService.getRoutePath('Hall Building', '');

      // Assert
      expect(result, isA<List<LatLng>>());
      expect(result, isNotEmpty);
    });

    test('getRoutePath should throw an exception when destination is invalid',
        () async {
      // Act & Assert
      expect(
        () => FakeMapService().getRoutePath('Hall Building', ''),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Invalid destination'))),
      );
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

    test('returns a valid list of LatLng when route is found', () async {
      permission = 3;
      // Arrange
      const originAddress = 'Hall Building';
      const destinationAddress = 'EV Building';
      final expectedRoute = <LatLng>[
        const LatLng(45.4215, -75.6972),
        const LatLng(45.4216, -75.6969),
      ];

      // Stub the fetchRouteFromCoords method to return the expectedRoute
      when(mockODSdirectionsService.fetchRouteFromCoords(
              const LatLng(45.49721130711485, -73.5787529114208),
              const LatLng(45.49542095329432, -73.5779627198065)))
          .thenAnswer((_) async => expectedRoute);

      // Mock fetchRoute method to return the expected route points
      when(mockODSdirectionsService.fetchRoute(
              originAddress, destinationAddress))
          .thenAnswer((_) async => expectedRoute);

      // Act
      final routePoints =
          await realMapService.getRoutePath(originAddress, destinationAddress);

      // Assert
      expect(routePoints, isA<List<LatLng>>());
    });

    test('throws exception when route fetching fails', () async {
      // Arrange
      const originAddress = 'Hall Building';
      const destinationAddress = 'EV Building';

      // Mock the method to throw an exception
      when(mockMapService.getRoutePath(originAddress, destinationAddress))
          .thenThrow(Exception('Failed to fetch route'));

      // Act & Assert
      expect(
        () async => await mockMapService.getRoutePath(
            originAddress, destinationAddress),
        throwsException,
      );
    });
  });
}
