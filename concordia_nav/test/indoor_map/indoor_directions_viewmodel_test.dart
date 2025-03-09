import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concrete_floor_routable_point.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/utils/building_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late IndoorDirectionsViewModel indoorDirectionsViewModel;

  setUp(() {
    indoorDirectionsViewModel = IndoorDirectionsViewModel();
  });

  test('Getter for isAccessibilityMode', () {
    expect(indoorDirectionsViewModel.isAccessibilityMode, false);
  });

  test('Toggling accessibility mode updates value', () {
    indoorDirectionsViewModel.toggleAccessibilityMode(true);
    expect(indoorDirectionsViewModel.isAccessibilityMode, true);
  });

  test('getPositionPoint should return a valid point for a known room',
      () async {
    final point = await indoorDirectionsViewModel.getPositionPoint(
        'Hall Building', '8', '827');
    expect(point, isA<ConcordiaFloorPoint>());
  });

  test('getPositionPoint should handle leading zeros in room number', () async {
    final point = await indoorDirectionsViewModel.getPositionPoint(
        'John Molson School of Business', 'S2', '0001');
    expect(point, isA<ConcordiaFloorPoint>());
  });

  test('getStartPoint with accessibility mode active provides elevator point', () async {
    final point = await indoorDirectionsViewModel.getStartPoint(
      'Hall Building', '8', true);

    expect(point, isA<ConcordiaFloorPoint>());
    expect(point?.floor.floorNumber, '8');
    expect(point?.positionX, 665);
  });

  test('getStartPoint with accessibility mode disabled provides escalator point', () async {
    final point = await indoorDirectionsViewModel.getStartPoint(
      'Hall Building', '8', false);

    expect(point, isA<ConcordiaFloorPoint>());
    expect(point?.floor.floorNumber, '8');
    expect(point?.positionX, 520);
  });

  test('getStartPoint with accessibility mode disabled provides stairs point if no escalator', () async {
    final point = await indoorDirectionsViewModel.getStartPoint(
      'Vanier Library', '1', false);

    expect(point, isA<ConcordiaFloorPoint>());
    expect(point?.floor.floorNumber, '1');
    expect(point?.positionX, 519);
  });

  group('ConcreteFloorRoutablePoint Setters', () {
    test('Can create a ConcreteFloorRoutablePoint', () {
      final floor = ConcordiaFloor("1", BuildingRepository.h);
      final concreteFloorRoutablePoint = ConcreteFloorRoutablePoint(
        floor: floor, positionX: 0, positionY: 0);

      expect(concreteFloorRoutablePoint.floor.floorNumber, "1");
      expect(concreteFloorRoutablePoint.positionX, 0);
      expect(concreteFloorRoutablePoint.positionY, 0);
    });

    test('Can set ConcreteFloorRoutablePoint attributes', () {
      final floor = ConcordiaFloor("1", BuildingRepository.h);
      final concreteFloorRoutablePoint = ConcreteFloorRoutablePoint(
        floor: floor, positionX: 0, positionY: 0);

      // Verify can change floor
      concreteFloorRoutablePoint.floor = ConcordiaFloor("2", BuildingRepository.h);
      expect(concreteFloorRoutablePoint.floor.floorNumber, "2");

      // Verify can change positionX
      concreteFloorRoutablePoint.positionX = 20;
      expect(concreteFloorRoutablePoint.positionX, 20);

      // Verify can change positionY
      concreteFloorRoutablePoint.positionY = 22;
      expect(concreteFloorRoutablePoint.positionY, 22);
    });
  });

  group('BuildingViewModel tests', () {
    test('getFloorsForBuilding returns empty list when cant find yaml', () async {
      final floors = await BuildingViewModel().getFloorsForBuilding('Administration Building');
      expect(floors, []);
    });

    test('getRoomsForFloor returns [] when cant find yaml', () async {
      final rooms = await BuildingViewModel().getRoomsForFloor('Administration Building', '1');
      expect(rooms, []);
    });
  });
}
