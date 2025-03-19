import 'package:concordia_nav/widgets/journey/navigation_step_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget({required int pageCount}) {
    return MaterialApp(
      home: NavigationStepPage(
        journeyName: 'Test Journey',
        pageCount: pageCount,
        pageBuilder: (index) => Center(child: Text('Page $index')),
      ),
      routes: {
        '/HomePage': (context) => const Scaffold(body: Text('Home Page')),
      },
    );
  }

  testWidgets('Displays the first page initially', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(pageCount: 3));

    expect(find.text('Page 0'), findsOneWidget);
    expect(find.text('Proceed to The Next Direction Step'), findsOneWidget);
  });

  testWidgets('Navigates to next page on button press',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(pageCount: 3));

    await tester.tap(find.text('Proceed to The Next Direction Step'));
    await tester.pumpAndSettle();

    expect(find.text('Page 1'), findsOneWidget);
  });

  testWidgets('Displays "Complete My Journey" on last step',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(pageCount: 2));

    await tester.tap(find.text('Proceed to The Next Direction Step'));
    await tester.pumpAndSettle();

    expect(find.text('Complete My Journey'), findsOneWidget);
  });

  testWidgets('Navigates to HomePage when completed',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(pageCount: 2));

    await tester.tap(find.text('Proceed to The Next Direction Step'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete My Journey'));
    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);
  });
}
