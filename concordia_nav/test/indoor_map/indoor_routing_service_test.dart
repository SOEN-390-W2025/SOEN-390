import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/repositories/building_data.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/repositories/calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/services/indoor_routing_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../map/map_viewmodel_test.mocks.dart';
import 'indoor_routing_service_test.mocks.dart';

@GenerateMocks([GeolocatorPlatform, CalendarRepository])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // random position far away from campuses
  var testPosition = Position(
      longitude: 100.0,
      latitude: 100.0,
      timestamp: DateTime.now(),
      accuracy: 30.0,
      altitude: 20.0,
      heading: 120,
      speed: 150.9,
      speedAccuracy: 10.0,
      altitudeAccuracy: 10.0,
      headingAccuracy: 10.0);
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

  late CalendarRepository mockCalendarRepository;
  late MockMapService mockMapService;

  setUp(() {
    mockMapService = MockMapService();
    mockCalendarRepository = MockCalendarRepository();
    permission = 3;
    request = 3;
    service = true;

    testPosition = Position(
        longitude: 100.0,
        latitude: 100.0,
        timestamp: DateTime.now(),
        accuracy: 30.0,
        altitude: 20.0,
        heading: 120,
        speed: 150.9,
        speedAccuracy: 10.0,
        altitudeAccuracy: 10.0,
        headingAccuracy: 10.0);
  });

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(locationChannel, locationHandler);
  });

  group('parseRoomNumber', () {
    test('should return a valid location for valid input EV 123.101', () async {
      expect(IndoorRoutingService.parseRoomNumber("EV 123.101"), isNotNull);
    });
    test('should return a valid location for valid input MB 45', () async {
      expect(IndoorRoutingService.parseRoomNumber("MB 45"), isNotNull);
    });
    test('should return a valid location for valid input H-101', () async {
      expect(IndoorRoutingService.parseRoomNumber("H-101"), isNotNull);
    });
    test('should return a valid location for valid input ABC 101', () async {
      expect(IndoorRoutingService.parseRoomNumber("ABC 101"), isNotNull);
    });
    test('should return a valid location for valid input 123.101', () async {
      expect(IndoorRoutingService.parseRoomNumber("123.101"), isNotNull);
    });
    test('should return a valid location for valid input ED 4.22', () async {
      expect(IndoorRoutingService.parseRoomNumber("ED 4.22"), isNotNull);
    });
    test('should return a valid location for valid input MI 302', () async {
      expect(IndoorRoutingService.parseRoomNumber("MI 302"), isNotNull);
    });
    test('should return a valid location for valid input MTL 501', () async {
      expect(IndoorRoutingService.parseRoomNumber("MTL 501"), isNotNull);
    });
    test('should return a valid location for valid input H6.55', () async {
      expect(IndoorRoutingService.parseRoomNumber("H9.27"), isNotNull);
    });
    test('should return a valid location for valid input H655', () async {
      expect(IndoorRoutingService.parseRoomNumber("H930"), isNotNull);
    });
    test('should return a valid location for valid input H6555', () async {
      expect(IndoorRoutingService.parseRoomNumber("H6555"), isNotNull);
    });
  });

  group('getProximalCalendarEventLocation', () {
    setUp(() {
      mockCalendarRepository = MockCalendarRepository();
      IndoorRoutingService.calendarRepository = mockCalendarRepository;
    });

    test('returns event location if there is an in-progress event', () async {
      // Arrange
      const mockBuilding = BuildingRepository.h;
      var mockEventLocation = ConcordiaFloor("1", BuildingRepository.h);
      final now = DateTime.now();
      final eventsToday = [
        UserCalendarEvent(
          UserCalendar('1', 'Test Calendar'),
          '1',
          'Test Event',
          now.subtract(const Duration(minutes: 5)),
          now.add(const Duration(minutes: 10)),
          'Test Event',
          'H101',
        ),
      ];

      when(mockCalendarRepository.getEventsOnLocalDate(null, 0))
          .thenAnswer((_) async => eventsToday);

      // Act
      final result =
          await IndoorRoutingService.getProximalCalendarEventLocation(
              mockBuilding);

      // Assert
      expect(result, mockEventLocation);
    });

    test('returns null if there are no events today', () async {
      // Arrange
      const mockBuilding = BuildingRepository.h;
      final eventsToday = <UserCalendarEvent>[];

      when(mockCalendarRepository.getEventsOnLocalDate(null, 0))
          .thenAnswer((_) async => eventsToday);

      // Act
      final result =
          await IndoorRoutingService.getProximalCalendarEventLocation(
              mockBuilding);

      // Assert
      expect(result, isNull);
    });
  });

  group('LocationService Tests', () {
    setUp(() {
      IndoorRoutingService.mapService = mockMapService;
      IndoorRoutingService.calendarRepository = mockCalendarRepository;
    });

    test('returns calendar location if geolocation is ConcordiaBuilding',
        () async {
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      testPosition = Position(
          longitude: -73.578,
          latitude: 45.495,
          timestamp: DateTime.now(),
          accuracy: 30.0,
          altitude: 20.0,
          heading: 120,
          speed: 150.9,
          speedAccuracy: 10.0,
          altitudeAccuracy: 10.0,
          headingAccuracy: 10.0);

      // Act
      final result = await IndoorRoutingService.getCurrentClassroom();

      // Assert
      expect(result?.lat, testPosition.latitude);
      expect(result?.lng, testPosition.longitude);
    });

    test('returns calendar location if geolocation is not ConcordiaBuilding',
        () async {
      when(mockMapService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      // Arrange
      const mockCalendarLocation = Location(
        45.4971,
        -73.5788,
        'Room 101',
        null,
        null,
        null,
        null,
      );

      // Act
      final result = await IndoorRoutingService.getCurrentClassroom();

      // Assert
      expect(result?.lat, testPosition.latitude);
      expect(result?.lng, testPosition.longitude);
    });
  });
  group('getIndoorRoute', () {
    // Create BuildingData for test building H
    const buildingH = BuildingRepository.h;
    final floorH1 = ConcordiaFloor("1", buildingH);
    final floorH8 = ConcordiaFloor("8", buildingH);

    // Create BuildingData for test building ER
    const buildingER = BuildingRepository.er;
    final floorER8 = ConcordiaFloor("8", buildingER);

    // Mock stairwell/elevator connection between floors
    final connectionPoints = <String, List<ConcordiaFloorPoint>>{
      "1": [ConcordiaFloorPoint(floorH1, 10, 10)],
      "8": [ConcordiaFloorPoint(floorH8, 10, 10)]
    };

    final connection = Connection(
        [floorH1, floorH8],
        connectionPoints,
        true,
        "Test Elevator",
        5.0, // fixed wait time
        2.0 // wait time per floor
        );

    // Create BuildingData for H building
    final buildingDataH = BuildingData(
        building: buildingH,
        floors: [floorH1, floorH8],
        roomsByFloor: {},
        waypointsByFloor: {
          "1": [
            ConcordiaFloorPoint(floorH1, 0, 0),
            ConcordiaFloorPoint(floorH1, 10, 10)
          ],
          "8": [
            ConcordiaFloorPoint(floorH8, 0, 0),
            ConcordiaFloorPoint(floorH8, 10, 10)
          ]
        },
        waypointNavigability: {
          "1": {
            0: [1],
            1: [0]
          },
          "8": {
            0: [1],
            1: [0]
          }
        },
        connections: [connection],
        outdoorExitPoint: ConcordiaFloorPoint(floorH1, 5, 5));

    test('should return no route if origin and destination are the same', () {
      final origin = ConcordiaFloorPoint(floorH1, 310, 940);
      final destination = origin;

      final route = IndoorRoutingService.getIndoorRoute(
          buildingDataH, origin, destination, true);

      expect(route.firstIndoorPortionToConnection, isNull);
      expect(route.firstIndoorConnection, isNull);
    });

    test(
        'should return route when origin and destination are in different buildings',
        () {
      final origin = ConcordiaFloorPoint(floorH1, 310, 940);
      final destination = ConcordiaFloorPoint(floorER8, 0, 0);

      final route = IndoorRoutingService.getIndoorRoute(
          buildingDataH, origin, destination, true);

      expect(route.firstIndoorPortionToConnection, isNotNull);
      expect(route.firstIndoorConnection, isNull);
      expect(route.secondIndoorPortionToConnection, isNull);
    });

    test('getIndoorRoute with valid destinationExitPoint', () async {
      final origin =
          ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.mb), 0, 0);
      final destination = ConcordiaFloorPoint(
          ConcordiaFloor("1", BuildingRepository.h), 775, 400);

      final route = IndoorRoutingService.getIndoorRoute(
          buildingDataH, origin, destination, true);

      expect(route.firstIndoorPortionToConnection, isNull);
      expect(route.firstIndoorConnection, isNull);
    });

    test(
        'should return route when origin and destination are on different floors',
        () async {
      final origin = ConcordiaFloorPoint(
          ConcordiaFloor("1", BuildingRepository.h), 662, 413);
      final destination = ConcordiaFloorPoint(
          ConcordiaFloor("2", BuildingRepository.h), 488, 548);

      final route = IndoorRoutingService.getIndoorRoute(
          buildingDataH, origin, destination, true);

      expect(route.firstIndoorPortionToConnection, isNotNull);
      expect(route.firstIndoorConnection, isNotNull);
    });
  });

  group("Test Location without channel", () {
    test('returns null when accuracy > 50', () async {
      // position with accuracy > 50
      testPosition = Position(
          longitude: -73.5788992164221,
          latitude: 45.4952628500172,
          timestamp: DateTime.now(),
          accuracy: 70.0,
          altitude: 20.0,
          heading: 120,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0);
      final res = await IndoorRoutingService.getRoundedGeolocation();
      expect(res, null); // should return null
    });
  });

  group("Test Location", () {
    test('return current location when located far from campuses', () async {
      final res = await IndoorRoutingService.getRoundedGeolocation();

      testPosition = Position(
          longitude: 100.0,
          latitude: 100.0,
          timestamp: DateTime.now(),
          accuracy: 30.0,
          altitude: 20.0,
          heading: 120,
          speed: 150.9,
          speedAccuracy: 10.0,
          altitudeAccuracy: 10.0,
          headingAccuracy: 10.0);

      expect(res, isA<Location>());
      expect(res?.lat, 100.0);
      expect(res?.name, "Current Location");
    });

    test('return concordia building located in', () async {
      // position in JMSB
      testPosition = Position(
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
      final res = await IndoorRoutingService.getRoundedGeolocation();
      // should return MB building
      expect(res, isA<ConcordiaBuilding>());
      expect(res?.lat, BuildingRepository.mb.lat);
      expect(res?.name, "John Molson School of Business");
    });

    test('return concordia building located in', () async {
      // position in JMSB
      testPosition = Position(
          longitude: -73.64149708911341,
          latitude: 45.45813042163085,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 20.0,
          heading: 120,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0);
      final res = await IndoorRoutingService.getRoundedGeolocation();
      // should return SP building
      expect(res, isA<ConcordiaBuilding>());
      expect(res?.lng, BuildingRepository.sp.lng);
      expect(res?.name, "Richard J. Renaud Science Complex");
    });
  });

  test('getSvgDimensions with invalid svgPath returns default value', () async {
    final svgDimensions =
        await IndoorRoutingService().getSvgDimensions("somePath");

    expect(svgDimensions, const Size(1024, 1024));
  });

  test('getSvgDimensions with valid svgPath returns file value', () async {
    final svgDimensions = await IndoorRoutingService()
        .getSvgDimensions("assets/maps/indoor/floorplans/CC1.svg");

    expect(svgDimensions, const Size(4096, 1024));
  });
}
