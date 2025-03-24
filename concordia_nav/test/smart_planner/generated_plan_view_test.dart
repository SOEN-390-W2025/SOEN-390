import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/travelling_salesman_request.dart';
import 'package:concordia_nav/ui/smart_planner/generated_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeneratedPlanView Tests', () {
    testWidgets('renders GeneratedPlanView page with non constant key',
        (WidgetTester tester) async {
      {
        final samplePlan = TravellingSalesmanRequest(
          [
            (
              "Place A",
              const Location(45.5017, -73.5673, "Place A", "Description",
                  "Category", "Address", "Building Code"),
              900
            ),
            (
              "Place B",
              const Location(45.5017, -73.5673, "Place A", "Description",
                  "Category", "Address", "Building Code"),
              1200
            ),
          ],
          [
            (
              "Meeting",
              const Location(45.5017, -73.5673, "Place A", "Description",
                  "Category", "Address", "Building Code"),
              DateTime(2025, 3, 24, 14, 0),
              DateTime(2025, 3, 24, 15, 0)
            )
          ],
          DateTime(2025, 3, 24, 9, 0),
          const Location(45.5017, -73.5673, "Place A", "Description",
              "Category", "Address", "Building Code"),
        );

        final routes = {
          '/GeneratedPlanView': (context) {
            return GeneratedPlanView(
              plan: samplePlan,
              key: UniqueKey(),
            );
          }
        };

        // Build the HomePage widget
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/GeneratedPlanView',
          routes: routes,
        ));

        expect(find.text("Generated Plan"), findsOneWidget);
      }
    });

    testWidgets('GeneratedPlanView page renders correctly',
        (WidgetTester tester) async {
      {
        final samplePlan = TravellingSalesmanRequest(
          [
            (
              "Place A",
              const Location(45.5017, -73.5673, "Place A", "Description",
                  "Category", "Address", "Building Code"),
              900
            ),
            (
              "Place B",
              const Location(45.5017, -73.5673, "Place A", "Description",
                  "Category", "Address", "Building Code"),
              1200
            ),
          ],
          [
            (
              "Meeting",
              const Location(45.5017, -73.5673, "Place A", "Description",
                  "Category", "Address", "Building Code"),
              DateTime(2025, 3, 24, 14, 0),
              DateTime(2025, 3, 24, 15, 0)
            )
          ],
          DateTime(2025, 3, 24, 9, 0),
          const Location(45.5017, -73.5673, "Place A", "Description",
              "Category", "Address", "Building Code"),
        );

        final routes = {
          '/GeneratedPlanView': (context) {
            return GeneratedPlanView(
              plan: samplePlan,
            );
          }
        };

        // Build the HomePage widget
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/GeneratedPlanView',
          routes: routes,
        ));

        expect(find.text("Generated Plan"), findsOneWidget);
      }
    });
  });
}
