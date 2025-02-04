import 'package:concordia_nav/ui/poi/poi_choice_view.dart';
import 'package:concordia_nav/widgets/poi_box.dart';
import 'package:concordia_nav/widgets/search_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('poiAppBar', () {
    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Nearby Facilities'), findsOneWidget);
    });

    testWidgets('tapping back button in appBar brings back to home', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // find the back button and tap it
      await tester.tap(find.byIcon(Icons.arrow_back));

      // wait till the screen changes
      await tester.pumpAndSettle();

      // should be in the Home page
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('poiPage', () {
    testWidgets('searchBar and title exists', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // Verify that the searchBar widget exists
      expect(find.byType(SearchBarWidget), findsOneWidget);
    });

    testWidgets('selection title exists and is correct', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // Find the Text widget (title)
      final Text title = tester.widget(
        find.descendant(of: find.byType(Align), matching: find.byType(Text))
      );

      // Verify that title is correct
      expect(title.data, 'Select a nearby facility');
    });

    testWidgets('list of PoiBox are present', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // Verify that exactly 8 PoiBox exist
      expect(find.byType(PoiBox), findsNWidgets(8));
    });

    testWidgets('list of PoiBox are accurate', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // Verify that the Restrooms PoiBox text and icon are present
      expect(find.text('Restrooms'), findsOneWidget);
      expect(find.byIcon(Icons.wc_outlined), findsOneWidget);

      // Verify that the Elevators PoiBox text and icon are present
      expect(find.text('Elevators'), findsOneWidget);
      expect(find.byIcon(Icons.elevator_outlined), findsOneWidget);

      // Verify that the Staircases PoiBox text and icon are present
      expect(find.text('Staircases'), findsOneWidget);
      expect(find.byIcon(Icons.stairs_outlined), findsOneWidget);

      // Verify that the Emergency Exit PoiBox text and icon are present
      expect(find.text('Emergency Exit'), findsOneWidget);
      expect(find.byIcon(Icons.directions_run_outlined), findsOneWidget);

      // Verify that the Health Centers PoiBox text and icon are present
      expect(find.text('Health Centers'), findsOneWidget);
      expect(find.byIcon(Icons.local_hospital_outlined), findsOneWidget);

      // Verify that the Lost and Found PoiBox text and icon are present
      expect(find.text('Lost and Found'), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);

      // Verify that the Food and Drinks PoiBox text and icon are present
      expect(find.text('Food & Drinks'), findsOneWidget);
      expect(find.byIcon(Icons.food_bank_outlined), findsOneWidget);

      // Verify that the Others PoiBox text and icon are present
      expect(find.text('Others'), findsOneWidget);
      expect(find.byIcon(Icons.more_outlined), findsOneWidget);
    });

    testWidgets('PoiBox onPress works', (WidgetTester tester) async {
      // Build the POI page widget
      await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
      await tester.pump();

      // Tap on Elevators PoiBox
      await tester.tap(find.text('Elevators'));
      await tester.pump();

      // Tap on Staircases PoiBox
      await tester.tap(find.text('Staircases'));
      await tester.pump();

      // Tap on Emergency Exit PoiBox
      await tester.tap(find.text('Emergency Exit'));
      await tester.pump();

      // Tap on Health Centers PoiBox
      await tester.tap(find.text('Health Centers'));
      await tester.pump();

      // Tap on Lost and Found PoiBox
      await tester.tap(find.text('Lost and Found'));
      await tester.pump();

      // Tap on Food & Drinks PoiBox
      await tester.tap(find.text('Food & Drinks'));
      await tester.pump();

      // Tap on Others PoiBox
      await tester.tap(find.text('Others'));
      await tester.pump();

      // Tap on Restrooms PoiBox brings to POIMapView
      await tester.tap(find.text('Restrooms'));
      await tester.pumpAndSettle();
      // Should be in the POI map view page
      expect(find.text('Nearby Facility'), findsOneWidget);
    });

  });
}