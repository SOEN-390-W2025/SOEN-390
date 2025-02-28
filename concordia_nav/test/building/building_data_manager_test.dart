import 'package:concordia_nav/data/repositories/building_data.dart';
import 'package:concordia_nav/data/repositories/building_data_manager.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildingDataManager tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    test('getAllBuildingData returns map of buildingData', () async {
      final buildingDataCache = await BuildingDataManager.getAllBuildingData();

      // verify buildingDataCache type and that it contains a value
      expect(buildingDataCache, isA<Map<String, BuildingData>>());
      expect(buildingDataCache["H"]!.building, BuildingRepository.h);
    });

    test('getAllBuildingData by initializing datapaths first', () async {
      await BuildingDataManager.initialize();

      final buildingDataCache = await BuildingDataManager.getAllBuildingData();

      // verify buildingDataCache type and that it contains a value
      expect(buildingDataCache, isA<Map<String, BuildingData>>());
      expect(buildingDataCache["H"]!.building, BuildingRepository.h);
    });

    test('getBuildingData returns buildingData for specific abbreviation', () async {
      final buildingData = await BuildingDataManager.getBuildingData("H");

      // verify return value has right type and value
      expect(buildingData, isA<BuildingData>());
      expect(buildingData!.building, BuildingRepository.h);
    });

    test('getBuildingData throws flutterError with invalid abbrebiation', () {
      const invalidAbbreviation = "WAA";
      
      // verify method throws flutterError when given a non existant abbreviation
      expect(BuildingDataManager.getBuildingData(invalidAbbreviation), throwsFlutterError);
    });

    test('toJson doesnt trigger errors', () async {
      // verify no errors are triggered when running it
      await BuildingDataManager.toJson();
    });
  });
}