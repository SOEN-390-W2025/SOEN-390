import 'package:concordia_nav/ui/setting/guide/indoor_directions_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndoorDirectionsGuide tests', () {
    testWidgets('renders IndoorDirectionsGuide with non constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: IndoorDirectionsGuide(key: UniqueKey())));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Indoor Directions'), findsOneWidget);
    });

    testWidgets('renders IndoorDirectionsGuide correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: IndoorDirectionsGuide()));
      await tester.pump();

      expect(find.text('Key Features:'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(4));
    });
  });
}