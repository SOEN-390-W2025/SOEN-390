import 'package:concordia_nav/data/repositories/calendar.dart';
import 'package:concordia_nav/ui/setting/accessibility/accessibility_page.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_link_view.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_selection_view.dart';
import 'package:concordia_nav/ui/setting/settings_page.dart';
import 'package:concordia_nav/widgets/settings_tile.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

import '../calendar/calendar_repository_test.mocks.dart';
import '../calendar/calendar_view_test.mocks.dart';

void main() {
  group('SettingsPage', () {
    late MockDeviceCalendarPlugin mockPlugin;

    setUp(() {
      mockPlugin = MockDeviceCalendarPlugin();
    });

    testWidgets(
      'navigates to CalendarSelectionView when permissions are granted',
      (WidgetTester tester) async {
        // Arrange: Mock hasPermissions to return true
        when(mockPlugin.hasPermissions())
            .thenAnswer((_) async => Result<bool>()..data = true);
        when(mockPlugin.requestPermissions())
            .thenAnswer((_) async => Result<bool>()..data = true);

        // Arrange: CalendarSelectionViewModel mock
        final MockCalendarSelectionViewModel mockSelectionViewModel = MockCalendarSelectionViewModel(); 
        final calendar1 = UserCalendar('1', 'Calendar 1');
        final calendar2 = UserCalendar('2', 'Calendar 2');
        final calendars = [calendar1, calendar2];
        when(mockSelectionViewModel.loadCalendars()).thenAnswer((_) async => {});
        when(mockSelectionViewModel.calendars).thenReturn(calendars);

        // define routes needed for this test
        final routes = {
          '/': (context) => SettingsPage(plugin: mockPlugin),
          '/CalendarSelectionView': (context) => CalendarSelectionView(
              calendarViewModel: mockSelectionViewModel),
        };

        // Build the SettingsPage widget
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/',
          routes: routes,
        ));

        // Simulate tapping the "My calendar" tile
        await tester.tap(find.text('My calendar'));
        await tester.pumpAndSettle(); // Wait for the navigation to complete

        // Assert that Navigator.push was called and navigated to CalendarSelectionView
        verify(mockPlugin.hasPermissions()).called(1);
        expect(find.byType(CalendarSelectionView), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to CalendarLinkView when permissions are not granted',
      (WidgetTester tester) async {
        // Arrange: Mock hasPermissions to return false
        when(mockPlugin.hasPermissions())
            .thenAnswer((_) async => Result<bool>()..data = false);
        when(mockPlugin.requestPermissions())
            .thenAnswer((_) async => Result<bool>()..data = false);

        // define routes needed for this test
        final routes = {
          '/': (context) => SettingsPage(plugin: mockPlugin),
          '/CalendarLinkView': (context) => const CalendarLinkView(),
        };

        // Build the SettingsPage widget
        await tester.pumpWidget(MaterialApp(
          initialRoute: '/',
          routes: routes,
        ));

        // Simulate tapping the "My calendar" tile
        await tester.tap(find.text('My calendar'));
        await tester.pumpAndSettle(); // Wait for the navigation to complete

        // Assert that Navigator.push was called and navigated to CalendarLinkView
        verify(mockPlugin.hasPermissions()).called(1);
        expect(find.byType(CalendarLinkView), findsOneWidget);
      },
    );
  });

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
      expect(find.byType(SettingsTile), findsNWidgets(6));
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
    });

    testWidgets('SettingsTile onPress is possible',
        (WidgetTester tester) async {
      // define routes needed for this test
      final routes = {
        '/': (context) => const SettingsPage(),
        '/AccessibilityPage': (context) => const AccessibilityPage(),
      };

      // Build the SettingsPage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));

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
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Tap on Contact SettingsTile
      await tester.tap(find.text('Contact'));
      await tester.pump();

      // Tap on Guide SettingsTile
      await tester.tap(find.text('Guide'));
      await tester.pump();
    });
  });
}
