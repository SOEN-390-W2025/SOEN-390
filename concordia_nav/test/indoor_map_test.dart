import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/widgets/indoor_map_view.dart';
import 'package:concordia_nav/widgets/map_layout.dart';

void main() {
  group('IndoorMapView Widget Tests', () {
    testWidgets('IndoorMapView should render correctly',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorMapView(),
        ),
      );

      // Verify that the custom app bar is rendered with the correct title
      expect(find.text('Indoor Map'), findsOneWidget);

      // Verify that the MapLayout is rendered
      expect(find.byType(MapLayout), findsOneWidget);
    });

    testWidgets('MapLayout should receive correct parameters',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorMapView(),
        ),
      );

      // Find the MapLayout widget
      final mapLayout = tester.widget<MapLayout>(find.byType(MapLayout));

      // Verify that the MapLayout receives the correct parameters
      expect(mapLayout.searchController, isA<TextEditingController>());
      expect(mapLayout.onMyLocation, isA<Function>());
      expect(mapLayout.onZoomIn, isA<Function>());
      expect(mapLayout.onZoomOut, isA<Function>());
    });

    testWidgets('CustomAppBar should have the correct title',
        (WidgetTester tester) async {
      // Build the IndoorMapView widget
      await tester.pumpWidget(
        const MaterialApp(
          home: IndoorMapView(),
        ),
      );

      // Verify that the custom app bar has the correct title
      expect(find.text('Indoor Map'), findsOneWidget);
    });
  });
}
