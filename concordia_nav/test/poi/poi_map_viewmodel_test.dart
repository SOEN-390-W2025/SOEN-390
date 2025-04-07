import 'dart:ui';

import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/data/repositories/building_data_manager.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/utils/building_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:concordia_nav/utils/poi/poi_map_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'poi_map_viewmodel_test.mocks.dart';

@GenerateMocks([IndoorDirectionsViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  late POIMapViewModel poiMapViewModel;
  late MockIndoorDirectionsViewModel mockDirectionsViewModel;
  setUp(() async {
    mockDirectionsViewModel = MockIndoorDirectionsViewModel();
    final buildingData = await BuildingDataManager.getBuildingData("H");
    final floor = ConcordiaFloor("1", BuildingRepository.h);
    final point = ConcordiaFloorPoint(floor, 450, 670);
    when(mockDirectionsViewModel.getRegularStartPoint(buildingData, "1"))
        .thenReturn(point);
    when(mockDirectionsViewModel.getSvgDimensions(any))
        .thenAnswer((_) async => const Size(1024, 1024));
    poiMapViewModel = POIMapViewModel(
        poiName: "Washroom",
        buildingViewModel: BuildingViewModel(),
        indoorDirectionsViewModel: mockDirectionsViewModel,
        indoorMapViewModel: IndoorMapViewModel(vsync: const TestVSync()));
  });

  group('POIMapViewModel Tests', () {
    test('can get isLoading value', () {
      final loading = poiMapViewModel.isLoading;

      // verify returns true by default
      expect(loading, true);
    });

    test('can get floorPlanExists value', () {
      final floorPlanExists = poiMapViewModel.floorPlanExists;

      // verify returns true by default
      expect(floorPlanExists, true);
    });

    test('can get floorPlanPath value', () {
      final floorPlanPath = poiMapViewModel.floorPlanPath;

      // verify returns empty string by default
      expect(floorPlanPath, '');
    });

    test('can get width value', () {
      final width = poiMapViewModel.width;

      // verify returns a value by default
      expect(width, 1024.0);
    });

    test('can get height value', () {
      final height = poiMapViewModel.height;

      // verify returns a value by default
      expect(height, 1024.0);
    });

    test('can get searchRadius value', () {
      final searchRadius = poiMapViewModel.searchRadius;

      // verify returns 50 by default
      expect(searchRadius, 50);
    });

    test('can get isLoadingAllPOIs value', () {
      final loading = poiMapViewModel.isLoadingAllPOIs;

      // verify returns true when loadingAllPois
      expect(loading, true);
    });

    test('loadPOIData with initialBuilding', () async {
      await poiMapViewModel.loadPOIData(
          initialBuilding: "Hall Building", initialFloor: "1");

      expect(poiMapViewModel.nearestBuilding, BuildingRepository.h);
      expect(poiMapViewModel.matchingPOIs, isNotEmpty);
      expect(poiMapViewModel.poisOnCurrentFloor, isNotEmpty);
      expect(poiMapViewModel.noPoisOnCurrentFloor, false);
      expect(poiMapViewModel.allPOIs, isNotEmpty);
    });

    test('loadPOIData creates error if invalid building', () async {
      await poiMapViewModel.loadPOIData(
          initialBuilding: "Test Building", initialFloor: "1");

      expect(poiMapViewModel.errorMessage, "Building Test Building not found.");
      expect(poiMapViewModel.nearestBuilding, null);
    });

    test('loadPOIData without initial building without location permissions',
        () async {
      await poiMapViewModel.loadPOIData();

      expect(poiMapViewModel.errorMessage,
          "Could not determine your location. Please check location permissions.");
    });

    test('findNearestBuildingWithPOI', () async {
      await poiMapViewModel.loadPOIData(
          initialBuilding: "Hall Building", initialFloor: "1");
      await poiMapViewModel.findNearestBuildingWithPOI(
          45.49648751167641, -73.57862647170876, "");

      expect(poiMapViewModel.nearestBuilding, BuildingRepository.h);
    });

    test('changeFloor changes the selected floor', () async {
      await poiMapViewModel.changeFloor("9");

      expect(poiMapViewModel.selectedFloor, "9");
    });

    test('setSearchRadius updates poisOnCurrentFloor', () async {
      final buildingData = await BuildingDataManager.getBuildingData("H");
      final floor = ConcordiaFloor("1", BuildingRepository.h);
      final point = ConcordiaFloorPoint(floor, 50, 50);
      when(mockDirectionsViewModel.getRegularStartPoint(buildingData, "1"))
          .thenReturn(point);

      await poiMapViewModel.loadPOIData(
          initialBuilding: "Hall Building", initialFloor: "1");
      final originalPOIs = poiMapViewModel.poisOnCurrentFloor;
      expect(originalPOIs, isEmpty);

      await poiMapViewModel.setSearchRadius(2000);
      expect(poiMapViewModel.poisOnCurrentFloor, isNotEmpty);
    });

    test('retry calls loadPOIData and updates poisOnCurrentFloor', () async {
      await poiMapViewModel.retry(
          initialBuilding: "Hall Building", initialFloor: "1");

      expect(poiMapViewModel.nearestBuilding, BuildingRepository.h);
      expect(poiMapViewModel.matchingPOIs, isNotEmpty);
      expect(poiMapViewModel.poisOnCurrentFloor, isNotEmpty);
      expect(poiMapViewModel.userPosition, const Offset(450, 670));
    });

    test('panToPOI pans POI', () {
      final poi = POI(
          id: "1",
          name: "washroom",
          buildingId: "H",
          floor: "1",
          category: POICategory.washroom,
          x: 492,
          y: 678);
      poiMapViewModel.panToPOI(poi, const Size(50, 50));
    });

    test('panToFirstPOI pans to first POI', () async {
      await poiMapViewModel.loadPOIData(
          initialBuilding: "Hall Building", initialFloor: "1");

      poiMapViewModel.panToFirstPOI(const Size(50, 50));
    });
  });
}
