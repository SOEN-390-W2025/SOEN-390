import 'package:concordia_nav/ui/setting/accessibility/accessibility_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';

void main() {
  testWidgets('renders AccessibilityPage with non-constant key',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccessibilityPage(key: UniqueKey()),
      ),
    );

    expect(find.text('Accessibility'), findsOneWidget);
  });

  testWidgets('Accessibility Page should render correctly',
      (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));

    // Verify that the app bar is present and has the correct title
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Verify that the Concordia Campus Guide text and icon are present
    expect(find.text('Concordia Campus Guide'), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    // Press the settings button
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Press the accessibility button
    expect(find.text('Accessibility'), findsOneWidget);
    await tester.tap(find.text('Accessibility'));
    await tester.pumpAndSettle();

    // Press the Visual accessibility button
    expect(find.text('Visual Accessibility'), findsOneWidget);
    await tester.tap(find.text('Visual Accessibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text size and style'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visual Accessibility'));
    await tester.pumpAndSettle();

    // Press the Visual accessibility button
    expect(find.text('Hearing Accessibility'), findsOneWidget);
    await tester.tap(find.text('Hearing Accessibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hearing Accessibility'));
    await tester.pumpAndSettle();

    // Press the Visual accessibility button
    expect(find.text('Physical and Motor Accessibility'), findsOneWidget);
    await tester.tap(find.text('Physical and Motor Accessibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Physical and Motor Accessibility'));
    await tester.pumpAndSettle();

    // Press the Visual accessibility button
    expect(find.text('Cognitive Accessibility'), findsOneWidget);
    await tester.tap(find.text('Cognitive Accessibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cognitive Accessibility'));
    await tester.pumpAndSettle();

    // Press the Visual accessibility button
    expect(find.text('General Accessibility'), findsOneWidget);
    await tester.tap(find.text('General Accessibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('General Accessibility'));
    await tester.pumpAndSettle();
  });
}
