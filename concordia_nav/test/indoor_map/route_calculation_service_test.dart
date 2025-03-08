import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/services/routecalculation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteCalculationService tests', () {
    test('calculateTotalDistanceFromRoute returns totalDistance', () {
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('2', building, 1.0);
      final floor3 = ConcordiaFloor('3', building, 1.0);
      final point1 = ConcordiaFloorPoint(floor1, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor1, 3.0, 4.0);
      final point3 = ConcordiaFloorPoint(floor2, 6.0, 8.0);
      final point4 = ConcordiaFloorPoint(floor3, 1.0, 2.0);
      final point5 = ConcordiaFloorPoint(floor3, 0.0, 0.0);

      final connection1 =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);
      final connection2 =
          Connection([floor2, floor3], {}, true, 'Stairs', 4.0, 2.5);

      final route = IndoorRoute(
        building,
        [point1, point2],
        connection1,
        [point3, point3],
        building,
        [point4, point4],
        connection2,
        [point4, point5],
      );

      final distance = RouteCalculationService.calculateTotalDistanceFromRoute(route);

      expect(distance, 7.23606797749979);
    });

    test('getConnectionFocusPoint returns the focus point', () {
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('2', building, 1.0);
      final connection =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);

      final focusPoint = RouteCalculationService.getConnectionFocusPoint(
        connection, '1', const Offset(0.0, 0.0), const Offset(6.0, 8.0));

      expect(focusPoint, const Offset(3, 4));
    });

    test('formatDistance changes distance format to km if very far', () {
      final distance = RouteCalculationService.formatDistance(24000);

      // translates distance to km
      expect(distance, '24.0 km');
    });

    test('formatDistance rounds distance if smaller than 100m', () {
      final distance = RouteCalculationService.formatDistance(79.14654);

      // rounds distance
      expect(distance, '79 m');
    });

    test('formatDetailedTime rounds and keeps time in seconds if smaller than 60', () {
      final seconds = RouteCalculationService.formatDetailedTime(45.256);

      // rounds distance
      expect(seconds, '45 sec');
    });

    test('getTurnIcon returns correct icon according to direction', () {
      var icon = RouteCalculationService.getTurnIcon('Go diagonal');
      expect(icon, Icons.turn_slight_left);

      icon = RouteCalculationService.getTurnIcon('Do a U-turn');
      expect(icon, Icons.u_turn_right);
    });
  });
}