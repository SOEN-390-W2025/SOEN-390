import 'package:concordia_nav/ui/poi/poi_map_view.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('poi_map_view appBar', () {
    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Nearby Facility'), findsOneWidget);
    });

    testWidgets('tapping back btn in appBar brings back to poiPage', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // find the back button and tap it
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(); // wait till screen changes

      // Should be in POI page
      expect(find.text('Nearby Facilities'), findsOneWidget);
    });
  });

  group('POI map view page', () {
    testWidgets('mapLayout widget exists', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // Verify that MapLayout widget exists
      expect(find.byType(MapLayout), findsOneWidget);
    });

    testWidgets('time and distance text fields exist', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // Find the row the two fields are in
      final Row fieldBox = tester.widget(
        find.descendant(of: find.byType(Container), matching: find.byType(Row).first)
      );

      // Verify that it contains exactly 2 children (the two fields)
      expect(fieldBox.children.length, 2);
    });
  });
}