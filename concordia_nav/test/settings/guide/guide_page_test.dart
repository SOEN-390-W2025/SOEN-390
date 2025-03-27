import 'package:concordia_nav/ui/setting/guide/guide_page.dart';
import 'package:concordia_nav/widgets/guide_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuidePage tests', () {
    testWidgets('renders GuidePage with non constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: GuidePage(key: UniqueKey())));
      await tester.pump();

      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Explore Campus Features'), findsOneWidget);
    });

    testWidgets('renders GuidePage correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuidePage()));
      await tester.pump();

      final campusCard = find.byType(GuideCard).evaluate().first.widget as GuideCard;
      expect(find.byType(GuideCard), findsAtLeast(5));
      expect(campusCard.title, 'Campus Map');
    });

    testWidgets('can navigate to specific guide page',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuidePage()));
      await tester.pump();

      // tap on Campus Map guide
      expect(find.text('Campus Map'), findsOneWidget);
      await tester.tap(find.text('Campus Map'));
      await tester.pumpAndSettle();

      expect(find.text('Campus Map'), findsOneWidget);
      expect(find.text('Key Features:'), findsOneWidget);
    });
  });
}