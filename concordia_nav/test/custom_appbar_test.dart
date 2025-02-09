import 'package:concordia_nav/ui/home/homepage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customAppBar', () {
    // Test that the customAppBar returns an AppBar widget
    testWidgets('should return an AppBar widget', (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));

      // Ensure the widget tree is rendered
      await tester.pump();

      // Verify that the returned widget is an AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    // Test that the AppBar has the correct title
    testWidgets('should have the correct title', (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));

      // Ensure the widget tree is rendered
      await tester.pump();

      // Verify that the title is correct
      expect(find.text('Home'), findsOneWidget);
    });

    // Test that the AppBar has the correct background color
    testWidgets('should have the correct background color',
        (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));

      // Ensure the widget tree is rendered
      await tester.pump();

      // Verify that the background color is correct
      final AppBar appBarWidget = tester.widget(find.byType(AppBar));
      expect(appBarWidget.backgroundColor,
          Theme.of(tester.element(find.byType(AppBar))).primaryColor);
    });

    // Test that the AppBar has a leading IconButton with the correct icon
    testWidgets('should have a leading IconButton with the correct icon',
        (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));

      // Ensure the widget tree is rendered
      await tester.pump();

      // Find the leading IconButton
      final IconButton leadingIconButton = tester.widget(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(IconButton).first,
        ),
      );

      const expectedIcon = const Icon(Icons.settings, color: Colors.white);
      final actualIcon = leadingIconButton.icon as Icon;

      expect(actualIcon.icon, expectedIcon.icon); // Compare IconData
      expect(actualIcon.color, expectedIcon.color); // Compare color
    });

    // Test that the AppBar has an actions list with the correct icon
    testWidgets('should have an actions list with the correct icon',
        (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));

      // Ensure the widget tree is rendered
      await tester.pump();

      // Find the actions IconButton
      final IconButton leadingIconButton = tester.widget(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(IconButton).at(1),
        ),
      );

      const expectedIcon = const Icon(Icons.menu, color: Colors.white);
      final actualIcon = leadingIconButton.icon as Icon;

      expect(actualIcon.icon, expectedIcon.icon); // Compare IconData
      expect(actualIcon.color, expectedIcon.color); // Compare color
    });

    testWidgets('tapping the Settings button should bring to settingspage', (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));

      // Ensure the widget tree is rendered
      await tester.pump();

      // find the Settings icon and tap it
      await tester.tap(find.byIcon(Icons.settings));

      // wait till the screen changes
      await tester.pumpAndSettle();

      // should be in the Settings page
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('back button in the Settings page brings back to home', (WidgetTester tester) async {
      // Build the customAppBar inside a MaterialApp
      await tester.pumpWidget(const MaterialApp(home: const HomePage()));
      await tester.pump();

      // find the Settings icon and tap it
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // find back button in settings page and tap it 
      await tester.tap(find.byIcon(Icons.arrow_back));

      // wait till the screen changes
      await tester.pumpAndSettle();

      // should be in the Home page
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
