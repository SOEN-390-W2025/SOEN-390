import 'package:concordia_nav/data/repositories/calendar.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_link_view.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_selection_view.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_view.dart';
import 'package:concordia_nav/utils/calendar_selection_viewmodel.dart';
import 'package:device_calendar/src/models/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'calendar_repository_test.mocks.dart';
import 'calendar_selection_viewmodel_test.mocks.dart';

@GenerateMocks([CalendarRepository, CalendarSelectionViewModel])
void main() {
  late CalendarRepository calendarRepository;
  late MockDeviceCalendarPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockDeviceCalendarPlugin();
    calendarRepository = CalendarRepository();
    calendarRepository.plugin = mockPlugin;
  });

  group('CalendarView Widget Tests', () {
    testWidgets('renders CalendarView with non-constant key',
        (WidgetTester tester) async {
      const testKey = Key('nonConstantKey');

      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarView(key: testKey),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('Calendar').first, findsOneWidget);
    });

    testWidgets('renders CalendarView with constant key',
        (WidgetTester tester) async {
      const testKey = ValueKey('constantKey');

      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarView(key: testKey),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('Calendar').first, findsOneWidget);
    });

    testWidgets('finds at least one widget with Calendar text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarView(),
        ),
      );

      expect(find.textContaining('Calendar').first, findsOneWidget);
    });
  });

  group('CalendarLinkView Widget Tests', () {
    testWidgets(
      'displays permission denied message when permission is not granted',
      (WidgetTester tester) async {
        when(mockPlugin.hasPermissions())
            .thenAnswer((_) async => Result<bool>()..data = false);
        when(mockPlugin.requestPermissions())
            .thenAnswer((_) async => Result<bool>()..data = false);

        await tester.pumpWidget(
          MaterialApp(
            home: CalendarLinkView(calendarRepository: calendarRepository),
          ),
        );

        await tester.tap(find.text('Link'));
        await tester.pumpAndSettle();

        expect(find.text('Permission denied. Please enable it in settings.'),
            findsOneWidget);
      },
    );

    testWidgets('navigates to CalendarSelectionView when permission is granted',
        (WidgetTester tester) async {
      final MockCalendarSelectionViewModel mockSelectionViewModel = MockCalendarSelectionViewModel(); 
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendars = [calendar1, calendar2];
      when(mockPlugin.hasPermissions())
          .thenAnswer((_) async => Result<bool>()..data = true);
      when(mockPlugin.requestPermissions())
          .thenAnswer((_) async => Result<bool>()..data = true);
      when(mockSelectionViewModel.loadCalendars()).thenAnswer((_) async => {});
      when(mockSelectionViewModel.calendars).thenReturn(calendars);

      // define routes needed for this test
      final routes = {
        '/': (context) =>
            CalendarLinkView(calendarRepository: calendarRepository),
        '/CalendarSelectionView': (context) => CalendarSelectionView(
              calendarViewModel: mockSelectionViewModel),
      };

      // Build the CalendarLinkView widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));

      await tester.tap(find.text('Link'));
      await tester.pumpAndSettle();

      expect(find.text('Calendar Selection'), findsOneWidget);
    });

    testWidgets('displays message when there is currently no calendar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarLinkView(),
        ),
      );

      expect(find.text('There is currently no calendar'), findsOneWidget);
    });
  });
}
