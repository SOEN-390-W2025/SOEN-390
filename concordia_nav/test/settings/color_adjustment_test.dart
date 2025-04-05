import 'package:concordia_nav/ui/setting/accessibility/color_adjustment_view.dart';
import 'package:concordia_nav/ui/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ColorAdjustmentView Widget Tests', () {
    testWidgets('Opens color wheel and applies a color for each color type',
        (WidgetTester tester) async {
      // Set up the app widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const ColorAdjustmentView(),
        ),
      );

      // List of color row labels in the UI
      final colorRowLabels = [
        'Primary color',
        'Secondary color',
        'Background color',
        'Card color',
        'Primary text color',
        'Secondary text color',
      ];

      for (var label in colorRowLabels) {
        // Tap the color row to open the color picker
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        // Expect the color picker dialog to show up
        expect(find.text('Select $label'), findsOneWidget);
        expect(find.byType(ColorPicker), findsOneWidget);

        // Tap on a point inside the color picker to simulate color selection
        final pickerFinder = find.byType(ColorPicker);
        final pickerCenter = tester.getCenter(pickerFinder);
        await tester.tapAt(pickerCenter +
            const Offset(10, 10)); // slight offset inside the wheel
        await tester.pumpAndSettle();

        // Tap the "APPLY" button
        await tester.tap(find.text('APPLY'));
        await tester.pumpAndSettle();

        // Ensure dialog closed
        expect(find.text('Select $label'), findsNothing);
      }
    });

    testWidgets('Displays all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const ColorAdjustmentView(),
        ),
      );

      expect(find.text('Customize your colors'), findsOneWidget);
      expect(find.text('Primary color'), findsOneWidget);
      expect(find.text('Secondary color'), findsOneWidget);
      expect(find.text('Background color'), findsOneWidget);
      expect(find.text('Card color'), findsOneWidget);
      expect(find.text('Primary text color'), findsOneWidget);
      expect(find.text('Secondary text color'), findsOneWidget);
      expect(find.text('Color Preview'), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Reset to default'), findsOneWidget);
    });

    testWidgets('Opens color picker when a color row is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const ColorAdjustmentView(),
        ),
      );

      final primaryButtonFinder = find.text('Primary Button');
      await tester.ensureVisible(primaryButtonFinder);
      await tester.tap(primaryButtonFinder);
      await tester.pumpAndSettle();

      final secondaryButtonFinder = find.text('Secondary Button');
      await tester.ensureVisible(secondaryButtonFinder);
      await tester.tap(secondaryButtonFinder);
      await tester.pumpAndSettle();

      final primaryColorFinder = find.text('Primary color');
      await tester.ensureVisible(primaryColorFinder);
      await tester.tap(primaryColorFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Select Primary color'), findsOneWidget);
      expect(find.text('APPLY'), findsOneWidget);

      final applyButtonFinder = find.text('APPLY');
      await tester.ensureVisible(applyButtonFinder);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(applyButtonFinder);
      await tester.pump();

      await tester.tap(find.text('Primary color'));
      await tester.pumpAndSettle();

      final cancelButtonFinder = find.text('CANCEL');
      await tester.ensureVisible(cancelButtonFinder);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(cancelButtonFinder);
      await tester.pump();
    });

    testWidgets('Saves theme changes on pressing Save changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const ColorAdjustmentView(),
        ),
      );

      final saveButtonFinder = find.text('Save changes');
      await tester.ensureVisible(saveButtonFinder);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(saveButtonFinder);
      await tester.pump();
    });

    testWidgets('Resets theme when Reset to default is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const ColorAdjustmentView(),
        ),
      );

      final resetFinder = find.text('Reset to default');
      await tester.ensureVisible(resetFinder);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(resetFinder);
      await tester.pump();
    });
  });
}
