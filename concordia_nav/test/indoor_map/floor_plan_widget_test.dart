import 'dart:ui';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/indoor_location/floor_plan_widget.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:concordia_nav/widgets/indoor/indoor_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late IndoorMapViewModel mockIndoorMapViewModel;
  late double testWidth;
  late double testHeight;

  setUp(() {
    mockIndoorMapViewModel = IndoorMapViewModel(vsync: const TestVSync());
    testWidth = 1024.0;
    testHeight = 1024.0;
  });

  testWidgets('Double tapping pans to the correct region',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloorPlanWidget(
            indoorMapViewModel: mockIndoorMapViewModel,
            floorPlanPath: 'assets/floor_plan.svg',
            semanticsLabel: 'Test Floor Plan',
            width: testWidth,
            height: testHeight,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(const Offset(200, 200));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.down(const Offset(200, 200));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(mockIndoorMapViewModel.transformationController.toScene(Offset.zero),
        isNotNull);
  });

  testWidgets('Displays error message when SVG fails to load',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloorPlanWidget(
            indoorMapViewModel: mockIndoorMapViewModel,
            floorPlanPath: 'invalid_path.svg',
            semanticsLabel: 'Test Floor Plan',
            width: testWidth,
            height: testHeight,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No floor plans exist at this time.'), findsOneWidget);
  });

  testWidgets('FloorPlanWidget with pois', (WidgetTester tester) async {
    final pois = [
      POI(id: "1", name: "washroom", buildingId:"H", floor: "1", category: POICategory.washroom, 
          x: 492, y: 678),
      POI(id: "2", name: "washroom", buildingId:"H", floor: "1", category: POICategory.washroom, 
          x: 564, y: 711),
      POI(id: "3", name: "washroom", buildingId:"H", floor: "1", category: POICategory.washroom, 
          x: 815, y: 915)];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloorPlanWidget(
            indoorMapViewModel: mockIndoorMapViewModel,
            floorPlanPath: 'assets/floor_plan.svg',
            semanticsLabel: 'Test Floor Plan',
            width: testWidth,
            height: testHeight,
            pois: pois,
            onPoiTap: (poi) => {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsAtLeast(1));
  });

  testWidgets('FloorPlanWidget with current location', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloorPlanWidget(
            indoorMapViewModel: mockIndoorMapViewModel,
            floorPlanPath: 'assets/floor_plan.svg',
            semanticsLabel: 'Test Floor Plan',
            width: testWidth,
            height: testHeight,
            currentLocation: const Offset(45.4215, -75.6992),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // find white circle marker
    final container = find.byType(Container).evaluate().single.widget as Container;
    final locationMarker = container.decoration as BoxDecoration;
    expect(find.byType(Container), findsOneWidget);
    expect(locationMarker.color, Colors.white);
    expect(locationMarker.shape, BoxShape.circle);
  });

  group('Indoor Path Tests', () {
    test('test', () async {
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('2', building, 1.0);
      final floor3 = ConcordiaFloor('3', building, 1.0);
      final point1 = ConcordiaFloorPoint(floor1, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor1, 3.0, 4.0);
      final point3 = ConcordiaFloorPoint(floor2, 6.0, 8.0);
      final point4 = ConcordiaFloorPoint(floor3, 1.0, 2.0);
      final point5 = ConcordiaFloorPoint(floor3, 3.0, 4.0);

      final connection1 =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);
      final connection2 =
          Connection([floor2, floor3], {}, true, 'Stairs', 4.0, 2.5);

      final route = IndoorRoute(building, [point1, point2], connection1, [point3],
        building, [point4], connection2, [point4, point5]);

      final indoorMapPainter = IndoorMapPainter(
        route: route,
        startLocation: const Offset(0, 0), 
        endLocation: const Offset(3.0, 4.0)
      );

      final canvas = Canvas(PictureRecorder());

      // draw path
      indoorMapPainter.paint(canvas, const Size(1024, 1024));

      expect(canvas.toString(), 'Canvas(recording: true)');
    });
  });
}
