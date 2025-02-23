import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/widgets/building_info_drawer.dart';

void main() async {

  group('test building info drawer', () {
    testWidgets('drawer can render', (WidgetTester tester) async {
      // Build the buildinginfodrawer widget
      await tester.pumpWidget(MaterialApp(
          home: BuildingInfoDrawer(
              building: BuildingRepository.ad,
              onClose: () {})));

      // finds widgets
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byIcon(Icons.directions),
          findsOneWidget); // finds directions button
      expect(find.byIcon(Icons.map), findsOneWidget); // finds indoor map button
      expect(find.text(BuildingRepository.ad.name), findsOneWidget);
    });
  });
}
