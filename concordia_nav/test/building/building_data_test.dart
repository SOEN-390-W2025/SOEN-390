import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/repositories/building_data.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/repositories/indoor_feature_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Building data tests', () {
    test('Can create BuildingData object', () {
      // Arrange
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor("1", BuildingRepository.h, 1);
      final floor8 = ConcordiaFloor("8", BuildingRepository.h, 1);
      final floors = [floor1, floor8];
      final roomsByFloor = IndoorFeatureRepository.roomsByFloor[building.abbreviation];
      final waypointsByFloor = {
          "1": [
            ConcordiaFloorPoint(floors[0], 1400, 2030),
            ConcordiaFloorPoint(floors[0], 1400, 2220),
            ConcordiaFloorPoint(floors[0], 1400, 2430),
            ConcordiaFloorPoint(floors[0], 885, 2430),
          ],
          "8": [
            ConcordiaFloorPoint(floors[1], 175, 210),
            ConcordiaFloorPoint(floors[1], 175, 400),
            ConcordiaFloorPoint(floors[1], 175, 600),
            ConcordiaFloorPoint(floors[1], 175, 790),
            ConcordiaFloorPoint(floors[1], 340, 210),
            ConcordiaFloorPoint(floors[1], 340, 400),
          ]
        };
      final waypointNavigability = IndoorFeatureRepository.waypointNavigabilityGroupsByFloor[building.abbreviation];
      final connections = IndoorFeatureRepository.connectionsByBuilding[building.abbreviation];
      final outdoorExitPoint = IndoorFeatureRepository.outdoorExitPointsByBuilding[building.abbreviation];

      // Act
      final buildingData = BuildingData(building: building, floors: floors, 
          roomsByFloor: roomsByFloor!, waypointsByFloor: waypointsByFloor, 
          waypointNavigability: waypointNavigability!, connections: connections!, 
          outdoorExitPoint: outdoorExitPoint!);

      // Assert
      expect(buildingData.building, building);
      expect(buildingData.floors, floors);
    });

    test('Can get dataPath', () {
      //verify data path is accurate
      expect(BuildingData.dataPath, 'assets/maps/indoor/data/');
    });
  });

  group('BuildingDataLoader tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('Can create BuildingDataLoader', () {
      const building = BuildingRepository.h;
      final buildingDataLoader = BuildingDataLoader(building.abbreviation);

      expect(buildingDataLoader.buildingAbbreviation, building.abbreviation);
    });
    
    test('load() returns a BuildingData object', () async {
      // Arrange
      const building = BuildingRepository.h;
      final buildingDataLoader = BuildingDataLoader(building.abbreviation);
      final floors = [
        ConcordiaFloor("1", building, 1),
        ConcordiaFloor("2", building, 1),
        ConcordiaFloor("8", building, 1),
        ConcordiaFloor("9", building, 1)
      ];

      // Act
      final buildingData = await buildingDataLoader.load();

      // Assert
      expect(buildingData.building, building);
      expect(buildingData.floors, floors);
      expect(buildingData.outdoorExitPoint.floor, ConcordiaFloor("1", building, 1));
    });

    test('load() non existant building throws flutterError', () async {
      // Arrange
      const building = ConcordiaBuilding(45.4215, -75.6992, "test",
         "test", "Montreal", "QC", "WAA AAA", "WAA", ConcordiaCampus.sgw);
      final buildingDataLoader = BuildingDataLoader(building.abbreviation);

      // Verify that load() on non existant building throws an error
      expect(buildingDataLoader.load(), throwsFlutterError);
    });
  });
}