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
            campus: ConcordiaCampus.loy,
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
      expect(ConcordiaCampus.sgw.name, "Sir George Williams Campus");
      expect(ConcordiaCampus.sgw.abbreviation, "SGW");
      expect(ConcordiaCampus.sgw.lat, 45.49721130711485);
      expect(ConcordiaCampus.sgw.lng, -73.5787529114208);
    });

    test('Verify LOY campus properties', () {
      expect(ConcordiaCampus.loy.name, "Loyola Campus");
      expect(ConcordiaCampus.loy.abbreviation, "LOY");
      expect(ConcordiaCampus.loy.lat, 45.45887506989712);
      expect(ConcordiaCampus.loy.lng, -73.6404461142605);
    });

    test('Campus.fromAbbreviation returns correct campus', () {
      expect(ConcordiaCampus.fromAbbreviation("sgw"), ConcordiaCampus.sgw);
      expect(ConcordiaCampus.fromAbbreviation("loy"), ConcordiaCampus.loy);
    });

    test('Campus.fromAbbreviation throws exception for invalid abbreviation',
        () {
      expect(
          () => ConcordiaCampus.fromAbbreviation("xyz"), throwsArgumentError);
      expect(() => ConcordiaCampus.fromAbbreviation(""), throwsArgumentError);
    });

    test('Campus.campuses contains only predefined campuses', () {
      expect(ConcordiaCampus.campuses.length, 2);
      expect(ConcordiaCampus.campuses, contains(ConcordiaCampus.sgw));
      expect(ConcordiaCampus.campuses, contains(ConcordiaCampus.loy));
      expect(ConcordiaCampus.campuses, isNot(contains(null)));
    });
  });
}
