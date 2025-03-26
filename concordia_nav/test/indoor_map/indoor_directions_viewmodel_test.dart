import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concrete_floor_routable_point.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
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

  test('Getter for isLoading is false by default', () {
    expect(indoorDirectionsViewModel.isLoading, false);
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

  test('getStartPoint with accessibility mode active provides elevator point',
      () async {
    final point = await indoorDirectionsViewModel.getStartPoint(
        'Hall Building', '8', true, '');

    expect(point, isA<ConcordiaFloorPoint>());
    expect(point?.floor.floorNumber, '8');
    expect(point?.positionX, 665);
  });

  test(
      'getStartPoint with accessibility mode disabled provides escalator point',
      () async {
    final point = await indoorDirectionsViewModel.getStartPoint(
        'Hall Building', '8', false, '');

    expect(point, isA<ConcordiaFloorPoint>());
    expect(point?.floor.floorNumber, '8');
    expect(point?.positionX, 520);
  });

  test(
      'getStartPoint with accessibility mode disabled provides stairs point if no escalator',
      () async {
    final point = await indoorDirectionsViewModel.getStartPoint(
        'Vanier Library', '1', false, '');

    expect(point, isA<ConcordiaFloorPoint>());
    expect(point?.floor.floorNumber, '1');
    expect(point?.positionX, 519);
  });

  test('areDirectionsAvailableForLocation checks if directions available', () async {
    final available = await indoorDirectionsViewModel.areDirectionsAvailableForLocation('H 937');

    expect(available, true);
  });

  test('areDirectionsAvailableForLocation returns false if location has no space', () async {
    final available = await indoorDirectionsViewModel.areDirectionsAvailableForLocation('H937');

    expect(available, false);
  });

  test('areDirectionsAvailableForLocation returns true with valid location', () async {
    final available = await indoorDirectionsViewModel.areDirectionsAvailableForLocation('MB S2115');

    expect(available, true);
  });

  test('areDirectionsAvailableForLocation returns true with MB S2', () async {
    final available = await indoorDirectionsViewModel.areDirectionsAvailableForLocation('MB S2');

    expect(available, true);
  });

  test('areDirectionsAvailableForLocation returns false if roomNumber empty', () async {
    final available = await indoorDirectionsViewModel.areDirectionsAvailableForLocation('H ');

    expect(available, false);
  });

  test('areDirectionsAvailableForLocation returns true with building abb and floor nb', () async {
    final available = await indoorDirectionsViewModel.areDirectionsAvailableForLocation('H 1');

    expect(available, true);
  });

  test('can set the endLocation', () {
    const offset = Offset(492, 678);
    indoorDirectionsViewModel.endLocation = offset;

    expect(indoorDirectionsViewModel.endLocation, offset);
  });

  test('calculateRoute with destinationPOI calculates route', () async {
    final poi = POI(id: "1", name: "Washroom", buildingId:"H", floor: "1", 
        category: POICategory.washroom, x: 492, y: 678);
    await indoorDirectionsViewModel.calculateRoute(
      "Hall Building", "1", "H 110", "", false, destinationPOI: poi);

    expect(indoorDirectionsViewModel.endLocation, const Offset(492, 678));
    expect(indoorDirectionsViewModel.eta, "7 sec");
  });

  test('calculateRoute with ma endRoom calculates route', () async {
    await indoorDirectionsViewModel.calculateRoute(
      "Hall Building", "1", "H 110", "ma", false);

    expect(indoorDirectionsViewModel.endLocation, const Offset(310, 1000));
    expect(indoorDirectionsViewModel.eta, "4 sec");
  });

  group('ConcreteFloorRoutablePoint Setters', () {
    test('Can create a ConcreteFloorRoutablePoint', () {
      final floor = ConcordiaFloor("1", BuildingRepository.h);
      final concreteFloorRoutablePoint =
          ConcreteFloorRoutablePoint(floor: floor, positionX: 0, positionY: 0);

      expect(concreteFloorRoutablePoint.floor.floorNumber, "1");
      expect(concreteFloorRoutablePoint.positionX, 0);
      expect(concreteFloorRoutablePoint.positionY, 0);
    });

    test('Can set ConcreteFloorRoutablePoint attributes', () {
      final floor = ConcordiaFloor("1", BuildingRepository.h);
      final concreteFloorRoutablePoint =
          ConcreteFloorRoutablePoint(floor: floor, positionX: 0, positionY: 0);

      // Verify can change floor
      concreteFloorRoutablePoint.floor =
          ConcordiaFloor("2", BuildingRepository.h);
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
    test('getFloorsForBuilding returns empty list when cant find yaml',
        () async {
      final floors = await BuildingViewModel()
          .getFloorsForBuilding('Administration Building');
      expect(floors, []);
    });

    test('getRoomsForFloor returns [] when cant find yaml', () async {
      final rooms = await BuildingViewModel()
          .getRoomsForFloor('Administration Building', '1');
      expect(rooms, []);
    });

    test('getBuildingFromLocation returns a building from its location string', () async{
      final building = BuildingViewModel().getBuildingFromLocation('H 937');
      expect(building?.abbreviation, 'H');
    });

    test('getBuildingFromLocation returns null if location has invalid format', () {
      final building = BuildingViewModel().getBuildingFromLocation('937');
      expect(building, isNull);
    });
  });
}
