import 'package:concordia_nav/ui/indoor_location/indoor_location_view.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndoorLocationView', () {
    testWidgets('renders correctly with a non-constant key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IndoorLocationView(
            building: "Building",
            key: UniqueKey(),
          ),
        ),
      );
      expect(find.text('Indoor Location'), findsOneWidget);
    });
  });

  group('indoor location appBar', () {
    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the indoor location view widget
      await tester
          .pumpWidget(const MaterialApp(home: const IndoorLocationView(building: 'building')));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Indoor Location'), findsOneWidget);
    });
  });

  group('indoor location view page', () {
    testWidgets('mapLayout widget exists', (WidgetTester tester) async {
      // Build the indoor location view widget
      await tester
          .pumpWidget(const MaterialApp(home: const IndoorLocationView(building: 'building')));
      await tester.pump();

      // Verify that MapLayout widget exists
      expect(find.byType(MapLayout), findsOneWidget);
    });
  });
}
