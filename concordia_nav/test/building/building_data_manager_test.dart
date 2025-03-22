import 'dart:io';

import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/data/repositories/building_data.dart';
import 'package:concordia_nav/data/repositories/building_data_manager.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'building_data_manager_test.mocks.dart';

@GenerateMocks([AssetManifest, BuildingDataLoader])
void main() {
  setUp(() {
    BuildingDataManager.buildingDataCache = null;
    BuildingDataManager.buildingDataPaths = null;
    BuildingDataManager.setAssetManifest(null);
    BuildingDataManager.setLoader(null);
  });

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

    test('getBuildingData returns buildingData for specific abbreviation',
        () async {
      final buildingData = await BuildingDataManager.getBuildingData("H");

      // verify return value has right type and value
      expect(buildingData, isA<BuildingData>());
      expect(buildingData!.building, BuildingRepository.h);
    });

    test('getBuildingData returns null with invalid abbrebiation', () async {
      const invalidAbbreviation = "WAA";

      // verify method returns null when given a non existant abbreviation
      expect(await BuildingDataManager.getBuildingData(invalidAbbreviation),
          isNull);
    });

    test('toJson doesnt trigger errors', () async {
      // verify no errors are triggered when running it
      await BuildingDataManager.toJson();
    });
  });

  test('should return an empty map when no indoor map paths are found',
      () async {
    // Simulate no indoor map paths being found
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets()).thenReturn([]);

    BuildingDataManager.setAssetManifest(mockAssetManifest);

    final result = await BuildingDataManager.loadAllBuildingData();

    // Expect that the result is an empty map
    expect(result, isEmpty);
  });

  test('should return map of building data when indoor map paths are found',
      () async {
    // Simulate indoor map paths being found
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets()).thenReturn(['path/to/building.yaml']);

    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenAnswer((_) async => BuildingData(
        building: BuildingRepository.h,
        roomsByFloor: {},
        floors: [],
        waypointsByFloor: {},
        waypointNavigability: {},
        connections: [],
        outdoorExitPoint: ConcordiaFloorPoint(
            ConcordiaFloor("1", BuildingRepository.h), 0, 0)));

    BuildingDataManager.setAssetManifest(mockAssetManifest);
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadAllBuildingData();

    // Expect that the result is a map with building data
    expect(result, isEmpty);
  });

  test(
      'should return empty map when loading building data results in an exception',
      () async {
    // Simulate an exception being thrown while loading building data
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets()).thenReturn(['path/to/building.yaml']);

    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenThrow(Exception('Error loading building data'));

    BuildingDataManager.setAssetManifest(mockAssetManifest);
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadAllBuildingData();

    // Expect that the result is an empty map due to error
    expect(result, isEmpty);
  });

  test('should skip already loaded building data', () async {
    // Simulate indoor map paths being found
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets())
        .thenReturn(['path/to/building1.yaml', 'path/to/building2.yaml']);

    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenAnswer((_) async => BuildingData(
        building: const ConcordiaBuilding(
            1.00,
            1.00,
            "BUILDING2",
            "123 ABC St.",
            "Alphabet",
            "Quebec",
            "A1B2C3",
            "BUILDING2",
            ConcordiaCampus.sgw),
        roomsByFloor: {},
        floors: [],
        waypointsByFloor: {},
        waypointNavigability: {},
        connections: [],
        outdoorExitPoint: ConcordiaFloorPoint(
            ConcordiaFloor("1", BuildingRepository.h), 0, 0)));

    // Mock that the first building has already been loaded
    BuildingDataManager.buildingDataCache = {
      'BUILDING1': BuildingData(
          building: BuildingRepository.h,
          roomsByFloor: {},
          floors: [],
          waypointsByFloor: {},
          waypointNavigability: {},
          connections: [],
          outdoorExitPoint: ConcordiaFloorPoint(
              ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
    };

    BuildingDataManager.setAssetManifest(mockAssetManifest);
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadAllBuildingData();

    // Expect that only one building is added because the other was already cached
    expect(result, contains('BUILDING1'));
  });

  test('should handle error when loading building data and return empty map',
      () async {
    // Simulate an error when loading building data
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets()).thenReturn(['path/to/building.yaml']);

    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenThrow(Exception('Error loading building data'));

    BuildingDataManager.setAssetManifest(mockAssetManifest);
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadAllBuildingData();

    // Expect that the result is an empty map
    expect(result, isEmpty);
  });

  test('should return an empty list in getBuildingDataPaths() if no assets',
      () async {
    // Simulate no assets found
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets()).thenReturn([]); // Return empty list

    BuildingDataManager.setAssetManifest(mockAssetManifest);

    final paths = await BuildingDataManager.getBuildingDataPaths();
    expect(paths, isEmpty); // Expect empty list
  });

  test('should return FormatException in loadBuildingData()', () async {
    // Simulate a format exception when loading building data
    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenThrow(const FormatException('Invalid format'));
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadBuildingData('ABBR');

    // Expect that the result is a FormatException
    expect(result, isA<FormatException>());
    expect((result as FormatException).message, 'Invalid format');
  });

  test('should return FileSystemException in loadBuildingData()', () async {
    // Simulate a file system exception when loading building data
    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load())
        .thenThrow(const FileSystemException('File system error'));
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadBuildingData('ABBR');

    // Expect that the result is a FileSystemException
    expect(result, isA<FileSystemException>());
    expect((result as FileSystemException).message, 'File system error');
  });

  test('should return ArgumentError in loadBuildingData()', () async {
    // Simulate an argument error while loading building data
    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenThrow(ArgumentError('Invalid argument'));
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadBuildingData('ABBR');

    // Expect that the result is an ArgumentError
    expect(result, isA<ArgumentError>());
    expect((result as ArgumentError).message, 'Invalid argument');
  });

  test('should return Exception in loadBuildingData()', () async {
    // Simulate a generic exception when loading building data
    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenThrow(Exception('Generic error'));
    BuildingDataManager.setLoader(mockLoader);

    final result = await BuildingDataManager.loadBuildingData('ABBR');

    // Expect that the result is a generic Exception
    expect(result, isA<Exception>());
    expect((result as Exception).toString(), 'Exception: Generic error');
  });

  test('should return Exception in loadAllBuildingData()', () async {
    // Simulate a generic exception when loading all building data
    final mockAssetManifest = MockAssetManifest();
    when(mockAssetManifest.listAssets()).thenReturn(
        ['path/to/building.yaml']); // Simulate that there's one asset

    final mockLoader = MockBuildingDataLoader();
    when(mockLoader.load()).thenThrow(Exception('Error loading building data'));

    final result = await BuildingDataManager.loadAllBuildingData();

    // Expect that the result is an Exception
    expect(result, isA<Map<String, BuildingData>>());
  });

  test('extractPOIsFromBuilding returns a list of POIs', () async {
    final listPOIs = await BuildingDataManager.extractPOIsFromBuilding("MB");

    expect(listPOIs, isNotEmpty);
    expect(listPOIs, isA<List<POI>>());
    expect(listPOIs[0], isA<POI>());
  });

  test('extractPOIsFromBuilding returns empty list if invalid building', () async {
    final listPOIs = await BuildingDataManager.extractPOIsFromBuilding("EV");

    expect(listPOIs, isEmpty);
  });

  test('getAllPOIs returns a list of POIs for all buildings', () async {
    final listPOIs = await BuildingDataManager.getAllPOIs();

    expect(listPOIs, isNotEmpty);
    expect(listPOIs, isA<List<POI>>());
    expect(listPOIs.first.buildingId, "CC");
    expect(listPOIs.last.buildingId, "VL");
  });
}
