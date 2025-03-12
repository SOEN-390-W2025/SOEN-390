import 'dart:developer' as dev;

import '../data/repositories/calendar.dart';

class CalendarSelectionViewModel {
  final CalendarRepository _repository = CalendarRepository();
  final List<UserCalendar> _calendars = [];
  final Set<String> _selectedCalendarIds = {}; // Store IDs instead of objects

  // Getter for calendars
  List<UserCalendar> get calendars => List.unmodifiable(_calendars);
  
  // Load available calendars from the repository
  Future<void> loadCalendars() async {
    dev.log('CalendarViewModel: Loading calendars');
    
    _calendars.clear();
    _selectedCalendarIds.clear();
    
    bool hasPermission = await _repository.checkPermissions();
    if (!hasPermission) {
      dev.log('CalendarViewModel: No calendar permissions');
      throw Exception('Calendar permissions not granted');
    }
    
    final loadedCalendars = await _repository.getUserCalendars();
    _calendars.addAll(loadedCalendars);
    dev.log('CalendarViewModel: Loaded ${_calendars.length} calendars');
  }
  
  // Check if a calendar is selected
  bool isCalendarSelected(UserCalendar calendar) {
    return _selectedCalendarIds.contains(calendar.calendarId);
  }
  
  // Add a calendar to selected calendars
  void selectCalendar(UserCalendar calendar) {
    _selectedCalendarIds.add(calendar.calendarId);
    dev.log('CalendarViewModel: Selected calendar: ${calendar.displayName}');
  }
  
  // Remove a calendar from selected calendars
  void unselectCalendar(UserCalendar calendar) {
    _selectedCalendarIds.remove(calendar.calendarId);
    dev.log('CalendarViewModel: Unselected calendar: ${calendar.displayName}');
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