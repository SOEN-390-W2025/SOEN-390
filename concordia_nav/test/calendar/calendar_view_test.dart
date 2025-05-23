// ignore_for_file: depend_on_referenced_packages

import 'dart:collection';

import 'package:calendar_view/calendar_view.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/repositories/calendar.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_link_view.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_selection_view.dart';
import 'package:concordia_nav/ui/setting/calendar/calendar_view.dart';
import 'package:concordia_nav/utils/calendar_selection_viewmodel.dart';
import 'package:concordia_nav/utils/calendar_viewmodel.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

import '../settings/calendar_view_test.mocks.dart';
import 'calendar_repository_test.mocks.dart';
import 'calendar_view_test.mocks.dart';

@GenerateMocks(
    [CalendarRepository, CalendarSelectionViewModel, CalendarViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();

  late CalendarRepository calendarRepository;
  late MockDeviceCalendarPlugin mockPlugin;
  late MockCalendarViewModel mockCalendarViewModel;

  setUp(() {
    mockPlugin = MockDeviceCalendarPlugin();
    calendarRepository = CalendarRepository();
    calendarRepository.plugin = mockPlugin;
    mockCalendarViewModel = MockCalendarViewModel();
  });

  group('CalendarView Widget Tests', () {
    test('getNextClassEvent returns the next event', () async {
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final startTime = DateTime.now()
          .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);

      when(mockPlugin.retrieveEvents(any, any))
          .thenAnswer((_) async => Result<UnmodifiableListView<Event>>()
            ..data = UnmodifiableListView<Event>([
              Event(
                'event1',
                eventId: 'event1',
                title: 'Math Class',
                description: 'Description 1',
                start: TZDateTime.from(startTime, local),
                end: TZDateTime.from(endTime, local),
                allDay: false,
                location: 'Location 1',
              ),
            ]));

      final nextEvent = await calendarRepository.getNextClassEvent([calendar1]);

      expect(nextEvent, isNotNull);
      expect(nextEvent!.title, 'Math Class');
    });

    test('getNextClassEvent returns null when no events are found', () async {
      final calendar1 = UserCalendar('1', 'Calendar 1');

      when(mockPlugin.retrieveEvents(any, any)).thenAnswer(
          (_) async => Result<UnmodifiableListView<Event>>()..data = null);

      final nextEvent = await calendarRepository.getNextClassEvent([calendar1]);

      expect(nextEvent, isNull);
    });

    // Tests for getNextClassRoom
    test('getNextClassRoom returns ConcordiaRoom based on event location',
        () async {
      final mockCalendar = UserCalendar('1', 'Calendar 1');

      final startTime = DateTime.now()
          .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);
      const building = BuildingRepository.mb;

      final MockBuildingViewModel mockBuildingViewModel =
          MockBuildingViewModel();

      when(mockBuildingViewModel.getBuildingByAbbreviation('MB'))
          .thenReturn(building);

      when(mockPlugin.retrieveEvents(any, any))
          .thenAnswer((_) async => Result<UnmodifiableListView<Event>>()
            ..data = UnmodifiableListView<Event>([
              Event(
                'event1',
                eventId: 'event1',
                title: 'Math Class',
                description: 'Description 1',
                start: TZDateTime.from(startTime, local),
                end: TZDateTime.from(endTime, local),
                allDay: false,
                location: 'MB S2.330',
              ),
            ]));

      final nextClassRoom = await calendarRepository
          .getNextClassRoom([mockCalendar], mockBuildingViewModel);

      expect(nextClassRoom, isNotNull);
      expect(nextClassRoom!.roomNumber, '330');
      expect(nextClassRoom.floor.floorNumber, 'S2');
    });

    test('getNextClassRoom returns null if location is missing or invalid',
        () async {
      final mockCalendar = UserCalendar('1', 'Calendar 1');

      final startTime = DateTime.now()
          .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);

      final MockBuildingViewModel mockBuildingViewModel =
          MockBuildingViewModel();

      when(mockBuildingViewModel.getBuildingByAbbreviation('bababooey'))
          .thenReturn(null);

      when(mockPlugin.retrieveEvents(any, any))
          .thenAnswer((_) async => Result<UnmodifiableListView<Event>>()
            ..data = UnmodifiableListView<Event>([
              Event(
                'event1',
                eventId: 'event1',
                title: 'Math Class',
                description: 'Description 1',
                start: TZDateTime.from(startTime, local),
                end: TZDateTime.from(endTime, local),
                allDay: false,
                location: 'bababooey',
              ),
            ]));

      final nextClassRoom = await calendarRepository
          .getNextClassRoom([mockCalendar], mockBuildingViewModel);

      expect(nextClassRoom, isNull);
    });

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

    testWidgets('initialize CalendarView Widget with selected Calendar',
        (WidgetTester tester) async {
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final startTime = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 2, minute: 30, second: 0, millisecond: 0);
      final startTime2 = DateTime.now()
          .copyWith(hour: 3, minute: 0, second: 0, millisecond: 0);
      final endTime2 = DateTime.now()
          .copyWith(hour: 4, minute: 30, second: 0, millisecond: 0);
      final calendarEvent = UserCalendarEvent(
          calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');
      final calendarEvent2 = UserCalendarEvent(
          calendar1, '1', 'nooo', startTime2, endTime2, 'NOOO', 'H 837');
      final calendarEventData = CalendarEventData(
          title: calendarEvent.title,
          date: calendarEvent.localStart,
          description: calendarEvent.description,
          startTime: calendarEvent.localStart,
          endTime: calendarEvent.localEnd,
          color: Colors.cyan,
          event: calendarEvent);
      final calendarEventData2 = CalendarEventData(
          title: calendarEvent2.title,
          date: calendarEvent2.localStart,
          description: calendarEvent2.description,
          startTime: calendarEvent2.localStart,
          endTime: calendarEvent2.localEnd,
          color: Colors.greenAccent,
          event: calendarEvent2);
      final calendarEventDatas = [calendarEventData, calendarEventData2];
      when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
          .thenAnswer((_) async => {});
      when(mockCalendarViewModel.getCalendarEventData())
          .thenReturn(calendarEventDatas);
      when(mockCalendarViewModel.isLoading).thenReturn(false);
      when(mockCalendarViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
              selectedCalendar: calendar1,
              calendarViewModel: mockCalendarViewModel),
        ),
      );
      await tester.pump();

      // CalendarView page is displayed and first event is shown
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text(calendarEventData.title), findsOneWidget);
    });

    testWidgets(
        'an error message is displayed if calendarviewmodel provides one',
        (WidgetTester tester) async {
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final startTime = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 2, minute: 30, second: 0, millisecond: 0);
      final startTime2 = DateTime.now()
          .copyWith(hour: 3, minute: 0, second: 0, millisecond: 0);
      final endTime2 = DateTime.now()
          .copyWith(hour: 4, minute: 30, second: 0, millisecond: 0);
      final calendarEvent = UserCalendarEvent(
          calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');
      final calendarEvent2 = UserCalendarEvent(
          calendar1, '1', 'nooo', startTime2, endTime2, 'NOOO', 'H 837');
      final calendarEventData = CalendarEventData(
          title: calendarEvent.title,
          date: calendarEvent.localStart,
          description: calendarEvent.description,
          startTime: calendarEvent.localStart,
          endTime: calendarEvent.localEnd,
          color: Colors.cyan,
          event: calendarEvent);
      final calendarEventData2 = CalendarEventData(
          title: calendarEvent2.title,
          date: calendarEvent2.localStart,
          description: calendarEvent2.description,
          startTime: calendarEvent2.localStart,
          endTime: calendarEvent2.localEnd,
          color: Colors.greenAccent,
          event: calendarEvent2);
      final calendarEventDatas = [calendarEventData, calendarEventData2];
      when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
          .thenAnswer((_) async => {});
      when(mockCalendarViewModel.getCalendarEventData())
          .thenReturn(calendarEventDatas);
      when(mockCalendarViewModel.isLoading).thenReturn(false);
      when(mockCalendarViewModel.errorMessage).thenReturn('Test Error');

      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
              selectedCalendar: calendar1,
              calendarViewModel: mockCalendarViewModel),
        ),
      );
      await tester.pump();

      // Error message is diplayed on screen
      expect(find.text('Test Error'), findsOneWidget);
    });

    testWidgets('a circular progress indicator is displayed if loading',
        (WidgetTester tester) async {
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final startTime = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 2, minute: 30, second: 0, millisecond: 0);
      final startTime2 = DateTime.now()
          .copyWith(hour: 3, minute: 0, second: 0, millisecond: 0);
      final endTime2 = DateTime.now()
          .copyWith(hour: 4, minute: 30, second: 0, millisecond: 0);
      final calendarEvent = UserCalendarEvent(
          calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');
      final calendarEvent2 = UserCalendarEvent(
          calendar1, '1', 'nooo', startTime2, endTime2, 'NOOO', 'H 837');
      final calendarEventData = CalendarEventData(
          title: calendarEvent.title,
          date: calendarEvent.localStart,
          description: calendarEvent.description,
          startTime: calendarEvent.localStart,
          endTime: calendarEvent.localEnd,
          color: Colors.cyan,
          event: calendarEvent);
      final calendarEventData2 = CalendarEventData(
          title: calendarEvent2.title,
          date: calendarEvent2.localStart,
          description: calendarEvent2.description,
          startTime: calendarEvent2.localStart,
          endTime: calendarEvent2.localEnd,
          color: Colors.greenAccent,
          event: calendarEvent2);
      final calendarEventDatas = [calendarEventData, calendarEventData2];
      when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
          .thenAnswer((_) async => {});
      when(mockCalendarViewModel.getCalendarEventData())
          .thenReturn(calendarEventDatas);
      when(mockCalendarViewModel.isLoading).thenReturn(true);
      when(mockCalendarViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: CalendarView(
              selectedCalendar: calendar1,
              calendarViewModel: mockCalendarViewModel),
        ),
      );
      await tester.pump();

      // CircularProgressIndicator is displayed on screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping event opens drawer', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final calendar1 = UserCalendar('1', 'Calendar 1');
        final startTime = DateTime.now()
            .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
        final endTime = DateTime.now()
            .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);
        final startTime2 = DateTime.now()
            .copyWith(hour: 3, minute: 0, second: 0, millisecond: 0);
        final endTime2 = DateTime.now()
            .copyWith(hour: 4, minute: 30, second: 0, millisecond: 0);
        final calendarEvent = UserCalendarEvent(
            calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');
        final calendarEvent2 = UserCalendarEvent(
            calendar1, '1', 'nooo', startTime2, endTime2, 'NOOO', 'B 837');
        final calendarEventData = CalendarEventData(
            title: calendarEvent.title,
            date: calendarEvent.localStart,
            description: calendarEvent.description,
            startTime: calendarEvent.localStart,
            endTime: calendarEvent.localEnd,
            color: Colors.cyan,
            event: calendarEvent);
        final calendarEventData2 = CalendarEventData(
            title: calendarEvent2.title,
            date: calendarEvent2.localStart,
            description: calendarEvent2.description,
            startTime: calendarEvent2.localStart,
            endTime: calendarEvent2.localEnd,
            color: Colors.greenAccent,
            event: calendarEvent2);
        final calendarEventDatas = [calendarEventData, calendarEventData2];
        final startFormat =
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
        final endFormat =
            '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';

        when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
            .thenAnswer((_) async => {});
        when(mockCalendarViewModel.getCalendarEventData())
            .thenReturn(calendarEventDatas);
        when(mockCalendarViewModel.isLoading).thenReturn(false);
        when(mockCalendarViewModel.errorMessage).thenReturn(null);
        when(mockCalendarViewModel.formatEventTime(calendarEvent))
            .thenReturn('$startFormat - $endFormat');

        await tester.pumpWidget(
          MaterialApp(
            home: CalendarView(
                selectedCalendar: calendar1,
                calendarViewModel: mockCalendarViewModel),
          ),
        );
        await tester.pump();

        // simulate tapping an event
        final container = find
            .ancestor(
                of: find.text(calendarEvent.title),
                matching: find.byType(Container))
            .first;
        await tester.tapAt(tester.getCenter(container));

        // wait for drawer to fetch needed data and display
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // eventDetailsDrawer is displayed
        expect(find.text('Directions'), findsOneWidget);
        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });
    });

    testWidgets(
        'tapping event opens drawer with unavailable directions when locationField null',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        final calendar1 = UserCalendar('1', 'Calendar 1');
        final startTime = DateTime.now()
            .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
        final endTime = DateTime.now()
            .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);
        final startTime2 = DateTime.now()
            .copyWith(hour: 3, minute: 0, second: 0, millisecond: 0);
        final endTime2 = DateTime.now()
            .copyWith(hour: 4, minute: 30, second: 0, millisecond: 0);
        final calendarEvent = UserCalendarEvent(
            calendar1, '1', 'waaa', startTime, endTime, 'WAAA', null);
        final calendarEvent2 = UserCalendarEvent(
            calendar1, '1', 'nooo', startTime2, endTime2, 'NOOO', 'H 837');
        final calendarEventData = CalendarEventData(
            title: calendarEvent.title,
            date: calendarEvent.localStart,
            description: calendarEvent.description,
            startTime: calendarEvent.localStart,
            endTime: calendarEvent.localEnd,
            color: Colors.cyan,
            event: calendarEvent);
        final calendarEventData2 = CalendarEventData(
            title: calendarEvent2.title,
            date: calendarEvent2.localStart,
            description: calendarEvent2.description,
            startTime: calendarEvent2.localStart,
            endTime: calendarEvent2.localEnd,
            color: Colors.greenAccent,
            event: calendarEvent2);
        final calendarEventDatas = [calendarEventData, calendarEventData2];
        final startFormat =
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
        final endFormat =
            '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';

        when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
            .thenAnswer((_) async => {});
        when(mockCalendarViewModel.getCalendarEventData())
            .thenReturn(calendarEventDatas);
        when(mockCalendarViewModel.isLoading).thenReturn(false);
        when(mockCalendarViewModel.errorMessage).thenReturn(null);
        when(mockCalendarViewModel.formatEventTime(calendarEvent))
            .thenReturn('$startFormat - $endFormat');

        await tester.pumpWidget(
          MaterialApp(
            home: CalendarView(
                selectedCalendar: calendar1,
                calendarViewModel: mockCalendarViewModel),
          ),
        );
        await tester.pump();

        // simulate tapping an event
        final container = find
            .ancestor(
                of: find.text(calendarEvent.title),
                matching: find.byType(Container))
            .first;
        await tester.tapAt(tester.getCenter(container));

        // wait for drawer to fetch needed data and display
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // eventDetailsDrawer is displayed
        expect(find.text('Not Available'), findsOneWidget);
        expect(find.byIcon(Icons.access_time), findsOneWidget);
      });
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
      final MockCalendarSelectionViewModel mockSelectionViewModel =
          MockCalendarSelectionViewModel();
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
        '/CalendarSelectionView': (context) =>
            CalendarSelectionView(calendarViewModel: mockSelectionViewModel),
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

  group('CalendarSelectionView Widget tests', () {
    testWidgets('tapping event opens drawer and navigate to outdoor directions',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        final calendar1 = UserCalendar('1', 'Calendar 1');
        final startTime = DateTime.now()
            .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
        final endTime = DateTime.now()
            .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);
        final calendarEvent = UserCalendarEvent(
            calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 637');
        final calendarEventData = CalendarEventData(
            title: calendarEvent.title,
            date: calendarEvent.localStart,
            description: calendarEvent.description,
            startTime: calendarEvent.localStart,
            endTime: calendarEvent.localEnd,
            color: Colors.cyan,
            event: calendarEvent);

        when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
            .thenAnswer((_) async => {});
        when(mockCalendarViewModel.getCalendarEventData())
            .thenReturn([calendarEventData]);
        when(mockCalendarViewModel.isLoading).thenReturn(false);
        when(mockCalendarViewModel.errorMessage).thenReturn(null);
        when(mockCalendarViewModel.formatEventTime(calendarEvent)).thenReturn(
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}');

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/NextClassDirectionsPreview': (context) {
                return Container();
              },
              '/OutdoorLocationMapView': (context) => Scaffold(
                    appBar: AppBar(title: const Text('Outdoor Location Map')),
                    body: const Center(child: Text('No content available')),
                  ),
            },
            home: CalendarView(
                selectedCalendar: calendar1,
                calendarViewModel: mockCalendarViewModel),
          ),
        );

        await tester.pump();

        // simulate tapping an event
        final container = find
            .ancestor(
                of: find.text(calendarEvent.title),
                matching: find.byType(Container))
            .first;
        await tester.tapAt(tester.getCenter(container));

        // wait for drawer to fetch needed data and display
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify eventDetailsDrawer is displayed
        expect(find.text('Directions'), findsOneWidget);
        await tester.tap(find.text('Directions'));
        await tester.pumpAndSettle();
      });
    });

    testWidgets(
        'tapping event opens drawer and does not navigate to directions',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        final calendar1 = UserCalendar('1', 'Calendar 1');
        final startTime = DateTime.now()
            .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
        final endTime = DateTime.now()
            .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);
        final calendarEvent = UserCalendarEvent(
            calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'B 937');
        final calendarEventData = CalendarEventData(
            title: calendarEvent.title,
            date: calendarEvent.localStart,
            description: calendarEvent.description,
            startTime: calendarEvent.localStart,
            endTime: calendarEvent.localEnd,
            color: Colors.cyan,
            event: calendarEvent);

        when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
            .thenAnswer((_) async => {});
        when(mockCalendarViewModel.getCalendarEventData())
            .thenReturn([calendarEventData]);
        when(mockCalendarViewModel.isLoading).thenReturn(false);
        when(mockCalendarViewModel.errorMessage).thenReturn(null);
        when(mockCalendarViewModel.formatEventTime(calendarEvent)).thenReturn(
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}');

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/NextClassDirectionsPreview': (context) {
                return Container();
              },
            },
            home: CalendarView(
                selectedCalendar: calendar1,
                calendarViewModel: mockCalendarViewModel),
          ),
        );

        await tester.pump();

        // simulate tapping an event
        final container = find
            .ancestor(
                of: find.text(calendarEvent.title),
                matching: find.byType(Container))
            .first;
        await tester.tapAt(tester.getCenter(container));

        // wait for drawer to fetch needed data and display
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify eventDetailsDrawer is displayed
        expect(find.text('Directions'), findsNothing);
      });
    });

    testWidgets('tapping event opens drawer and navigates to directions',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        final calendar1 = UserCalendar('1', 'Calendar 1');
        final startTime = DateTime.now()
            .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0);
        final endTime = DateTime.now()
            .copyWith(hour: 12, minute: 30, second: 0, millisecond: 0);
        final calendarEvent = UserCalendarEvent(
            calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');
        final calendarEventData = CalendarEventData(
            title: calendarEvent.title,
            date: calendarEvent.localStart,
            description: calendarEvent.description,
            startTime: calendarEvent.localStart,
            endTime: calendarEvent.localEnd,
            color: Colors.cyan,
            event: calendarEvent);

        when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
            .thenAnswer((_) async => {});
        when(mockCalendarViewModel.getCalendarEventData())
            .thenReturn([calendarEventData]);
        when(mockCalendarViewModel.isLoading).thenReturn(false);
        when(mockCalendarViewModel.errorMessage).thenReturn(null);
        when(mockCalendarViewModel.formatEventTime(calendarEvent)).thenReturn(
            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}');

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/NextClassDirectionsPreview': (context) {
                return Container();
              },
            },
            home: CalendarView(
                selectedCalendar: calendar1,
                calendarViewModel: mockCalendarViewModel),
          ),
        );

        await tester.pump();

        // simulate tapping an event
        final container = find
            .ancestor(
                of: find.text(calendarEvent.title),
                matching: find.byType(Container))
            .first;
        await tester.tapAt(tester.getCenter(container));

        // wait for drawer to fetch needed data and display
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify eventDetailsDrawer is displayed
        expect(find.text('Directions'), findsOneWidget);
        await tester.tap(find.text('Directions'));
        await tester.pumpAndSettle();

        // Verify navigation happens by checking if we're redirected to the directions screen
        expect(find.byType(Container), findsOneWidget);
      });
    });

    testWidgets('navigates to CalendarView when select Calendar',
        (WidgetTester tester) async {
      // Arrange CalendarSelectionView
      final MockCalendarSelectionViewModel mockSelectionViewModel =
          MockCalendarSelectionViewModel();
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendars = [calendar1, calendar2];
      when(mockSelectionViewModel.loadCalendars()).thenAnswer((_) async => {});
      when(mockSelectionViewModel.calendars).thenReturn(calendars);

      // Arrange CalendarView
      final startTime = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 2, minute: 30, second: 0, millisecond: 0);
      final startTime2 = DateTime.now()
          .copyWith(hour: 3, minute: 0, second: 0, millisecond: 0);
      final endTime2 = DateTime.now()
          .copyWith(hour: 4, minute: 30, second: 0, millisecond: 0);
      final calendarEvent = UserCalendarEvent(
          calendar1, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');
      final calendarEvent2 = UserCalendarEvent(
          calendar1, '1', 'nooo', startTime2, endTime2, 'NOOO', 'H 837');
      final calendarEventData = CalendarEventData(
          title: calendarEvent.title,
          date: calendarEvent.localStart,
          description: calendarEvent.description,
          startTime: calendarEvent.localStart,
          endTime: calendarEvent.localEnd,
          color: Colors.cyan,
          event: calendarEvent);
      final calendarEventData2 = CalendarEventData(
          title: calendarEvent2.title,
          date: calendarEvent2.localStart,
          description: calendarEvent2.description,
          startTime: calendarEvent2.localStart,
          endTime: calendarEvent2.localEnd,
          color: Colors.greenAccent,
          event: calendarEvent2);
      final calendarEventDatas = [calendarEventData, calendarEventData2];
      when(mockCalendarViewModel.initialize(selectedCalendar: calendar1))
          .thenAnswer((_) async => {});
      when(mockCalendarViewModel.getCalendarEventData())
          .thenReturn(calendarEventDatas);
      when(mockCalendarViewModel.isLoading).thenReturn(false);
      when(mockCalendarViewModel.errorMessage).thenReturn(null);

      // define routes needed for this test
      final routes = {
        '/': (context) =>
            CalendarSelectionView(calendarViewModel: mockSelectionViewModel),
        '/CalendarView': (context) => CalendarView(
            selectedCalendar: calendar1,
            calendarViewModel: mockCalendarViewModel),
      };

      // Build the CalendarSelectionView widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));
      await tester.pump();

      // find Calendar 1 and tap it
      expect(find.text('Calendar 1'), findsOneWidget);
      await tester.tap(find.text('Calendar 1'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarView), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });
  });
}
