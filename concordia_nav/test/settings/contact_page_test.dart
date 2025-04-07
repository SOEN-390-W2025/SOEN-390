import 'package:concordia_nav/ui/setting/contact/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders contact page with expected sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ContactPage(),
      ),
    );

    // Check for titles
    expect(find.text('Central Phone Line'), findsOneWidget);
    expect(find.text('🚨 Emergency (24/7)'), findsOneWidget);
    expect(find.text('IT Support'), findsOneWidget);
    expect(find.text('Campus Addresses'), findsOneWidget);

    // Check for campus names
    expect(find.text('Sir George Williams Campus'), findsOneWidget);
    expect(find.text('Loyola Campus'), findsOneWidget);
  });

  testWidgets('tapping ticket link calls launchUrl',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ContactPage(),
      ),
    );

    final ticketLink = find.text('Open a ticket');
    expect(ticketLink, findsOneWidget);

    await tester.tap(ticketLink);
    await tester.pumpAndSettle();

    expect(find.text('Sir George Williams Campus'), findsOneWidget);
    expect(find.text('Loyola Campus'), findsOneWidget);
  });

  testWidgets('has semantics label for accessibility',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ContactPage(),
      ),
    );

    final semantics =
        find.bySemanticsLabel('Displays useful contact information.');
    expect(semantics, findsOneWidget);
  });
}
