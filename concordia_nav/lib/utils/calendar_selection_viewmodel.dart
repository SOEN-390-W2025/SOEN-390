// ignore_for_file: prefer_final_locals

import 'dart:developer' as dev;

import '../data/repositories/calendar.dart';

class CalendarSelectionViewModel {
  CalendarRepository _calendarRepository = CalendarRepository();
  final List<UserCalendar> _calendars = [];
  final Set<String> _selectedCalendarIds = {}; // Store IDs instead of objects

  // Allows setting a custom calendar repository (for testing)
  set calendarRepository(CalendarRepository repo) {
    _calendarRepository = repo;
  }

  // Getter for calendars
  List<UserCalendar> get calendars => List.unmodifiable(_calendars);

  // Load available calendars from the repository
  Future<void> loadCalendars() async {

    _calendars.clear();
    _selectedCalendarIds.clear();

    bool hasPermission = await _calendarRepository.checkPermissions();
    if (!hasPermission) {
      throw Exception('Calendar permissions not granted');
    }

    final loadedCalendars = await _calendarRepository.getUserCalendars();
    _calendars.addAll(loadedCalendars);
  }

  // Check if a calendar is selected
  bool isCalendarSelected(UserCalendar calendar) {
    return _selectedCalendarIds.contains(calendar.calendarId);
  }

  // Add a calendar to selected calendars
  void selectCalendar(UserCalendar calendar) {
    _selectedCalendarIds.add(calendar.calendarId);

  }

  // Remove a calendar from selected calendars
  void unselectCalendar(UserCalendar calendar) {
    _selectedCalendarIds.remove(calendar.calendarId);
  }

  // Toggle calendar selection
  void toggleCalendarSelection(UserCalendar calendar) {
    if (isCalendarSelected(calendar)) {
      unselectCalendar(calendar);
    } else {
      selectCalendar(calendar);
    }
  }
  
  // Get the list of selected calendars (using repository objects)
  List<UserCalendar> getSelectedCalendars() {
    return _calendars.where((calendar) => 
      _selectedCalendarIds.contains(calendar.calendarId)).toList();
  }
  
  // Select calendars based on display name
  void selectCalendarsByDisplayName(String displayName) {
    final matchingCalendars = _calendars.where(
      (calendar) => calendar.displayName == displayName
    );

    for (var calendar in matchingCalendars) {
      selectCalendar(calendar);
    }

    dev.log('CalendarViewModel: Selected ${matchingCalendars.length} calendars with name: $displayName');
  }

  // Get selected calendars matching a display name
  List<UserCalendar> getSelectedCalendarsByDisplayName(String displayName) {
    return getSelectedCalendars().where(
      (calendar) => calendar.displayName == displayName
    ).toList();
  }
}