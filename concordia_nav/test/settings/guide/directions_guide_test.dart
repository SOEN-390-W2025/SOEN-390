import 'package:concordia_nav/ui/setting/guide/directions_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DirectionsGuide tests', () {
    testWidgets('renders IndoorDirectionsGuide with non constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: DirectionsGuide(
        key: UniqueKey(),
        directionsType: 'Indoor')));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Indoor Directions'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(4));
    });

    testWidgets('renders DirectionsGuide correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DirectionsGuide(
        directionsType: 'Outdoor',
      )));
      await tester.pump();

      expect(find.text('Outdoor Directions'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(4));
    });
  });
}