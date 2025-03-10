import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/widgets/indoor/indoor_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'indoor_path_test.mocks.dart';

@GenerateMocks([Canvas, IndoorRoute])
void main() {
  group('IndoorMapPainter Tests', () {
    late MockIndoorRoute mockRoute;
    late Offset startLocation;
    late Offset endLocation;
    late MockCanvas mockCanvas;

    setUp(() {
      mockRoute = MockIndoorRoute();
      startLocation = const Offset(100, 100);
      endLocation = const Offset(200, 200);
      mockCanvas = MockCanvas();
    });

    test('Draw Step View Test', () {
      // Set up mock data for step view
      when(mockRoute.firstIndoorPortionToConnection).thenReturn([
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20)
      ]);
      when(mockRoute.firstIndoorPortionFromConnection).thenReturn([
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20)
      ]);
      when(mockRoute.firstIndoorConnection).thenReturn(Connection([
        ConcordiaFloor("1", BuildingRepository.h),
        ConcordiaFloor("1", BuildingRepository.h),
      ], {}, true, 'Elevator', 5.0, 3.0));
      when(mockRoute.secondIndoorPortionToConnection).thenReturn(null);
      when(mockRoute.secondIndoorConnection).thenReturn(null);
      when(mockRoute.secondIndoorPortionFromConnection).thenReturn(null);

      final painter = IndoorMapPainter(
        route: mockRoute,
        startLocation: startLocation,
        endLocation: endLocation,
        showStepView: true,
      );

      // Call the paint method
      painter.paint(mockCanvas, const Size(400, 400));

      // Verify that paths and circles are drawn (this is checking the logic, adjust according to methods you expect)
      verify(mockCanvas.drawCircle(startLocation, 6.0, any)).called(1);
      verify(mockCanvas.drawCircle(endLocation, 6.0, any)).called(1);
    });

    test('Draw Path Test', () {
      final points = [
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
      ];

      final painter = IndoorMapPainter(
        route: mockRoute,
        startLocation: startLocation,
        endLocation: endLocation,
      );

      painter.drawPath(mockCanvas, points);

      verify(mockCanvas.drawPath(any, any)).called(1);
    });

    test('Draw Highlighted Segment Near Point Test', () {
      final points = [
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 10, 20),
        ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 50, 60),
        ConcordiaFloorPoint(
            ConcordiaFloor("1", BuildingRepository.h), 100, 120),
        ConcordiaFloorPoint(
            ConcordiaFloor("1", BuildingRepository.h), 139, 120),
        ConcordiaFloorPoint(
            ConcordiaFloor("1", BuildingRepository.h), 139, 120),
      ];

      const targetPoint = Offset(100, 120);

      final painter = IndoorMapPainter(
        route: mockRoute,
        startLocation: startLocation,
        endLocation: endLocation,
        highlightCurrentStep: true,
        currentStepPoint: targetPoint,
      );

      painter.drawHighlightedSegmentNearPoint(mockCanvas, points, targetPoint);
    });

    test('Distance to Segment Test', () {
      const p = Offset(15, 25);
      const v = Offset(10, 20);
      const w = Offset(30, 40);

      final painter = IndoorMapPainter(
        route: mockRoute,
        startLocation: startLocation,
        endLocation: endLocation,
      );

      final distance = painter.distanceToSegment(p, v, w);
      expect(distance, isNotNull);
    });

    test('Draw Connection Test', () {
      final connection = Connection([
        ConcordiaFloor("1", BuildingRepository.h),
        ConcordiaFloor("1", BuildingRepository.h),
      ], {
        'points': [
          ConcordiaFloorPoint(
              ConcordiaFloor("1", BuildingRepository.h), 10, 20),
          ConcordiaFloorPoint(
              ConcordiaFloor("1", BuildingRepository.h), 50, 60),
        ]
      }, true, 'Elevator', 5.0, 3.0);

      final painter = IndoorMapPainter(
        route: mockRoute,
        startLocation: startLocation,
        endLocation: endLocation,
      );

      painter.drawConnection(mockCanvas, connection);

      verify(mockCanvas.drawCircle(any, any, any)).called(2);
    });
  });
}
