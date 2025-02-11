import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';

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
      expect(ConcordiaCampus.sgw.name, "SGW Campus");
      expect(ConcordiaCampus.sgw.abbreviation, "sgw");
      expect(ConcordiaCampus.sgw.lat, 45.4973);
      expect(ConcordiaCampus.sgw.lng, -73.5793);
    });

    test('Verify LOY campus properties', () {
      expect(ConcordiaCampus.loy.name, "LOY Campus");
      expect(ConcordiaCampus.loy.abbreviation, "loy");
      expect(ConcordiaCampus.loy.lat, 45.4582);
      expect(ConcordiaCampus.loy.lng, -73.6405);
    });

    test('Verify unknown campus properties', () {
      expect(ConcordiaCampus.unknown.name, "Unknown");
      expect(ConcordiaCampus.unknown.abbreviation, "unknown");
      expect(ConcordiaCampus.unknown.lat, 45.4582);
      expect(ConcordiaCampus.unknown.lng, -73.6405);
    });

    test('Campus.fromAbbreviation returns correct campus', () {
      expect(ConcordiaCampus.fromAbbreviation("sgw"), ConcordiaCampus.sgw);
      expect(ConcordiaCampus.fromAbbreviation("loy"), ConcordiaCampus.loy);
    });

    test('Campus.fromAbbreviation returns unknown for invalid abbreviation',
        () {
      expect(ConcordiaCampus.fromAbbreviation("xyz"), ConcordiaCampus.unknown);
      expect(ConcordiaCampus.fromAbbreviation(""), ConcordiaCampus.unknown);
    });

    test('Campus.campuses contains only predefined campuses', () {
      expect(ConcordiaCampus.campuses.length, 2);
      expect(ConcordiaCampus.campuses, contains(ConcordiaCampus.sgw));
      expect(ConcordiaCampus.campuses, contains(ConcordiaCampus.loy));
      expect(
          ConcordiaCampus.campuses, isNot(contains(ConcordiaCampus.unknown)));
    });
  });
}
