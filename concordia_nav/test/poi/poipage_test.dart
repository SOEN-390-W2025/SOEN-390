import 'package:concordia_nav/ui/poi/poi_choice_view.dart';
import 'package:concordia_nav/ui/poi/poi_map_view.dart';
import 'package:concordia_nav/widgets/poi_box.dart';
import 'package:concordia_nav/widgets/search_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('poiAppBar', () {
    testWidgets('renders POIChoiceView with non-constant key',
        (WidgetTester tester) async {
      // runAsync ref: https://stackoverflow.com/a/69004451
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester
            .pumpWidget(MaterialApp(home: POIChoiceView(key: UniqueKey())));
        await tester.pump();

        // Verify that the appBar exists and has the right title
        expect(find.text('Nearby Facilities'), findsOneWidget);
      });
    });

    testWidgets('appBar has the right title', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
        await tester.pump();

        // Verify that the appBar exists and has the right title
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Nearby Facilities'), findsOneWidget);
      });
    });
  });

  group('poiViewModel', () {
    testWidgets('filter option works', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
        await tester.pump();

        // Find the SearchBarWidget
        final searchBarWidget = find
            .byType(SearchBarWidget)
            .evaluate()
            .single
            .widget as SearchBarWidget;

        expect(searchBarWidget.controller.text, "");

        // Enter "Lost" in the searchBar
        await tester.enterText(find.byType(SearchBarWidget), "Lost");
        expect(searchBarWidget.controller.text, "Lost");
        await tester.pumpAndSettle();

        // Verify that a PoiBox is present
        expect(find.byType(PoiBox), findsAtLeast(1));
      });
    });

    testWidgets('filter invalid option removes all poiBoxes',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
        await tester.pump();

        // Find the SearchBarWidget
        final searchBarWidget = find
            .byType(SearchBarWidget)
            .evaluate()
            .single
            .widget as SearchBarWidget;

        expect(searchBarWidget.controller.text, "");

        // Enter "Lost" in the searchBar
        await tester.enterText(find.byType(SearchBarWidget), "Test");
        expect(searchBarWidget.controller.text, "Test");
        await tester.pumpAndSettle();

        // Verify that a PoiBox is present
        expect(find.byType(PoiBox), findsNothing);
        expect(find.text("No results found"), findsOneWidget);
      });
    });
  });

  group('poiPage', () {
    testWidgets('searchBar and title exists', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
        await tester.pump();

        // Verify that the searchBar widget exists
        expect(find.byType(SearchBarWidget), findsOneWidget);
      });
    });

    testWidgets('list of PoiBox are present', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // Build the POI page widget
        await tester.pumpWidget(const MaterialApp(home: const POIChoiceView()));
        await tester.pump();

        // Verify that exactly 8 PoiBox exist
        expect(find.byType(PoiBox), findsAtLeast(4));
      });
    });

    testWidgets('list of PoiBox are accurate', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
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
        await tester.ensureVisible(find.text('Emergency Exit'));
        await tester.pumpAndSettle();
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
    });

    testWidgets('PoiBox onPress works', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // wait for loading JSON
        // define routes needed for this test
        final routes = {
          '/': (context) => const POIChoiceView(),
          '/POIMapView': (context) => const POIMapView(),
        };

        // Build the POIChoiceView widget
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/',
          routes: routes,
        ));
        await tester.pumpAndSettle();

        // Tap on Restrooms PoiBox brings to POIMapView
        await tester.tap(find.text('Restrooms'));
        await tester.pumpAndSettle();
        // Should be in the POI map view page
        expect(find.text('Nearby Facility'), findsWidgets);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(); // return to POIPage

        // Tap on Elevators PoiBox
        await tester.tap(find.text('Elevators'));
        await tester.pump();

        // Tap on Staircases PoiBox
        await tester.ensureVisible(find.text('Staircases'));
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
        await tester.ensureVisible(find.text('Food & Drinks'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food & Drinks'));
        await tester.pump();

        // Tap on Others PoiBox
        await tester.tap(find.text('Others'));
        await tester.pumpAndSettle();
      });
    });
  });
}
