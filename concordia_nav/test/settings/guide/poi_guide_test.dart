import 'package:concordia_nav/ui/setting/guide/poi_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('POIGuide tests', () {
    testWidgets('renders POIGuide with non-constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: POIGuide(key: UniqueKey())));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Find Nearby Facilities'), findsOneWidget);
    });

    testWidgets('renders POIGuide accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: POIGuide()));
      await tester.pump();

      expect(find.text('Key Features:'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(3));
    });
  });
}
