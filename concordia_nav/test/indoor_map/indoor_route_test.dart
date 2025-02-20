import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('concordia floors', () {
    const testBuilding = const ConcordiaBuilding(45.495397929966266, -73.57770373158148, 
        "EV Building", "1515 Saint-Catherine St W", "Montreal", "QC", "H3G 1S6", "EV", ConcordiaCampus.sgw);
    final floor4 = ConcordiaFloor("4", testBuilding);
    final floor5 = ConcordiaFloor("5", testBuilding);

    test('Can create a floor object and fetch its data', () {
      final testFloor = ConcordiaFloor("2", testBuilding);
      expect(testFloor.building, testBuilding);
      expect(testFloor.floorNumber, "2");
      expect(testFloor.building.abbreviation, "EV");
    });

    test('Can create a connection and fetch its data', () {
      final testFloor = ConcordiaFloor("2", testBuilding);
      final floors = [testFloor, floor4, floor5];
      final connection = Connection(floors, true, "test", 45.5, 15.25);
      expect(connection.name, "test");
      expect(connection.fixedWaitTimeSeconds, 45.5);
      expect(connection.waitTimePerFloorSeconds, 15.25);
    });

    test('can get connection wait time', () {
      final testFloor = ConcordiaFloor("2", testBuilding);
      final floors = [testFloor, floor4, floor5];
      // create test connection
      final connection = Connection(floors, true, "test", 45.5, 15.25);
      expect(connection.getWaitTime(floor4, floor5), 60.75);
    });

    test('getWaitTime returns null when not both floors are in list', () {
      final badFloor = ConcordiaFloor("3", testBuilding);
      final floors = [floor4, floor5];
      // create test connection
      final connection = Connection(floors, true, "test", 45.5, 15.25);
      // should return null as badfloor is not in the list of floors
      expect(connection.getWaitTime(floor4, badFloor), null);
    });
  });

  group('indoor route logic', () {
    const testBuilding = const ConcordiaBuilding(45.495397929966266, -73.57770373158148, 
        "EV Building", "1515 Saint-Catherine St W", "Montreal", "QC", "H3G 1S6", "EV", ConcordiaCampus.sgw);
    final floor6 = ConcordiaFloor("6", testBuilding);
    final testRoom = ConcordiaRoom("6.183", RoomCategory.office, floor6);
    final washroom = ConcordiaRoom("6.608", RoomCategory.washroom, floor6);
    final rooms = [testRoom, washroom];

    test('Can create ConcordiaRoom and fetch its data', () {
      final room = ConcordiaRoom("6.183", RoomCategory.office, floor6);
      expect(room.category, RoomCategory.office);
      expect(room.floor.floorNumber, "6");
      expect(room.roomNumber, "6.183");
    });

    test('firstIndoorPortionToConnection with list of rooms', () {
      var indoorRoute = IndoorRoute(rooms, null, null, null, null, null);
      // since firstIndoorPortionFromConnection is null, return last element of rooms
      expect(indoorRoute.firstPortionLastLocation(), washroom);

      // since secondIndoorPortionToConnection is null, returns null
      expect(indoorRoute.secondPortionFirstLocation(), null);

      final extraRoom = ConcordiaRoom("6.408", RoomCategory.washroom, floor6);
      indoorRoute = IndoorRoute([testRoom], null, [washroom, extraRoom], null, null, null);
      // returns last element of the firstIndoorPortionFromConnection list
      expect(indoorRoute.firstPortionLastLocation(), extraRoom);
    });

    test('secondIndoorPortionToConnection with list of rooms', () {
      // create second portion (room in another  building)
      const building2 = const ConcordiaBuilding(45.497311878717085, -73.5790341072897, 
        "H Building", "1455 De Maisonneuve Blvd. W.", "Montreal", "QC", "H3G 1M8", "H", ConcordiaCampus.sgw);
      final floor4 = ConcordiaFloor("4", building2);
      final classroom = ConcordiaRoom("420", RoomCategory.classroom, floor4);
      final bathroom = ConcordiaRoom("406", RoomCategory.washroom, floor4);
      final rooms2 = [classroom, bathroom];
      final indoorRoute = IndoorRoute(rooms, null, null, rooms2, null, null);
      // returns first element in rooms2 since it is not empty
      expect(indoorRoute.secondPortionFirstLocation(), classroom);
    });
  });
}