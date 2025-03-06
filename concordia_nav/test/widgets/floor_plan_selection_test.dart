import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:concordia_nav/widgets/floor_plan_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  const ConcordiaCampus campus = ConcordiaCampus(
    45.49721130711485,
    -73.5787529114208,
    "Sir George Williams Campus",
    "1455 boul. de Maisonneuve O",
    "Montreal",
    "QC",
    "H3G 1M8",
    "SGW"
  );

  const ConcordiaBuilding building = ConcordiaBuilding(
    45.49721130711485,
    -73.5787529114208,
    "Hall Building",
    "1455 boul. de Maisonneuve O",
    "Montreal",
    "QC",
    "H3G 1M8",
    "H",
    campus
  );

  group('FloorPlanSearchWidget Tests', () {
    testWidgets('Tapping search navigates to ClassroomSelection',
        (WidgetTester tester) async {
      final searchController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloorPlanSearchWidget(
              searchController: searchController,
              building: building,
              floor: '2',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byType(ClassroomSelection), findsOneWidget);
    });
  });
}
