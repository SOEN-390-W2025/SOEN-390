import 'package:concordia_nav/ui/setting/guide/campus_map_guide.dart';
import 'package:concordia_nav/widgets/guide_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuideCard tests', () {
    testWidgets('renders GuideCard with non-constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: GuideCard(
        key: UniqueKey(),
        title: 'Test', 
        description: 'Super Test', 
        icon: Icons.abc, 
        route: const CampusMapGuide())));
      await tester.pump();

       expect(find.text('Test'), findsOneWidget);
       expect(find.byIcon(Icons.abc), findsOneWidget);
    });

    testWidgets('renders GuideCard accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuideCard(
        title: 'Test', 
        description: 'Super Test', 
        icon: Icons.abc, 
        route: CampusMapGuide())));
      await tester.pump();

       expect(find.text('Test'), findsOneWidget);
       expect(find.text('Super Test'), findsOneWidget);
       expect(find.byIcon(Icons.abc), findsOneWidget);
    });

    testWidgets('tap on widget brings to route page',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuideCard(
        title: 'Test', 
        description: 'Super Test', 
        icon: Icons.abc, 
        route: CampusMapGuide())));
      await tester.pump();

      expect(find.text('Test'), findsOneWidget);
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(find.text('Campus Map'), findsOneWidget);
    });
  });
}