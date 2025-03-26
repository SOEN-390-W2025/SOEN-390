import 'package:concordia_nav/ui/setting/accessibility/color_adjustment_view.dart';
import 'package:concordia_nav/ui/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  group('Color Adjustment View Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Tapping color selection opens color wheel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ColorAdjustmentView()));

      // Find the primary color row
      final primaryColorTile = find.text('Primary color');
      expect(primaryColorTile, findsOneWidget);

      // Tap on the primary color selector
      await tester.tap(primaryColorTile);
      await tester.pumpAndSettle();

      // Verify that the color picker dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('Pressing reset button restores default theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ColorAdjustmentView()));

      // Find the scrollable widget
      final scrollableFinder = find.byType(SingleChildScrollView);
      final resetButtonFinder = find.text('Reset to default');

      // Ensure reset button is present
      expect(resetButtonFinder, findsOneWidget);

      // Scroll down to make the reset button visible
      await tester.drag(scrollableFinder, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap the reset button
      await tester.tap(resetButtonFinder);
    });
  });

  group('AppTheme Tests', () {
    setUp(() async {
      // Ensure SharedPreferences is initialized with a mock instance
      SharedPreferences.setMockInitialValues({});
    });

    test('resetToDefault should reset theme and clear preferences', () async {
      final prefs = await SharedPreferences.getInstance();

      // Set a dummy theme in SharedPreferences
      await prefs.setString(
          'app_theme', jsonEncode({'primaryColor': '0xFF123456'}));

      await AppTheme.resetToDefault();

      // Ensure the theme is reset
      expect(AppTheme.theme.primaryColor, const Color.fromRGBO(146, 35, 56, 1));

      // Verify that SharedPreferences no longer contains a saved theme
      expect(prefs.getString('app_theme'), isNull);
    });

    test(
        'loadSavedTheme should use default theme if preferences are empty or invalid',
        () async {
      await AppTheme.loadSavedTheme();

      // Ensure it falls back to default theme values
      expect(AppTheme.theme.primaryColor, const Color.fromRGBO(146, 35, 56, 1));
    });

    test('loadSavedTheme should load a saved theme from SharedPreferences',
        () async {
      final prefs = await SharedPreferences.getInstance();

      // Mock a stored theme
      final mockThemeData = {
        'primaryColor': '0xFF123456',
        'secondaryColor': '0xFF654321',
        'backgroundColor': '0xFFFFFFFF',
        'primaryTextColor': '0xFF000000',
        'secondaryTextColor': '0xFFFFFFFF',
        'cardColor': '0xFFCCCCCC',
      };

      await prefs.setString('app_theme', jsonEncode(mockThemeData));

      await AppTheme.loadSavedTheme();

      // Check if the theme was correctly loaded
      expect(AppTheme.theme.primaryColor, const Color(0xFF123456));
      expect(AppTheme.theme.colorScheme.secondary, const Color(0xFF654321));
      expect(AppTheme.theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(
          AppTheme.theme.textTheme.bodyLarge?.color, const Color(0xFF000000));
      expect(AppTheme.theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(AppTheme.theme.cardColor, const Color(0xFFCCCCCC));
    });
  });
}
