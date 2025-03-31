import 'package:concordia_nav/ui/setting/guide/campus_map_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CampusMapGuide tests', () {
    testWidgets('renders CampusMapGuide with non constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CampusMapGuide(key: UniqueKey())));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Campus Map'), findsOneWidget);
    });

    testWidgets('renders CampusMapGuide correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CampusMapGuide()));
      await tester.pump();

      expect(find.text('Key Features:'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(3));
    });
  });
}