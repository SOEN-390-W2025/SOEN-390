import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_step_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../map/outdoor_location_map_test.dart';
import '../widgets/indoor/indoor_path_test.mocks.dart';
import 'indoor_step_view_test.mocks.dart';

@GenerateMocks([IndoorDirectionsViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late VirtualStepGuideViewModel viewModel;

  setUp(() {
    viewModel = VirtualStepGuideViewModel(
      sourceRoom: 'H 830',
      building: 'Hall Building',
      floor: '8',
      endRoom: 'H 113',
      isDisability: false,
      vsync: const TestVSync(), // Mock this if necessary
    );
  });

  group('VirtualStepGuideViewModel tests', () {
    test('getCurrentStepTimeEstimate should return correct time estimate', () {
      // Arrange: Set up the mock to return a specific value when the method is called
      // Act: Call the method
      final timeEstimate = viewModel.getCurrentStepTimeEstimate();

      // Assert: Verify that the method returns the expected time estimate
      expect(timeEstimate, isNotNull);
    });

    test(
        'getCurrentStepDistanceEstimate should return n/a',
        () {
      // Act: Call the method
      final distanceEstimate = viewModel.getCurrentStepDistanceEstimate();

      // Assert: Verify that the method returns N/A when no steps
      expect(distanceEstimate, isNotNull);
      expect(distanceEstimate, 'N/A');
    });

    test(
        'getCurrentStepDistanceEstimate with steps',
        () async {
      final mockDirectionsViewModel = MockIndoorDirectionsViewModel();
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('8', building, 1.0);
      final point1 = ConcordiaFloorPoint(floor1, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor1, 20.0, 46.0);
      final point3 = ConcordiaFloorPoint(floor2, 6.0, 8.0);
      final point4 = ConcordiaFloorPoint(floor2, 25.0, 32.0);

      final connection1 =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);

      final route = IndoorRoute(
        building,
        [point1, point2],
        connection1,
        [point3, point4],
        null,
        null,
        null,
        null,
      );

      when(mockDirectionsViewModel.startLocation).thenReturn(const Offset(45.4215, -75.6992));
      when(mockDirectionsViewModel.endLocation).thenReturn(const Offset(49.4215, -74.6993));
      when(mockDirectionsViewModel.calculatedRoute).thenReturn(route);
      when(mockDirectionsViewModel.calculateRoute(
        'Hall Building', '1', 'H 110', 'H 937', false))
          .thenAnswer((_) async => {});

      final stepViewModel = VirtualStepGuideViewModel(
        sourceRoom: 'H 830',
        building: 'Hall Building',
        floor: '8',
        endRoom: 'H 113',
        isDisability: false,
        directionsViewModel: mockDirectionsViewModel,
        vsync: const TestVSync(), // Mock this if necessary
      );

      await stepViewModel.initializeRoute();

      // Act: Call the method
      final distanceEstimate = stepViewModel.getCurrentStepDistanceEstimate();

      // Assert: Verify that the method returns the expected distance estimate
      expect(distanceEstimate, "0.0 m");
    });

    test('previousStep should decrease currentStepIndex', () {
      viewModel.currentStepIndex = 5; // Set an initial index
      viewModel.navigationSteps = [
        NavigationStep(
            title: 'Step 1',
            description: 'Description',
            focusPoint: Offset.zero)
      ];

      viewModel.previousStep(MockBuildContext());

      expect(viewModel.currentStepIndex,
          equals(4)); // Should move to previous step
    });

    test('getPOICategoryIcon returns right icon', () {
      IconData icon = viewModel.getPOICategoryIcon(POICategory.washroom);
      expect(icon, Icons.wc);

      icon = viewModel.getPOICategoryIcon(POICategory.other);
      expect(icon, Icons.place);
    });

    test('_addConnectionStep should add navigation step for connection', () {
      final mockRoute = MockIndoorRoute();

      when(mockRoute.firstBuilding).thenReturn(BuildingRepository.h);
      when(mockRoute.firstIndoorPortionToConnection).thenReturn([
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
      ]);
      when(mockRoute.firstIndoorConnection).thenReturn(Connection([
        ConcordiaFloor("1", BuildingRepository.h),
        ConcordiaFloor("1", BuildingRepository.h),
      ], {}, true, 'Elevator', 5.0, 3.0));
      when(mockRoute.firstIndoorPortionFromConnection).thenReturn([
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20)
      ]);
      when(mockRoute.secondBuilding).thenReturn(BuildingRepository.h);
      when(mockRoute.secondIndoorPortionToConnection).thenReturn([
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20)
      ]);
      when(mockRoute.secondIndoorConnection).thenReturn(Connection([
        ConcordiaFloor("1", BuildingRepository.h),
        ConcordiaFloor("1", BuildingRepository.h),
      ], {}, true, 'Elevator', 5.0, 3.0));
      when(mockRoute.secondIndoorPortionFromConnection).thenReturn([
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20)
      ]);
      when(mockRoute.getFloorRoutablePointListTravelTime(any)).thenReturn(5.0);
      when(mockRoute.getIndoorTravelTimeSeconds()).thenReturn(10.0);

      viewModel.addConnectionStep(mockRoute);

      expect(viewModel.navigationSteps.length, greaterThan(0));
      expect(viewModel.navigationSteps[0].title, 'Elevator');
      expect(viewModel.navigationSteps[0].description,
          'Take the elevator (accessible)');
      expect(viewModel.navigationSteps[0].icon, Icons.elevator);
    });

    test('addConnectionStep with stairs', () {
      final firstPortion = ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20);
      final firstConnection = Connection([
        ConcordiaFloor("1", BuildingRepository.h),
        ConcordiaFloor("1", BuildingRepository.h),
      ], {}, false, 'Stairs', 5.0, 3.0);
      final route = IndoorRoute(BuildingRepository.h, [firstPortion], firstConnection, null, null, null, null, null);
      viewModel.addConnectionStep(route);

      expect(viewModel.navigationSteps[0].description, "Use the stairs to continue your route");
    }); 

    test('addConnectionStep with escalator', () {
      final firstPortion = ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20);
      final firstConnection = Connection([
        ConcordiaFloor("1", BuildingRepository.h),
        ConcordiaFloor("1", BuildingRepository.h),
      ], {}, false, 'Escalator', 5.0, 3.0);
      final route = IndoorRoute(BuildingRepository.h, [firstPortion], firstConnection, null, null, null, null, null);
      viewModel.addConnectionStep(route);

      expect(viewModel.navigationSteps[0].description, "Take the escalator to continue your route");
    }); 

    test('initializeRoute with selectedPOI', () async {
      final poi = POI(id: "1", name: "washroom", buildingId:"H", floor: "1", 
          category: POICategory.washroom, x: 492, y: 678);
      final mockDirectionsViewmodel = MockIndoorDirectionsViewModel();
      when(mockDirectionsViewmodel.calculateRoute(
        'Hall Building', '8', 'H 830', 'H 113', false, destinationPOI: poi))
          .thenAnswer((_) async => {});
      final indoorRoute = IndoorRoute(
        BuildingRepository.h, null, null, null, null, null, null, null);
      when(mockDirectionsViewmodel.calculatedRoute).thenReturn(indoorRoute);
      when(mockDirectionsViewmodel.startLocation)
          .thenReturn(const Offset(45.4215, -75.6992));
      when(mockDirectionsViewmodel.endLocation)
          .thenReturn(const Offset(45.4215, -75.6992));
      const path = "assets/maps/indoor/floorplans/H8.svg";
      when(mockDirectionsViewmodel.getSvgDimensions(path))
          .thenAnswer((_) async => const Size(1024, 1024));

      final viewModelwithPOI = VirtualStepGuideViewModel(
        sourceRoom: 'H 830',
        building: 'Hall Building',
        floor: '8',
        endRoom: 'H 113',
        isDisability: false,
        selectedPOI: poi,
        directionsViewModel: mockDirectionsViewmodel,
        vsync: const TestVSync(), // Mock this if necessary
      );

      await viewModelwithPOI.initializeRoute();

      expect(viewModelwithPOI.navigationSteps, isNotEmpty);
      expect(viewModelwithPOI.navigationSteps.last.icon, Icons.wc);
    });
  });
}
