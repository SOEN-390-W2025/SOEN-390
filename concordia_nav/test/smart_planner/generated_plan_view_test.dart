import 'package:concordia_nav/ui/smart_planner/generated_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeneratedPlanView Tests', () {
    testWidgets('renders GeneratedPlanView page with non constant key', (WidgetTester tester) async {{
      await tester.pumpWidget(MaterialApp(
        home: GeneratedPlanView(key: UniqueKey())
      ));
      await tester.pump();

      expect(find.text("Smart Planner"), findsOneWidget);
    }});
    
    testWidgets('GeneratedPlanView page renders correctly', (WidgetTester tester) async {{
      await tester.pumpWidget(const MaterialApp(
        home: GeneratedPlanView()
      ));
      await tester.pump();

      expect(find.text("Smart Planner"), findsOneWidget);
      expect(find.text('Suggested plan:'), findsOneWidget);

      // Press the Get Directions button
      expect(find.text('Get Directions'), findsOneWidget);
      await tester.tap(find.text('Get Directions'));
      await tester.pumpAndSettle();
    }});
  });
}