import '../domain-model/concordia_floor.dart';
import '../domain-model/concordia_floor_point.dart';
import '../domain-model/concordia_room.dart';
import '../domain-model/connection.dart';
import '../domain-model/floor_routable_point.dart';
import '../domain-model/room_category.dart';
import 'building_repository.dart';

class IndoorFeatureRepository {
  static final String h = BuildingRepository.h.abbreviation;
  static final List<ConcordiaFloor> hallFloors = floorsByBuilding[h]!;

  // I wouldn't refactor this to come from an assets file, since we sometimes
  // need to refer to the actual floor objects and we don't neccesarily
  // want those references to change. But it could be done.
  static final Map<String, List<ConcordiaFloor>> floorsByBuilding = {
    (BuildingRepository.h.abbreviation): [
      ConcordiaFloor("00", BuildingRepository.h),
      ConcordiaFloor("0", BuildingRepository.h),
      ConcordiaFloor("1", BuildingRepository.h),
      ConcordiaFloor("2", BuildingRepository.h),
      ConcordiaFloor("4", BuildingRepository.h),
      ConcordiaFloor("5", BuildingRepository.h),
      ConcordiaFloor("6", BuildingRepository.h),
      ConcordiaFloor("7", BuildingRepository.h),
      ConcordiaFloor("8", BuildingRepository.h),
      ConcordiaFloor("9", BuildingRepository.h),
      ConcordiaFloor("10", BuildingRepository.h),
      ConcordiaFloor("11", BuildingRepository.h),
      ConcordiaFloor("12", BuildingRepository.h)
    ]
  };

  // FYI if you Find and Replace in this file BuildingRepository.h.abbreviation
  // replaced with "H" (in quotes) it will make it much more readable and won't
  // change the functionality. Hopefully that makes it easier to understand the
  // structure for conversion into an asset file.
  //
  // Also not sure if another format might be more practical than JSON for the
  // catalog, such as YAML (due to its support for references) or even SQLite.

  // This on the other hand, should probably come from an assets file
  static final Map<String, Map<String, List<ConcordiaRoom>>> roomsByFloor = {
    (BuildingRepository.h.abbreviation): {
      "1": [
        ConcordiaRoom("10", RoomCategory.auditorium, hallFloors[2],
            ConcordiaFloorPoint(hallFloors[2], 940, 2210))
      ],
      "6": [
        // Example of a room on a floor without an indoor routing map/support
        ConcordiaRoom("55", RoomCategory.conference, hallFloors[6], null)
      ],
      "8": [
        ConcordiaRoom(
            "20", // Aiman Hanna's room on 8th floor
            RoomCategory.classroom,
            hallFloors[8],
            ConcordiaFloorPoint(hallFloors[8], 775, 400))
      ]
    }
  };

  /// A list of free-space points by floor to use for finding routes
  /// This should probably also come from an assets file
  /// For now, all of these waypoints are assumed to be 'connected' for BFS
  /// purposes. If we encounter routing issues, it might be neccesary to
  /// strictly define which waypoints are connected.
  static Map<String, Map<String, List<FloorRoutablePoint>>> waypointsByFloor = {
    (BuildingRepository.h.abbreviation): {
      "1": [
        ConcordiaFloorPoint(hallFloors[2], 1400, 2030),
        ConcordiaFloorPoint(hallFloors[2], 1400, 2220),
        ConcordiaFloorPoint(hallFloors[2], 1400, 2430),
        ConcordiaFloorPoint(hallFloors[2], 885, 2430),
      ],
      "8": [
        ConcordiaFloorPoint(hallFloors[8], 175, 210),
        ConcordiaFloorPoint(hallFloors[8], 175, 400),
        ConcordiaFloorPoint(hallFloors[8], 175, 600),
        ConcordiaFloorPoint(hallFloors[8], 175, 790),
        ConcordiaFloorPoint(hallFloors[8], 340, 210),
        ConcordiaFloorPoint(hallFloors[8], 340, 400),

        /// 340, 600 is not free space
        ConcordiaFloorPoint(hallFloors[8], 340, 790),
        ConcordiaFloorPoint(hallFloors[8], 550, 210),
        ConcordiaFloorPoint(hallFloors[8], 550, 400),
        ConcordiaFloorPoint(hallFloors[8], 550, 600),
        ConcordiaFloorPoint(hallFloors[8], 550, 790),
        ConcordiaFloorPoint(hallFloors[8], 840, 210),
        ConcordiaFloorPoint(hallFloors[8], 840, 400),
        ConcordiaFloorPoint(hallFloors[8], 840, 600),
        ConcordiaFloorPoint(hallFloors[8], 840, 790),
        ConcordiaFloorPoint(hallFloors[8], 550, 300),
        ConcordiaFloorPoint(hallFloors[8], 550, 500),
        ConcordiaFloorPoint(hallFloors[8], 550, 700),
      ]
    }
  };

  // For each floor of each building, this contains a list of waypoint
  // navigability maps. This is one-way navigation from the key to the values.
  // For each indexed waypoint above (starting from zero), the list should
  // contain the indexes of waypoints reachable from that waypoint.
  static Map<String, Map<String, Map<int, List<int>>>>
      waypointNavigabilityGroupsByFloor = {
    (BuildingRepository.h.abbreviation): {
      "1": {
        0: [1, 2, 3],
        1: [0, 2, 3],
        2: [0, 1, 3],
        3: [0, 1, 2]
      },
      "8": {
        0: [1, 4],
        1: [0, 2, 5],
        2: [1, 3],
        3: [2, 6],
        4: [0, 7],
        5: [1, 8],
        6: [3, 10],
        7: [4, 11, 15],
        8: [5, 15, 16],
        9: [16, 17],
        10: [6, 14, 17],
        11: [7, 12],
        12: [11, 13],
        13: [12, 14],
        14: [13, 10],
        // These were the points added later
        15: [7, 8],
        16: [8, 9],
        17: [9, 10]
      }
    }
  };

  static Map<String, List<Connection>> connectionsByBuilding = {
    (BuildingRepository.h.abbreviation): [
      Connection(
          floorsByBuilding[BuildingRepository.h.abbreviation]!,
          // TODO: these references to floors by integer subscript should be
          // unit-tested to ensure their meaning doesn't change with future
          // updates to the list of floors
          {
            "1": ConcordiaFloorPoint(hallFloors[2], 1730, 2111),
            "2": ConcordiaFloorPoint(hallFloors[3], 1565, 1960),
            "8": ConcordiaFloorPoint(hallFloors[8], 355, 350),
            "9": ConcordiaFloorPoint(hallFloors[9], 355, 355)
          },
          true,
          "Main Elevators",
          60,
          8),
      Connection([
        hallFloors[2],
        hallFloors[3],
        hallFloors[4],
        hallFloors[5],
        hallFloors[6],
        hallFloors[7],
        hallFloors[8],
        hallFloors[9],
        hallFloors[10]
      ], {
        "1": ConcordiaFloorPoint(hallFloors[2], 1570, 2440),
        "2": ConcordiaFloorPoint(hallFloors[3], 1235, 1330),
        "8": ConcordiaFloorPoint(hallFloors[8], 480, 420),
        "9": ConcordiaFloorPoint(hallFloors[9], 460, 425)
      }, false, "Escalators", 0, 15)
    ]
  };

  /// One exit per building for simplicity. Key is building abberivation. For
  /// best cohesion with the outdoor routing portion, use the exit that
  /// corresponds to the municipal street address for the building (eg. for Hall
  /// the exit is the one on de Maisonneuve))
  static Map<String, ConcordiaFloorPoint> outdoorExitPointsByBuilding = {
    (BuildingRepository.h.abbreviation):
        ConcordiaFloorPoint(hallFloors[2], 850, 2640)
  };
}
