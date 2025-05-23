// ignore_for_file: depend_on_referenced_packages

import 'package:concordia_nav/data/repositories/calendar.dart';
import 'package:concordia_nav/utils/calendar_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

import '../indoor_map/indoor_routing_service_test.mocks.dart';

@GenerateMocks([CalendarRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();

  late MockCalendarRepository mockCalendarRepository;

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
  });

  group('CalendarViewModel tests', () {
    test('initialize with no selectedCalendar param defaults to all', () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendars = [calendar1, calendar2];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      final startDate = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      when(mockCalendarRepository.getEvents(
              calendars, const Duration(days: 7), startDate))
          .thenAnswer((_) async => []);

      // Act
      final calendarViewModel = CalendarViewModel();
      calendarViewModel.calendarRepository = mockCalendarRepository;

      await calendarViewModel.initialize();

      // Assert
      expect(calendarViewModel.allCalendars, calendars);
      expect(calendarViewModel.selectedCalendars, calendars);
      expect(calendarViewModel.events, []);
    });

    test('initialize with selectedCalendar param includes only selected',
        () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendars = [calendar1, calendar2];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      final startDate = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      when(mockCalendarRepository.getEvents(
              calendars, const Duration(days: 7), startDate))
          .thenAnswer((_) async => []);

      // Act
      final calendarViewModel = CalendarViewModel();
      calendarViewModel.calendarRepository = mockCalendarRepository;

      await calendarViewModel.initialize(selectedCalendar: calendar1);

      // Assert
      expect(calendarViewModel.allCalendars, calendars);
      expect(calendarViewModel.selectedCalendars, [calendar1]);
    });

    test('initialize returns error if permissions denied', () async {
      // Arrange: checkPermissions denied mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => false);

      // Act
      final calendarViewModel = CalendarViewModel();
      calendarViewModel.calendarRepository = mockCalendarRepository;

      await calendarViewModel.initialize();

      expect(calendarViewModel.errorMessage, 'Calendar permission denied');
    });

    test(
        'getCalendarEventData converts UserCalendarEvents to CalendarEventdata',
        () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendars = [calendar1, calendar2];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      final startDate = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      when(mockCalendarRepository.getEvents(
              calendars, const Duration(days: 7), startDate))
          .thenAnswer((_) async => []);

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
      final calendarEvents = [calendarEvent, calendarEvent2];

      final calendarViewModel = CalendarViewModel();
      calendarViewModel.calendarRepository = mockCalendarRepository;
      await calendarViewModel.initialize();

      calendarViewModel.eventsList = calendarEvents;

      final eventDataList = calendarViewModel.getCalendarEventData();

      expect(eventDataList, isNotEmpty);
      expect(eventDataList[0].title, calendarEvent.title);
    });

    test('formatEventTime formats event time', () {
      final calendar = UserCalendar('1', 'Calendar 1');
      final startTime = DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final endTime = DateTime.now()
          .copyWith(hour: 2, minute: 30, second: 0, millisecond: 0);
      final calendarEvent = UserCalendarEvent(
          calendar, '1', 'waaa', startTime, endTime, 'WAAA', 'H 937');

      // Act
      final formattedEvent = CalendarViewModel().formatEventTime(calendarEvent);

      // Assert
      final startFormat =
          '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
      final endFormat =
          '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';

      expect(formattedEvent, '$startFormat - $endFormat');
    });

    test('getBuildingAbbreviation returns building abbreviation from location',
        () async {
      final buildingAbbreviation =
          CalendarViewModel().getBuildingAbbreviation('H 937');

      expect(buildingAbbreviation, 'H');
    });

    test('getBuildingAbbreviation returns empty if invalid location', () async {
      final buildingAbbreviation =
          CalendarViewModel().getBuildingAbbreviation('937');

      expect(buildingAbbreviation, '');
    });
  });
}
