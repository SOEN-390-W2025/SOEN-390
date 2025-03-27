import 'package:concordia_nav/ui/setting/guide/outdoor_directions_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OutdoorDirectionsGuide tests', () {
    testWidgets('renders OutdoorDirectionsGuide with non constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: OutdoorDirectionsGuide(key: UniqueKey())));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Outdoor Directions'), findsOneWidget);
    });

    testWidgets('renders OutdoorDirectionsGuide correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OutdoorDirectionsGuide()));
      await tester.pump();

      expect(find.text('Key Features:'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(4));
    });
  });
}