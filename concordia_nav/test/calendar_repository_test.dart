import 'dart:collection';

import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:concordia_nav/data/repositories/calendar.dart';
import 'calendar_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DeviceCalendarPlugin>()])
void main() {
  group('UserCalendar', () {
    test('UserCalendar instances with the same calendarId are equal', () {
      // Arrange
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('1', 'Calendar 1');

      // Act & Assert
      expect(calendar1, equals(calendar2));
    });

    test('UserCalendar instances with different calendarId are not equal', () {
      // Arrange
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');

      // Act & Assert
      expect(calendar1, isNot(equals(calendar2)));
    });

    test(
        'UserCalendar instances with the same calendarId have the same hashCode',
        () {
      // Arrange
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('1', 'Calendar 1');

      // Act & Assert
      expect(calendar1.hashCode, equals(calendar2.hashCode));
    });

    test(
        'UserCalendar instances with different calendarId have different hashCode',
        () {
      // Arrange
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');

      // Act & Assert
      expect(calendar1.hashCode, isNot(equals(calendar2.hashCode)));
    });
  });

  group('CalendarRepository', () {
    late CalendarRepository calendarRepository;
    late MockDeviceCalendarPlugin mockPlugin;

    setUp(() {
      mockPlugin = MockDeviceCalendarPlugin();
      calendarRepository = CalendarRepository();
      calendarRepository.plugin = mockPlugin; // Inject the mock plugin
    });

    // Test for checkPermissions()
    test('checkPermissions returns true when permissions are granted',
        () async {
      // Arrange
      when(mockPlugin.hasPermissions())
          .thenAnswer((_) async => Result<bool>()..data = true);
      when(mockPlugin.requestPermissions())
          .thenAnswer((_) async => Result<bool>()..data = true);

      // Act
      final result = await calendarRepository.checkPermissions();

      // Assert
      expect(result, true);
    });

    test('checkPermissions returns false when permissions are denied',
        () async {
      // Arrange
      when(mockPlugin.hasPermissions())
          .thenAnswer((_) async => Result<bool>()..data = false);
      when(mockPlugin.requestPermissions())
          .thenAnswer((_) async => Result<bool>()..data = false);

      // Act
      final result = await calendarRepository.checkPermissions();

      // Assert
      expect(result, false);
    });

    // Test for getUserCalendars()
    test(
        'getUserCalendars returns a list of UserCalendars when permissions are granted',
        () async {
      // Arrange
      when(mockPlugin.hasPermissions())
          .thenAnswer((_) async => Result<bool>()..data = true);
      when(mockPlugin.retrieveCalendars())
          .thenAnswer((_) async => Result<UnmodifiableListView<Calendar>>()
            ..data = UnmodifiableListView<Calendar>([
              Calendar(id: '1', name: 'Calendar 1'),
              Calendar(id: '2', name: 'Calendar 2'),
            ]));

      // Act
      final result = await calendarRepository.getUserCalendars();

      // Assert
      expect(result.length, 2);
      expect(result[0].calendarId, '1');
      expect(result[0].displayName, 'Calendar 1');
      expect(result[1].calendarId, '2');
      expect(result[1].displayName, 'Calendar 2');
    });

    test(
        'getUserCalendars throws an exception when unable to retrieve calendars',
        () async {
      // Arrange
      when(mockPlugin.hasPermissions())
          .thenAnswer((_) async => Result<bool>()..data = true);
      when(mockPlugin.retrieveCalendars())
          .thenAnswer((_) async => Result<UnmodifiableListView<Calendar>>());

      // Act & Assert
      expect(() async => await calendarRepository.getUserCalendars(),
          throwsException);
    });

    test('getEvents uses current UTC time when utcStart is null', () async {
      // Arrange
      final userCalendar = UserCalendar('1', 'Calendar 1');
      final currentUtcTime = DateTime.now().toUtc();
      final endDate = currentUtcTime.add(const Duration(days: 1));

      when(mockPlugin.retrieveEvents(any, any))
          .thenAnswer((_) async => Result<UnmodifiableListView<Event>>()
            ..data = UnmodifiableListView<Event>([
              Event(
                'event1',
                eventId: 'event1',
                title: 'Event 1',
                description: 'Description 1',
                start: TZDateTime.from(currentUtcTime, local),
                end: TZDateTime.from(endDate, local),
                allDay: false,
                location: 'Location 1',
              ),
            ]));

      // Act
      final result = await calendarRepository
          .getEvents([userCalendar], const Duration(days: 1), null);

      // Assert
      expect(result.length, 1);
      expect(result[0].eventId, 'event1');
      expect(result[0].title, 'Event 1');
      expect(result[0].description, 'Description 1');
      expect(result[0].localStart, currentUtcTime);
      expect(result[0].localEnd, endDate);
      expect(result[0].locationField, 'Location 1');
    });

    test(
        'getEvents returns a list of UserCalendarEvents for the given time span',
        () async {
      // Arrange
      final userCalendar = UserCalendar('1', 'Calendar 1');
      final startDate = DateTime.now().toUtc();
      final endDate = startDate.add(const Duration(days: 1));

      when(mockPlugin.retrieveEvents(any, any))
          .thenAnswer((_) async => Result<UnmodifiableListView<Event>>()
            ..data = UnmodifiableListView<Event>([
              Event(
                'event1',
                eventId: 'event1',
                title: 'Event 1',
                description: 'Description 1',
                start: TZDateTime.from(startDate, local),
                end: TZDateTime.from(endDate, local),
                allDay: false,
                location: 'Location 1',
              ),
            ]));

      // Act
      final result = await calendarRepository
          .getEvents([userCalendar], const Duration(days: 1), startDate);

      // Assert
      expect(result.length, 1);
      expect(result[0].eventId, 'event1');
      expect(result[0].title, 'Event 1');
      expect(result[0].description, 'Description 1');
      expect(result[0].localStart, startDate);
      expect(result[0].localEnd, endDate);
      expect(result[0].locationField, 'Location 1');
    });

    // Test for getEventsOnLocalDate()
    test('getEventsOnLocalDate returns events for the given local date',
        () async {
      // Arrange
      final userCalendar = UserCalendar('1', 'Calendar 1');
      final startDate = DateTime.now().add(const Duration(days: 1)).toUtc();
      final endDate = startDate.add(const Duration(days: 1));

      when(mockPlugin.retrieveEvents(any, any))
          .thenAnswer((_) async => Result<UnmodifiableListView<Event>>()
            ..data = UnmodifiableListView<Event>([
              Event(
                '1',
                eventId: '1',
                title: 'Event 1',
                description: 'Description 1',
                start: TZDateTime.from(startDate, local),
                end: TZDateTime.from(endDate, local),
                allDay: false,
                location: 'Location 1',
              ),
            ]));

      // Act
      final result =
          await calendarRepository.getEventsOnLocalDate([userCalendar], 1);

      // Assert
      expect(result.length, 1);
      expect(result[0].eventId, '1');
      expect(result[0].title, 'Event 1');
      expect(result[0].description, 'Description 1');
      expect(result[0].localStart, startDate);
      expect(result[0].localEnd, endDate);
      expect(result[0].locationField, 'Location 1');
    });
  });
}
