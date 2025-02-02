import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/data/domain-model/campus.dart';

void main() {
  group('Campus Class Tests', () {
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
