import 'package:concordia_nav/data/repositories/calendar.dart';
import 'package:concordia_nav/utils/calendar_selection_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../indoor_map/indoor_routing_service_test.mocks.dart';

@GenerateMocks([CalendarRepository])
void main() {
  late MockCalendarRepository mockCalendarRepository;

  setUp(() {
    mockCalendarRepository = MockCalendarRepository();
  });

  group('CalendarSelectionViewModel tests', (){
    test('loadCalendars updates the list of calendars', () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendars = [calendar1, calendar2];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      
      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.calendarRepository = mockCalendarRepository;
      
      // Act
      await calendarSelectionViewModel.loadCalendars();

      // Assert
      expect(calendarSelectionViewModel.calendars, isNotEmpty);
      expect(calendarSelectionViewModel.calendars, calendars);
    });

    test('loadCalendars throws exception if permissions not allowed', () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => false);
      
      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.calendarRepository = mockCalendarRepository;
      
      expect(calendarSelectionViewModel.loadCalendars(), throwsException);
    });

    test('selectCalendar adds calendarId to list', () {
      final calendar = UserCalendar('1', 'Calendar 1');

      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.selectCalendar(calendar);

      expect(calendarSelectionViewModel.isCalendarSelected(calendar), true);
    });

    test('unselectCalendar removes calendarId from list', () {
      final calendar = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');

      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.selectCalendar(calendar);
      calendarSelectionViewModel.selectCalendar(calendar2);

      expect(calendarSelectionViewModel.isCalendarSelected(calendar), true);
      expect(calendarSelectionViewModel.isCalendarSelected(calendar2), true);

      // calendar is unselected but calendar2 is still present
      calendarSelectionViewModel.unselectCalendar(calendar);
      expect(calendarSelectionViewModel.isCalendarSelected(calendar), false);
      expect(calendarSelectionViewModel.isCalendarSelected(calendar2), true);
    });

    test('toggleCalendarSelection swaps selection state of calendar', () {
      final calendar = UserCalendar('1', 'Calendar 1');

      final calendarSelectionViewModel = CalendarSelectionViewModel();
      // expected to select the calendar
      calendarSelectionViewModel.toggleCalendarSelection(calendar);
      expect(calendarSelectionViewModel.isCalendarSelected(calendar), true);

      //expected to unselect the calendar
      calendarSelectionViewModel.toggleCalendarSelection(calendar);
      expect(calendarSelectionViewModel.isCalendarSelected(calendar), false);
    });

    test('getSelectedCalendars returns the list of selected calendars', () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendar3 = UserCalendar('3', 'Calendar 3');
      final calendars = [calendar1, calendar2, calendar3];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      
      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.calendarRepository = mockCalendarRepository;
      await calendarSelectionViewModel.loadCalendars();
      calendarSelectionViewModel.selectCalendar(calendar1);
      calendarSelectionViewModel.selectCalendar(calendar3);

      // Act
      final selectedCalendars = calendarSelectionViewModel.getSelectedCalendars();

      // Assert
      expect(selectedCalendars[0], calendar1);
      expect(selectedCalendars[1], calendar3);
    });

    test('selectCalendarsByDisplayName selects calendar by its display name', () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendar3 = UserCalendar('3', 'Calendar 3');
      final calendars = [calendar1, calendar2, calendar3];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      
      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.calendarRepository = mockCalendarRepository;
      await calendarSelectionViewModel.loadCalendars();

      // Act
      calendarSelectionViewModel.selectCalendarsByDisplayName('Calendar 1');

      // Assert
      expect(calendarSelectionViewModel.isCalendarSelected(calendar1), true);
    });

    test('getSelectedCalendarsByDisplayName returns a list of calendars matching display name', () async {
      // Arrange: checkPermissions accepted mock
      when(mockCalendarRepository.checkPermissions())
          .thenAnswer((_) async => true);
      // Arrange: getUserCalendars mock
      final calendar1 = UserCalendar('1', 'Calendar 1');
      final calendar2 = UserCalendar('2', 'Calendar 2');
      final calendar3 = UserCalendar('3', 'Calendar 3');
      final calendars = [calendar1, calendar2, calendar3];
      when(mockCalendarRepository.getUserCalendars())
          .thenAnswer((_) async => calendars);
      
      final calendarSelectionViewModel = CalendarSelectionViewModel();
      calendarSelectionViewModel.calendarRepository = mockCalendarRepository;
      await calendarSelectionViewModel.loadCalendars();
      calendarSelectionViewModel.selectCalendar(calendar1);
      calendarSelectionViewModel.selectCalendar(calendar3);

      // Act
      final selectedCalendars = calendarSelectionViewModel.getSelectedCalendarsByDisplayName('Calendar 1');

      // Assert
      expect(selectedCalendars[0], calendar1);
    });
  });
}