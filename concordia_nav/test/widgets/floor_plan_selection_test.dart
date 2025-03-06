import 'package:concordia_nav/ui/indoor_map/classroom_selection.dart';
import 'package:concordia_nav/widgets/floor_plan_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FloorPlanSearchWidget Tests', () {
    testWidgets('Tapping search navigates to ClassroomSelection',
        (WidgetTester tester) async {
      final searchController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloorPlanSearchWidget(
              searchController: searchController,
              building: 'Hall Building',
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
