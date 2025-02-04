import 'package:concordia_nav/ui/setting/settings_page.dart';
import 'package:concordia_nav/widgets/settings_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('settingsAppBar', () {
    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the SettingsPage widget
      await tester.pumpWidget(const MaterialApp(home: const SettingsPage()));

      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('appBar leading IconButton should include a back button',
        (WidgetTester tester) async {
      // Build the SettingsPage widget
      await tester.pumpWidget(const MaterialApp(home: const SettingsPage()));

      await tester.pump();

      // Find the leading IconButton
      final IconButton leadingIconButton = tester.widget(
        find.descendant(
            of: find.byType(AppBar), matching: find.byType(IconButton).first),
      );

      const expectedIcon = const Icon(Icons.arrow_back, color: Colors.white);
      final actualIcon = leadingIconButton.icon as Icon;

      expect(actualIcon.icon, expectedIcon.icon);
      expect(actualIcon.color, expectedIcon.color);
    });
  });

  group('settingTiles', () {
    testWidgets('list of SettingsTiles are present',
        (WidgetTester tester) async {
      // Build the SettingsPage widget
      await tester.pumpWidget(const MaterialApp(home: const SettingsPage()));

      // Verify that exactly 7 SettingsTile exist
      expect(find.byType(SettingsTile), findsNWidgets(7));
    });

    testWidgets('list of SettingsTiles are accurate',
        (WidgetTester tester) async {
      // Build the SettingsPage widget
      await tester.pumpWidget(const MaterialApp(home: const SettingsPage()));

      // Verify that the My Calendar SettingsTile text and icon are present
      expect(find.text('My calendar'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      // Verify that the Notifications SettingsTile text and icon are present
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Verify that the Preferences SettingsTile text and icon are present
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Verify that the Accessibility SettingsTile text and icon are present
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.byIcon(Icons.accessibility), findsOneWidget);

      // Verify that the Contact SettingsTile text and icon are present
      expect(find.text('Contact'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);

      // Verify that the Guide SettingsTile text and icon are present
      expect(find.text('Guide'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Verify that the Login SettingsTile text and icon are present
      expect(find.text('Login'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('SettingsTile onPress is possible',
        (WidgetTester tester) async {
      // Build the SettingsPage widget
      await tester.pumpWidget(const MaterialApp(home: const SettingsPage()));

      // Tap on My Calendar SettingsTile
      await tester.tap(find.text('My calendar'));
      await tester.pump();

      // Tap on Notifications SettingsTile
      await tester.tap(find.text('Notifications'));
      await tester.pump();

      // Tap on Preferences SettingsTile
      await tester.tap(find.text('Preferences'));
      await tester.pump();

      // Tap on Accessibility SettingsTile
      await tester.tap(find.text('Accessibility'));
      await tester.pump();

      // Tap on Contact SettingsTile
      await tester.tap(find.text('Contact'));
      await tester.pump();

      // Tap on Guide SettingsTile
      await tester.tap(find.text('Guide'));
      await tester.pump();

      // Tap on Login SettingsTile
      await tester.ensureVisible(find.text('Login'));
      await tester
          .pumpAndSettle(); // ensures and waits for the SettingsTile to be visible in the renderbox
      await tester.tap(find.text('Login'));
      await tester.pump();
    });
  });
}
