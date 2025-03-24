import 'package:concordia_nav/ui/indoor_map/building_selection.dart';
import 'package:concordia_nav/ui/indoor_map/floor_selection.dart';
import 'package:concordia_nav/widgets/select_indoor_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SelectIndoorDestination Widget Tests', () {

    testWidgets(
        'SelectIndoorDestination displays Select Floor button if floor is not null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SelectIndoorDestination(building: 'Hall Building', floor: '2'),
        ),
      );

      expect(find.text('Select Floor'), findsOneWidget);
    });

    testWidgets(
        'SelectIndoorDestination navigates to FloorSelection when Select Floor is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SelectIndoorDestination(building: 'Hall Building', floor: '2'),
        ),
      );

      await tester.tap(find.text('Select Floor'));
      await tester.pumpAndSettle();

      expect(find.byType(FloorSelection), findsOneWidget);
    });
  });
}
