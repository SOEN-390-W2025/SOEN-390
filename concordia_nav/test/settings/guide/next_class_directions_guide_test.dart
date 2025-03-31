import 'package:concordia_nav/ui/setting/guide/next_class_directions_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NextClassDirectionsGuide tests', () {
    testWidgets('renders NextClassDirectionsGuide with non constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NextClassDirectionsGuide(key: UniqueKey())));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Next Class Directions'), findsOneWidget);
    });

    testWidgets('renders NextClassDirectionsGuide correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NextClassDirectionsGuide()));
      await tester.pump();

      expect(find.text('Key Features:'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(3));
    });
  });
}