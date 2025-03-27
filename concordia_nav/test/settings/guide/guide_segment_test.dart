import 'package:concordia_nav/widgets/guide_segment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuideSegment tests', () {
    testWidgets('renders GuideSegment with non-constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: GuideSegment(
        key: UniqueKey(),
        title: 'Test', 
        description: 'Super Test')));
      await tester.pump();

       expect(find.text('Test'), findsOneWidget);
       expect(find.text('Super Test'), findsOneWidget);
    });

    testWidgets('renders GuideSegment accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GuideSegment(
        title: 'Test', 
        description: 'Super Test',
        assetPath: 'assets/images/guide/campus_map_3.png')));
      await tester.pump();

       expect(find.text('Test'), findsOneWidget);
       expect(find.text('Super Test'), findsOneWidget);
       expect(find.byType(Card), findsOneWidget);
    });
  });
}