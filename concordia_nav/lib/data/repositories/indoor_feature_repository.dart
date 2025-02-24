import '../domain-model/concordia_floor.dart';
import '../domain-model/concordia_floor_point.dart';
import '../domain-model/concordia_room.dart';
import '../domain-model/connection.dart';
import '../domain-model/floor_routable_point.dart';
import '../domain-model/room_category.dart';
import 'building_repository.dart';

class IndoorFeatureRepository {
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

  // This on the other hand, should probably come from an assets file
  static final Map<String, Map<String, List<ConcordiaRoom>>> roomsByFloor = {
    (BuildingRepository.h.abbreviation): {
      "1": [
        ConcordiaRoom(
            "10",
            RoomCategory.auditorium,
            floorsByBuilding[BuildingRepository.h.abbreviation]![2],
            ConcordiaFloorPoint(
                floorsByBuilding[BuildingRepository.h.abbreviation]![2],
                940,
                2210))
      ],
      "6": [
        // Example of a room on a floor without an indoor routing map/support
        ConcordiaRoom("55", RoomCategory.conference,
            floorsByBuilding[BuildingRepository.h.abbreviation]![6], null)
      ],
      "8": [
        ConcordiaRoom(
            "20", // Aiman Hanna's room on 8th floor
            RoomCategory.classroom,
            floorsByBuilding[BuildingRepository.h.abbreviation]![8],
            ConcordiaFloorPoint(
                floorsByBuilding[BuildingRepository.h.abbreviation]![8],
                775,
                400))
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
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![2],
            1400,
            2030),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![2],
            1400,
            2220),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![2],
            1400,
            2430),
      ],
      "8": [
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 175, 210),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 175, 400),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 175, 600),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 175, 790),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 340, 210),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 340, 400),

        /// 340, 600 is not free space
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 340, 790),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 550, 210),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 550, 300),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 550, 400),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 550, 600),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 550, 790),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 700, 210),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 840, 210),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 840, 400),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 840, 600),
        ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 840, 790),
      ]
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
            "1": ConcordiaFloorPoint(
                floorsByBuilding[BuildingRepository.h.abbreviation]![2],
                1730,
                2111),
            "2": ConcordiaFloorPoint(
                floorsByBuilding[BuildingRepository.h.abbreviation]![3],
                1565,
                1960),
            "8": ConcordiaFloorPoint(
                floorsByBuilding[BuildingRepository.h.abbreviation]![8],
                355,
                350),
            "9": ConcordiaFloorPoint(
                floorsByBuilding[BuildingRepository.h.abbreviation]![9],
                355,
                355)
          },
          true,
          "Main Elevators",
          60,
          8),
      Connection([
        floorsByBuilding[BuildingRepository.h.abbreviation]![2],
        floorsByBuilding[BuildingRepository.h.abbreviation]![3],
        floorsByBuilding[BuildingRepository.h.abbreviation]![4],
        floorsByBuilding[BuildingRepository.h.abbreviation]![5],
        floorsByBuilding[BuildingRepository.h.abbreviation]![6],
        floorsByBuilding[BuildingRepository.h.abbreviation]![7],
        floorsByBuilding[BuildingRepository.h.abbreviation]![8],
        floorsByBuilding[BuildingRepository.h.abbreviation]![9],
        floorsByBuilding[BuildingRepository.h.abbreviation]![10]
      ], {
        "1": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![2],
            1570,
            2440),
        "2": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![3],
            1235,
            1330),
        "8": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 480, 420),
        "9": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![9], 460, 425)
      }, false, "Escalators", 0, 15)
    ]
  };

  /// One exit per building for simplicity. Key is building abberivation. For
  /// best cohesion with the outdoor routing portion, use the exit that
  /// corresponds to the municipal street address for the building (eg. for Hall
  /// the exit is the one on de Maisonneuve))
  static Map<String, ConcordiaFloorPoint> outdoorExitPointsByBuilding = {
    (BuildingRepository.h.abbreviation): ConcordiaFloorPoint(
        floorsByBuilding[BuildingRepository.h.abbreviation]![2], 850, 2640)
  };
}
