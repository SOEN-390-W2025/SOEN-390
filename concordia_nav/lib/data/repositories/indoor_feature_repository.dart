import '../domain-model/concordia_floor.dart';
import '../domain-model/concordia_floor_point.dart';
import '../domain-model/connection.dart';
import '../domain-model/floor_routable_point.dart';
import 'building_repository.dart';

class IndoorFeatureRepository {
  static Map<String, List<ConcordiaFloor>> floorsByBuilding = {
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

  static Map<String, Map<String, List<FloorRoutablePoint>>> floorPointsByFloor =
      {(BuildingRepository.h.abbreviation): {}};

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
          5),
      Connection([
        floorsByBuilding[BuildingRepository.h.abbreviation]![2],
        floorsByBuilding[BuildingRepository.h.abbreviation]![3],
      ], {
        "1": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![2],
            1570,
            2440),
        "2": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![3], 1730, 1860)
      }, false, "Mezzanine Stairs", 0, 10),
      Connection([
        floorsByBuilding[BuildingRepository.h.abbreviation]![3],
        floorsByBuilding[BuildingRepository.h.abbreviation]![4],
        floorsByBuilding[BuildingRepository.h.abbreviation]![5],
        floorsByBuilding[BuildingRepository.h.abbreviation]![6],
        floorsByBuilding[BuildingRepository.h.abbreviation]![7],
        floorsByBuilding[BuildingRepository.h.abbreviation]![8],
        floorsByBuilding[BuildingRepository.h.abbreviation]![9],
        floorsByBuilding[BuildingRepository.h.abbreviation]![10]
      ], {
        "2": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![3],
            1235,
            1330),
        "8": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![8], 480, 420),
        "9": ConcordiaFloorPoint(
            floorsByBuilding[BuildingRepository.h.abbreviation]![9], 460, 425)
      }, false, "Escalators", 0, 10)
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
