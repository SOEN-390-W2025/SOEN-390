import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/navigation_decision.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/repositories/navigation_decision_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationDecisionRepository', () {
    test('should return NavigationDecision for same building classroom', () {
      final source = ConcordiaRoom(
          'H-801',
          RoomCategory.classroom,
          ConcordiaFloor("1", BuildingRepository.h),
          ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0));
      final destination = ConcordiaRoom(
          'H-802',
          RoomCategory.classroom,
          ConcordiaFloor("2", BuildingRepository.h),
          ConcordiaFloorPoint(ConcordiaFloor("2", BuildingRepository.h), 0, 0));
      final journey = [source, destination];

      final result =
          NavigationDecisionRepository.determineNavigationDecision(journey);

      expect(result, isNotNull);
      expect(result?.navCase, NavigationCase.sameBuildingClassroom);
      expect(result?.pageCount, 1);
    });

    test('should return NavigationDecision for different building classroom',
        () {
      final source = ConcordiaRoom(
          'H-801',
          RoomCategory.classroom,
          ConcordiaFloor("1", BuildingRepository.h),
          ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0));
      final destination = ConcordiaRoom(
          'LB-801',
          RoomCategory.classroom,
          ConcordiaFloor("1", BuildingRepository.lb),
          ConcordiaFloorPoint(
              ConcordiaFloor("1", BuildingRepository.lb), 0, 0));
      final journey = [source, destination];

      final result =
          NavigationDecisionRepository.determineNavigationDecision(journey);

      expect(result, isNotNull);
      expect(result?.navCase, NavigationCase.differentBuildingClassroom);
      expect(result?.pageCount, 3);
    });

    test('should return NavigationDecision for outdoor to classroom', () {
      const source = BuildingRepository.h;
      final destination = ConcordiaRoom(
          'H-801',
          RoomCategory.classroom,
          ConcordiaFloor("1", BuildingRepository.lb),
          ConcordiaFloorPoint(
              ConcordiaFloor("1", BuildingRepository.lb), 0, 0));
      final journey = [source, destination];

      final result =
          NavigationDecisionRepository.determineNavigationDecision(journey);

      expect(result, isNotNull);
      expect(result?.navCase, NavigationCase.outdoorToClassroom);
      expect(result?.pageCount, 2);
    });

    test('should return null for empty journey list', () {
      final result =
          NavigationDecisionRepository.determineNavigationDecision([]);

      expect(result, isNull);
    });

    test('should return null for single item journey list', () {
      final journey = [BuildingRepository.h];
      final result =
          NavigationDecisionRepository.determineNavigationDecision(journey);

      expect(result, isNull);
    });
  });
}
