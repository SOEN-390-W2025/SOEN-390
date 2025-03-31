import 'package:concordia_nav/widgets/header_guide_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeaderGuide tests', () {
    testWidgets('renders HeaderGuide with non-constant key',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HeaderGuide(
        key: UniqueKey(),
        title: 'Test', 
        description: 'Super Test',
        assetPath: 'assets/images/guide/campus_map_3.png')));
      await tester.pump();

       expect(find.text('Test'), findsOneWidget);
       expect(find.text('Super Test'), findsOneWidget);
       expect(find.text('Key Features:'), findsOneWidget);
    });

    testWidgets('renders HeaderGuide accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HeaderGuide(
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