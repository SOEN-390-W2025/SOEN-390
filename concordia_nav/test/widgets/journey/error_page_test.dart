import 'package:concordia_nav/widgets/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ErrorPage displays error message', (WidgetTester tester) async {
    const testMessage = "Test error occurred";

    await tester.pumpWidget(
      const MaterialApp(
        home: ErrorPage(message: testMessage),
      ),
    );

    expect(find.text("Whoops! Something went wrong."), findsOneWidget);
    expect(find.text("Error: $testMessage"), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('ErrorPage navigates to HomePage on button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/HomePage': (context) => const Scaffold(body: Text('Home Page')),
        },
        home: const ErrorPage(message: "Test error"),
      ),
    );

    await tester.tap(find.text("Go back to Home Page"));
    await tester.pumpAndSettle();

    expect(find.text("Home Page"), findsOneWidget);
  });
}
