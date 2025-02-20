import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/widgets/building_info_drawer.dart';

void main() {
  group('test building info drawer', () {
    testWidgets('drawer can render', (WidgetTester tester) async {
      // Build the buildinginfodrawer widget
      await tester.pumpWidget(MaterialApp(home: BuildingInfoDrawer(
        building: BuildingRepository.ad, 
        onClose: MapViewModel().unselectBuilding)));

      // finds widgets 
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byIcon(Icons.directions), findsOneWidget); // finds directions button
      expect(find.byIcon(Icons.map), findsOneWidget); // finds indoor map button
      expect(find.text(BuildingRepository.ad.name), findsOneWidget);
    });
/*
    testWidgets('can open drawer', (WidgetTester tester) async {
      // 

    });

    testWidgets('can close drawer', (WidgetTester tester) async {
      // Build the buildinginfodrawer widget
      await tester.pumpWidget(MaterialApp(home: BuildingInfoDrawer(
        building: BuildingRepository.ad, 
        onClose: MapViewModel().unselectBuilding)));

      // find close button
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsNothing);
    });*/
  });
}