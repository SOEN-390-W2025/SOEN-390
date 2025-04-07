import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/repositories/indoor_feature_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndoorRoute Tests', () {
    test('Distance between points should be calculated correctly', () {
      final floor = ConcordiaFloor('1', BuildingRepository.h);
      final point1 = ConcordiaFloorPoint(floor, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor, 3.0, 4.0);

      expect(IndoorRoute.getDistanceBetweenPoints(point1, point2),
          closeTo(5.0, 0.001));
    });

    test('Travel time should be computed correctly', () {
      final floor = ConcordiaFloor('1', BuildingRepository.h, 2.0);
      final points = [
        ConcordiaFloorPoint(floor, 0.0, 0.0),
        ConcordiaFloorPoint(floor, 3.0, 4.0),
      ];

      final route = IndoorRoute(
          floor.building, points, null, null, null, null, null, null);
      expect(route.getFloorRoutablePointListTravelTime(points),
          closeTo(2.5, 0.001));
    });

    test('Indoor travel time with connection should be computed correctly', () {
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('2', building, 1.0);
      final point1 = ConcordiaFloorPoint(floor1, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor1, 3.0, 4.0);
      final point3 = ConcordiaFloorPoint(floor2, 6.0, 8.0);

      final connection =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);

      final route = IndoorRoute(building, [point1, point2], connection,
          [point3], null, null, null, null);

      expect(route.getIndoorTravelTimeSeconds(), closeTo(12.0, 1));
    });

    test(
        'Indoor travel time with connection and secondIndoorPortionToConnection should be computed correctly',
        () {
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('2', building, 1.0);
      final floor3 = ConcordiaFloor('3', building, 1.0);
      final point1 = ConcordiaFloorPoint(floor1, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor1, 3.0, 4.0);
      final point3 = ConcordiaFloorPoint(floor2, 6.0, 8.0);
      final point4 = ConcordiaFloorPoint(floor3, 1.0, 2.0);

      final connection1 =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);
      final connection2 =
          Connection([floor2, floor3], {}, true, 'Stairs', 4.0, 2.5);

      final route = IndoorRoute(
        building,
        [point1, point2],
        connection1,
        [point3],
        building,
        [point4],
        connection2,
        null,
      );

      expect(route.getIndoorTravelTimeSeconds(), closeTo(13.0, 1));
    });
  });

  group('IndoorFeatureRepository Tests', () {
    test('hashCode should be consistent with abbreviation', () {
      // Create two instances with the same abbreviation
      const building1 = ConcordiaBuilding(
        45.4954,
        73.5787,
        'Building A',
        '123 Main St',
        'Montreal',
        'QC',
        'H3G 1M8',
        'B1',
        ConcordiaCampus.sgw,
      );
      const building2 = ConcordiaBuilding(
        45.4954,
        73.5787,
        'Building A',
        '123 Main St',
        'Montreal',
        'QC',
        'H3G 1M8',
        'B1',
        ConcordiaCampus.sgw,
      );

      // Check that both buildings have the same hashCode because their abbreviation is the same
      expect(building1.hashCode, equals(building2.hashCode));

      // Create a different building with a different abbreviation
      const building3 = ConcordiaBuilding(
        45.4954,
        73.5787,
        'Building B',
        '456 Elm St',
        'Montreal',
        'QC',
        'H3G 2N1',
        'B2',
        ConcordiaCampus.sgw,
      );

      // Check that the hashCode is different for buildings with different abbreviations
      expect(building1.hashCode, isNot(equals(building3.hashCode)));
    });

    test('floorsByBuilding should contain correct floors for Building H', () {
      // Arrange
      final buildingAbbreviation = BuildingRepository.h.abbreviation;
      final floors =
          IndoorFeatureRepository.floorsByBuilding[buildingAbbreviation];

      // Assert
      expect(floors, isNotNull);
      expect(floors?.length, equals(13));
    });

    test('roomsByFloor should contain correct rooms for Building H, Floor 1',
        () {
      // Arrange
      final buildingAbbreviation = BuildingRepository.h.abbreviation;
      final roomsOnFloor1 =
          IndoorFeatureRepository.roomsByFloor[buildingAbbreviation]?["1"];

      // Assert
      expect(roomsOnFloor1, isNotNull);
      expect(roomsOnFloor1?.length, equals(1));
      expect(roomsOnFloor1?[0].roomNumber, equals("10"));
      expect(roomsOnFloor1?[0].category, equals(RoomCategory.auditorium));
    });

    test(
        'waypointsByFloor should contain correct waypoints for Building H, Floor 1',
        () {
      // Arrange
      final buildingAbbreviation = BuildingRepository.h.abbreviation;
      final waypointsOnFloor1 =
          IndoorFeatureRepository.waypointsByFloor[buildingAbbreviation]?["1"];

      // Assert
      expect(waypointsOnFloor1, isNotNull);
      expect(waypointsOnFloor1?.length, equals(4));
    });

    test(
        'waypointNavigabilityGroupsByFloor should contain correct navigability for Building H, Floor 1',
        () {
      // Arrange
      final buildingAbbreviation = BuildingRepository.h.abbreviation;
      final navigabilityGroupsOnFloor1 = IndoorFeatureRepository
          .waypointNavigabilityGroupsByFloor[buildingAbbreviation]?["1"];

      // Assert
      expect(navigabilityGroupsOnFloor1, isNotNull);
    });

    test(
        'connectionsByBuilding should contain correct connections for Building H',
        () {
      // Arrange
      final buildingAbbreviation = BuildingRepository.h.abbreviation;
      final connections =
          IndoorFeatureRepository.connectionsByBuilding[buildingAbbreviation];

      // Assert
      expect(connections, isNotNull);
      expect(connections?.length, equals(2));

      // First connection assertions
      final firstConnection = connections?[0];
      expect(firstConnection?.name, equals("Main Elevators"));
      expect(firstConnection?.isAccessible, equals(true));
      expect(firstConnection?.fixedWaitTimeSeconds, equals(60));

      // Second connection assertions
      final secondConnection = connections?[1];
      expect(secondConnection?.name, equals("Escalators"));
      expect(secondConnection?.isAccessible, equals(false));
      expect(secondConnection?.waitTimePerFloorSeconds, equals(15));
    });

    test(
        'outdoorExitPointsByBuilding should contain correct outdoor exit for Building H',
        () {
      // Arrange
      final buildingAbbreviation = BuildingRepository.h.abbreviation;
      final outdoorExitPoint = IndoorFeatureRepository
          .outdoorExitPointsByBuilding[buildingAbbreviation];

      // Assert
      expect(outdoorExitPoint, isNotNull);
    });
  });

  test('IndoorRoute constructor initializes properties correctly', () {
    // Arrange
    final ConcordiaFloor floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
    final ConcordiaFloor floor2 = ConcordiaFloor("2", BuildingRepository.h, 1);

    final floorPoint1 = ConcordiaFloorPoint(floor1, 10.0, 20.0);
    final floorPoint2 = ConcordiaFloorPoint(floor1, 15.0, 25.0);
    final floorPoint3 = ConcordiaFloorPoint(floor2, 12.0, 22.0);

    final connection = Connection(
      [floor1, floor2],
      {
        '1': [floorPoint1], // Wrapped in a list
        '2': [floorPoint2], // Wrapped in a list
        '3': [floorPoint3] // Wrapped in a list
      },
      true,
      'Elevator Connection',
      10.0,
      5.0,
    );

    // Create the IndoorRoute
    final indoorRoute = IndoorRoute(
      BuildingRepository.h,
      [floorPoint1, floorPoint2],
      connection,
      [floorPoint2],
      BuildingRepository.h,
      [floorPoint3],
      connection,
      [floorPoint3],
    );

    // Act & Assert
    // Test for firstBuilding initialization
    expect(indoorRoute.firstBuilding, equals(BuildingRepository.h));

    // Test for secondBuilding initialization
    expect(indoorRoute.secondBuilding, equals(BuildingRepository.h));

    // Test for firstIndoorPortionToConnection initialization
    expect(indoorRoute.firstIndoorPortionToConnection,
        equals([floorPoint1, floorPoint2]));

    // Test for firstIndoorConnection initialization
    expect(indoorRoute.firstIndoorConnection, equals(connection));

    // Test for firstIndoorPortionFromConnection initialization
    expect(indoorRoute.firstIndoorPortionFromConnection, equals([floorPoint2]));

    // Test for secondIndoorPortionToConnection initialization
    expect(indoorRoute.secondIndoorPortionToConnection, equals([floorPoint3]));

    // Test for secondIndoorConnection initialization
    expect(indoorRoute.secondIndoorConnection, equals(connection));

    // Test for secondIndoorPortionFromConnection initialization
    expect(
        indoorRoute.secondIndoorPortionFromConnection, equals([floorPoint3]));
  });

  test('Connection constructor initializes properties correctly', () {
    // Arrange
    final floor1 = ConcordiaFloor("1", BuildingRepository.h);
    final floor2 = ConcordiaFloor("2", BuildingRepository.h);

// Update this map to wrap each point in a list
    final floorPoints = {
      '1': [ConcordiaFloorPoint(floor1, 10.5, 20.5)], // Wrap in list []
      '2': [ConcordiaFloorPoint(floor2, 15.5, 25.5)], // Wrap in list []
    };

    const bool isAccessible = true;
    const String name = 'Elevator Connection';
    const double fixedWaitTimeSeconds = 10.0;
    const double waitTimePerFloorSeconds = 5.0;

    // Act
    final connection = Connection(
      [floor1, floor2],
      floorPoints,
      isAccessible,
      name,
      fixedWaitTimeSeconds,
      waitTimePerFloorSeconds,
    );

    // Assert
    expect(connection.floors, equals([floor1, floor2]));
    expect(connection.floorPoints, equals(floorPoints));
    expect(connection.isAccessible, isTrue);
    expect(connection.name, equals(name));
    expect(connection.fixedWaitTimeSeconds, equals(fixedWaitTimeSeconds));
    expect(connection.waitTimePerFloorSeconds, equals(waitTimePerFloorSeconds));
  });

  test('getWaitTime returns correct wait time for connected floors', () {
    // Arrange
    final floor1 = ConcordiaFloor("1", BuildingRepository.h);
    final floor2 = ConcordiaFloor("2", BuildingRepository.h);
    final floor3 = ConcordiaFloor("3", BuildingRepository.h);
    final floor4 = ConcordiaFloor("4", BuildingRepository.h);

    final floorPoints = {
      '1': [ConcordiaFloorPoint(floor1, 10.5, 20.5)],
      '2': [ConcordiaFloorPoint(floor2, 15.5, 25.5)],
      '3': [ConcordiaFloorPoint(floor3, 20.5, 30.5)],
    };

    const double fixedWaitTimeSeconds = 10.0;
    const double waitTimePerFloorSeconds = 5.0;

    final connection = Connection(
      [floor1, floor2, floor3],
      floorPoints,
      true,
      'Elevator Connection',
      fixedWaitTimeSeconds,
      waitTimePerFloorSeconds,
    );

// Act & Assert
// Wait time between Floor 1 and Floor 2 should be 10 + (5 * 1) = 15 seconds
    expect(connection.getWaitTime(floor1, floor2), equals(15.0));

    // Wait time between Floor 2 and Floor 3 should be 10 + (5 * 1) = 15 seconds
    expect(connection.getWaitTime(floor2, floor3), equals(15.0));

    // Floors that are not in the same connection (like Floor 1 and Floor 3) should return null
    expect(connection.getWaitTime(floor1, floor4), isNull);
  });

  group('ConcordiaRoom tests', () {
    test('ConcordiaRoom constructor initializes properties correctly', () {
      // Arrange
      final mockFloor = ConcordiaFloor("1", BuildingRepository.h);

      final entrance = ConcordiaFloorPoint(mockFloor, 10.5, 20.5);
      const String roomNumber = 'EV9.123';
      const RoomCategory category = RoomCategory.auditorium;

      // Act
      final room = ConcordiaRoom(roomNumber, category, mockFloor, entrance);

      // Assert
      expect(room.roomNumber, equals(roomNumber));
      expect(room.category, equals(category));
      expect(room.floor, equals(mockFloor));
      expect(room.entrancePoint, equals(entrance));

      // Verify superclass properties
      expect(room.lat, equals(mockFloor.lat));
      expect(room.lng, equals(mockFloor.lng));
      expect(room.name, equals(mockFloor.name));
      expect(room.streetAddress, equals(mockFloor.streetAddress));
      expect(room.city, equals(mockFloor.city));
      expect(room.province, equals(mockFloor.province));
      expect(room.postalCode, equals(mockFloor.postalCode));
    });

    test('hashCode gets the hashcode of a ConcordiaRoom', () {
      // Arrange
      final mockFloor = ConcordiaFloor("1", BuildingRepository.h);

      final entrance = ConcordiaFloorPoint(mockFloor, 10.5, 20.5);
      const String roomNumber = 'EV9.123';
      const RoomCategory category = RoomCategory.auditorium;
      final room = ConcordiaRoom(roomNumber, category, mockFloor, entrance);

      // Act
      final hashCode = room.hashCode;

      // Assert
      expect(hashCode, isA<int>());
    });

    test('check override for == operator works', () {
      // Arrange
      final mockFloor = ConcordiaFloor("1", BuildingRepository.h);

      final entrance = ConcordiaFloorPoint(mockFloor, 10.5, 20.5);
      const String roomNumber = 'EV9.123';
      const RoomCategory category = RoomCategory.auditorium;
      final room = ConcordiaRoom(roomNumber, category, mockFloor, entrance);
      final room2 = ConcordiaRoom(
          roomNumber, RoomCategory.classroom, mockFloor, entrance);
      final room3 = ConcordiaRoom('EV9.125', category, mockFloor, entrance);

      expect(room == room, true);
      expect(room == room2, true);
      expect(room == room3, false);
      // ignore: unrelated_type_equality_checks
      expect(room == entrance, false);
    });
  });

  test('ConcordiaFloorPoint constructor initializes properties correctly', () {
    // Arrange
    final mockFloor = ConcordiaFloor("1", BuildingRepository.h);
    const double x = 10.5;
    const double y = 20.5;

    // Act
    final point = ConcordiaFloorPoint(mockFloor, x, y);

    // Assert
    expect(point.floor, equals(mockFloor));
    expect(point.positionX, equals(x));
    expect(point.positionY, equals(y));
  });

  test(
      'getDistanceBetweenPoints should calculate the correct distance between two points',
      () {
    final point1 =
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0);
    final point2 =
        ConcordiaFloorPoint(ConcordiaFloor("2", BuildingRepository.h), 3, 4);

    final result = IndoorRoute.getDistanceBetweenPoints(point1, point2);

    expect(result, 5.0); // Pythagorean theorem (3^2 + 4^2 = 5^2)
  });

  test('should return zero distance for the same points', () {
    final point1 =
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0);
    final point2 =
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0);

    final result = IndoorRoute.getDistanceBetweenPoints(point1, point2);

    expect(result, 0.0); // Same point, so distance is zero
  });

  test(
      'getFloorRoutablePointListTravelTime should calculate the correct travel time between points',
      () {
    final point1 =
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0);
    final point2 =
        ConcordiaFloorPoint(ConcordiaFloor("2", BuildingRepository.h), 3, 4);
    final points = [point1, point2];

    final result = IndoorRoute(
            BuildingRepository.h, null, null, null, null, null, null, null)
        .getFloorRoutablePointListTravelTime(points);

    expect(result, 5.0);
  });

  test(
      'getFloorRoutablePointListTravelTime should return 0 when only one point in list',
      () {
    final point1 =
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0);
    final points = [point1];

    final result = IndoorRoute(
            BuildingRepository.h, null, null, null, null, null, null, null)
        .getFloorRoutablePointListTravelTime(points);

    expect(result, 0.0); // only one point so no travel time
  });

  test('getIndoorTravelTimeSeconds returns travel time sum in seconds', () {
    // Arrange
    final ConcordiaFloor floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
    final ConcordiaFloor floor2 = ConcordiaFloor("2", BuildingRepository.h, 1);

    final floorPoint1 = ConcordiaFloorPoint(floor1, 10.0, 20.0);
    final floorPoint2 = ConcordiaFloorPoint(floor1, 15.0, 25.0);
    final floorPoint3 = ConcordiaFloorPoint(floor2, 12.0, 22.0);

    final connection = Connection(
      [floor1, floor2],
      {
        '1': [floorPoint1], // Wrapped in a list
        '2': [floorPoint2], // Wrapped in a list
        '3': [floorPoint3] // Wrapped in a list
      },
      true,
      'Elevator Connection',
      10.0,
      5.0,
    );

    // Create the IndoorRoute
    final indoorRoute = IndoorRoute(
      BuildingRepository.h,
      [floorPoint1, floorPoint2],
      connection,
      [floorPoint2],
      BuildingRepository.h,
      [floorPoint3],
      connection,
      [floorPoint3],
    );

    // Act
    final sum = indoorRoute.getIndoorTravelTimeSeconds();

    // Assert
    expect(sum, 7.0710678118654755);
  });

  test('getIndoorTravelTimeSeconds without secondIndoorPortionFromConnection',
      () {
    // Arrange
    final ConcordiaFloor floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
    final ConcordiaFloor floor2 = ConcordiaFloor("2", BuildingRepository.h, 1);

    final floorPoint1 = ConcordiaFloorPoint(floor1, 10.0, 20.0);
    final floorPoint2 = ConcordiaFloorPoint(floor1, 15.0, 25.0);
    final floorPoint3 = ConcordiaFloorPoint(floor2, 12.0, 22.0);

    final connection = Connection(
      [floor1, floor2],
      {
        '1': [floorPoint1], // Wrapped in a list
        '2': [floorPoint2], // Wrapped in a list
        '3': [floorPoint3] // Wrapped in a list
      },
      true,
      'Elevator Connection',
      10.0,
      5.0,
    );

    // Create the IndoorRoute
    final indoorRoute = IndoorRoute(
      BuildingRepository.h,
      [floorPoint1, floorPoint2],
      connection,
      [floorPoint2],
      BuildingRepository.h,
      [floorPoint3],
      connection,
      null,
    );

    // Act
    final sum = indoorRoute.getIndoorTravelTimeSeconds();

    // Assert
    expect(sum, 7.0710678118654755);
  });

  test('getIndoorTravelTimeSeconds without secondIndoorPortionToConnection',
      () {
    // Arrange
    final ConcordiaFloor floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
    final ConcordiaFloor floor2 = ConcordiaFloor("2", BuildingRepository.h, 1);

    final floorPoint1 = ConcordiaFloorPoint(floor1, 10.0, 20.0);
    final floorPoint2 = ConcordiaFloorPoint(floor1, 15.0, 25.0);
    final floorPoint3 = ConcordiaFloorPoint(floor2, 12.0, 22.0);

    final connection = Connection(
      [floor1, floor2],
      {
        '1': [floorPoint1], // Wrapped in a list
        '2': [floorPoint2], // Wrapped in a list
        '3': [floorPoint3] // Wrapped in a list
      },
      true,
      'Elevator Connection',
      10.0,
      5.0,
    );

    // Create the IndoorRoute
    final indoorRoute = IndoorRoute(
      BuildingRepository.h,
      [floorPoint1, floorPoint2],
      connection,
      [floorPoint2, floorPoint3],
      BuildingRepository.h,
      null,
      connection,
      null,
    );

    // Act
    final sum = indoorRoute.getIndoorTravelTimeSeconds();

    // Assert
    expect(sum, 11.31370849898476);
  });

  test('getIndoorTravelTimeSeconds without firstIndoorPortionFromConnection',
      () {
    // Arrange
    final ConcordiaFloor floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
    final ConcordiaFloor floor2 = ConcordiaFloor("2", BuildingRepository.h, 1);

    final floorPoint1 = ConcordiaFloorPoint(floor1, 10.0, 20.0);
    final floorPoint2 = ConcordiaFloorPoint(floor1, 15.0, 25.0);
    final floorPoint3 = ConcordiaFloorPoint(floor2, 12.0, 22.0);

    final connection = Connection(
      [floor1, floor2],
      {
        '1': [floorPoint1], // Wrapped in a list
        '2': [floorPoint2], // Wrapped in a list
        '3': [floorPoint3] // Wrapped in a list
      },
      true,
      'Elevator Connection',
      10.0,
      5.0,
    );

    // Create the IndoorRoute
    final indoorRoute = IndoorRoute(
      BuildingRepository.h,
      [floorPoint1, floorPoint2],
      connection,
      null,
      BuildingRepository.h,
      [floorPoint2, floorPoint3],
      connection,
      [floorPoint3],
    );

    // Act
    final sum = indoorRoute.getIndoorTravelTimeSeconds();

    // Assert
    expect(sum, 26.31370849898476);
  });

  test('getIndoorTravelTimeSeconds without firstIndoorPortionToConnection', () {
    // Arrange
    final ConcordiaFloor floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
    final ConcordiaFloor floor2 = ConcordiaFloor("2", BuildingRepository.h, 1);

    final floorPoint1 = ConcordiaFloorPoint(floor1, 10.0, 20.0);
    final floorPoint2 = ConcordiaFloorPoint(floor1, 15.0, 25.0);
    final floorPoint3 = ConcordiaFloorPoint(floor2, 12.0, 22.0);

    final connection = Connection(
      [floor1, floor2],
      {
        '1': [floorPoint1], // Wrapped in a list
        '2': [floorPoint2], // Wrapped in a list
        '3': [floorPoint3] // Wrapped in a list
      },
      true,
      'Elevator Connection',
      10.0,
      5.0,
    );

    // Create the IndoorRoute
    final indoorRoute = IndoorRoute(
      BuildingRepository.h,
      null,
      connection,
      [floorPoint1, floorPoint2],
      BuildingRepository.h,
      [floorPoint2, floorPoint3],
      connection,
      [floorPoint3],
    );

    // Act
    final sum = indoorRoute.getIndoorTravelTimeSeconds();

    // Assert
    expect(sum, 19.242640687119284);
  });

  group('concordia floors', () {
    const testBuilding = const ConcordiaBuilding(
        45.495397929966266,
        -73.57770373158148,
        "EV Building",
        "1515 Saint-Catherine St W",
        "Montreal",
        "QC",
        "H3G 1S6",
        "EV",
        ConcordiaCampus.sgw);
    ConcordiaFloor("4", testBuilding);
    ConcordiaFloor("5", testBuilding);

    test('Can create a floor object and fetch its data', () {
      final testFloor = ConcordiaFloor("2", testBuilding);
      expect(testFloor.building, testBuilding);
      expect(testFloor.floorNumber, "2");
      expect(testFloor.building.abbreviation, "EV");
    });
  });

  // test('Can create a connection and fetch its data', () {
  //   final testFloor = ConcordiaFloor("2", testBuilding);
  //   final floors = [testFloor, floor4, floor5];
  //   final connection = Connection(floors, true, "test", 45.5, 15.25);
  //   expect(connection.name, "test");
  //   expect(connection.fixedWaitTimeSeconds, 45.5);
  //   expect(connection.waitTimePerFloorSeconds, 15.25);
  // });

  // test('can get connection wait time', () {
  //   final testFloor = ConcordiaFloor("2", testBuilding);
  //   final floors = [testFloor, floor4, floor5];
  //   // create test connection
  //   final connection = Connection(floors, true, "test", 45.5, 15.25);
  //   expect(connection.getWaitTime(floor4, floor5), 60.75);
  // });

  //   test('getWaitTime returns null when not both floors are in list', () {
  //     final badFloor = ConcordiaFloor("3", testBuilding);
  //     final floors = [floor4, floor5];
  //     // create test connection
  //     final connection = Connection(floors, true, "test", 45.5, 15.25);
  //     // should return null as badfloor is not in the list of floors
  //     expect(connection.getWaitTime(floor4, badFloor), null);
  //   });
  // });

  // group('indoor route logic', () {
  //   const testBuilding = const ConcordiaBuilding(
  //       45.495397929966266,
  //       -73.57770373158148,
  //       "EV Building",
  //       "1515 Saint-Catherine St W",
  //       "Montreal",
  //       "QC",
  //       "H3G 1S6",
  //       "EV",
  //       ConcordiaCampus.sgw);
  //   final floor6 = ConcordiaFloor("6", testBuilding);
  //   final testRoom = ConcordiaRoom("6.183", RoomCategory.office, floor6);
  //   final washroom = ConcordiaRoom("6.608", RoomCategory.washroom, floor6);
  //   final rooms = [testRoom, washroom];

  //   test('Can create ConcordiaRoom and fetch its data', () {
  //     final room = ConcordiaRoom("6.183", RoomCategory.office, floor6);
  //     expect(room.category, RoomCategory.office);
  //     expect(room.floor.floorNumber, "6");
  //     expect(room.roomNumber, "6.183");
  //   });

  //   test('firstIndoorPortionToConnection with list of rooms', () {
  //     var indoorRoute = IndoorRoute(rooms, null, null, null, null, null);
  //     // since firstIndoorPortionFromConnection is null, return last element of rooms
  //     expect(indoorRoute.firstPortionLastLocation(), washroom);

  //     // since secondIndoorPortionToConnection is null, returns null
  //     expect(indoorRoute.secondPortionFirstLocation(), null);

  //     final extraRoom = ConcordiaRoom("6.408", RoomCategory.washroom, floor6);
  //     indoorRoute = IndoorRoute(
  //         [testRoom], null, [washroom, extraRoom], null, null, null);
  //     // returns last element of the firstIndoorPortionFromConnection list
  //     expect(indoorRoute.firstPortionLastLocation(), extraRoom);
  //   });

  //   test('secondIndoorPortionToConnection with list of rooms', () {
  //     // create second portion (room in another  building)
  //     const building2 = const ConcordiaBuilding(
  //         45.497311878717085,
  //         -73.5790341072897,
  //         "H Building",
  //         "1455 De Maisonneuve Blvd. W.",
  //         "Montreal",
  //         "QC",
  //         "H3G 1M8",
  //         "H",
  //         ConcordiaCampus.sgw);
  //     final floor4 = ConcordiaFloor("4", building2);
  //     final classroom = ConcordiaRoom("420", RoomCategory.classroom, floor4);
  //     final bathroom = ConcordiaRoom("406", RoomCategory.washroom, floor4);
  //     final rooms2 = [classroom, bathroom];
  //     final indoorRoute = IndoorRoute(rooms, null, null, rooms2, null, null);
  //     // returns first element in rooms2 since it is not empty
  //     expect(indoorRoute.secondPortionFirstLocation(), classroom);
  //   });
  // });
}
