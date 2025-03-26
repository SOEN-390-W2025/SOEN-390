import 'package:concordia_nav/ui/setting/accessibility/accessibility_page.dart';
import 'package:concordia_nav/ui/setting/accessibility/color_adjustment_view.dart';
import 'package:concordia_nav/ui/setting/settings_page.dart';
import 'package:concordia_nav/widgets/accessibility_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';

void main() {
  testWidgets('Tapping a sub-option calls the provided onTap function',
      (WidgetTester tester) async {
    bool wasTapped = false;

    // Define the sub-options with an onTap function
    final subOptions = [
      {
        'title': 'Sub Option 1',
        'onTap': () {
          wasTapped = true; // This should be set to true when tapped
        },
      },
    ];

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccessibilityTile(
            title: 'Main Option',
            subOptions: subOptions,
          ),
        ),
      ),
    );

    // Tap the main tile to expand it
    await tester.tap(find.text('Main Option'));
    await tester.pump(); // Rebuild UI

    // Tap the sub-option
    await tester.tap(find.text('Sub Option 1'));
    await tester.pump(); // Rebuild UI

    // Verify that the onTap function was triggered
    expect(wasTapped, isTrue);
  });

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
    // define routes needed for this test
    final routes = {
      '/HomePage': (context) => const HomePage(),
      '/SettingsPage': (context) => const SettingsPage(),
      '/AccessibilityPage': (context) => const AccessibilityPage(),
      '/ColorAdjustmentView': (context) => const ColorAdjustmentView(),
    };

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/AccessibilityPage',
      routes: routes,
    ));

    // Press the accessibility button
    expect(find.text('Accessibility'), findsOneWidget);
    await tester.tap(find.text('Accessibility'));
    await tester.pumpAndSettle();

    // Press the Visual accessibility button
    expect(find.text('Visual Accessibility'), findsOneWidget);
    await tester.tap(find.text('Visual Accessibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Color adjustment'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text-to-speech'));
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
