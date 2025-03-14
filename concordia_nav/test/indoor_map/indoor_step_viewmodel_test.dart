import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
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
        'getCurrentStepDistanceEstimate should return correct distance estimate',
        () {
      // Act: Call the method
      final distanceEstimate = viewModel.getCurrentStepDistanceEstimate();

      // Assert: Verify that the method returns the expected distance estimate
      expect(distanceEstimate, isNotNull);
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
  });
}
