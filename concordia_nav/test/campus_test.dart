import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/domain-model/campus.dart';

void main() {
  group('Campus Class Tests', () {
    testWidgets('CampusMapPage should render correctly with non-constant key',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMapPage(
            key: UniqueKey(),
            campus: Campus.loy,
          ),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.byType(CampusMapPage), findsOneWidget);

      // Press the button that swaps campus views
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
    });

    test('Verify SGW campus properties', () {
      expect(Campus.sgw.name, "SGW Campus");
      expect(Campus.sgw.abbreviation, "sgw");
      expect(Campus.sgw.lat, 45.4973);
      expect(Campus.sgw.lng, -73.5793);
    });

    test('Verify LOY campus properties', () {
      expect(Campus.loy.name, "LOY Campus");
      expect(Campus.loy.abbreviation, "loy");
      expect(Campus.loy.lat, 45.4582);
      expect(Campus.loy.lng, -73.6405);
    });

    test('Verify unknown campus properties', () {
      expect(Campus.unknown.name, "Unknown");
      expect(Campus.unknown.abbreviation, "unknown");
      expect(Campus.unknown.lat, 45.4582);
      expect(Campus.unknown.lng, -73.6405);
    });

    test('Campus.fromAbbreviation returns correct campus', () {
      expect(Campus.fromAbbreviation("sgw"), Campus.sgw);
      expect(Campus.fromAbbreviation("loy"), Campus.loy);
    });

    test('Campus.fromAbbreviation returns unknown for invalid abbreviation',
        () {
      expect(Campus.fromAbbreviation("xyz"), Campus.unknown);
      expect(Campus.fromAbbreviation(""), Campus.unknown);
    });

    test('Campus.campuses contains only predefined campuses', () {
      expect(Campus.campuses.length, 2);
      expect(Campus.campuses, contains(Campus.sgw));
      expect(Campus.campuses, contains(Campus.loy));
      expect(Campus.campuses, isNot(contains(Campus.unknown)));
    });
  });
}
