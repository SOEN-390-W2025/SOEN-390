// ignore_for_file: avoid_catches_without_on_clauses

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import '../data/repositories/calendar.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarRepository _calendarRepository = CalendarRepository();
  List<UserCalendar> _allCalendars = [];
  List<UserCalendar> _selectedCalendars = [];
  List<UserCalendarEvent> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<UserCalendar> get allCalendars => _allCalendars;
  List<UserCalendar> get selectedCalendars => _selectedCalendars;
  List<UserCalendarEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Allows setting a custom calendar repository (for testing)
  set calendarRepository(CalendarRepository repo) {
    _calendarRepository = repo;
  }

  // Allows settings a custom events list (for testing)
  set eventsList(List<UserCalendarEvent> events){
    _events = events;
  }

  // Initialize the view model with optional selected calendar
  Future<void> initialize({UserCalendar? selectedCalendar}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check permissions
      final hasPermission = await _calendarRepository.checkPermissions();
      if (!hasPermission) {
        _errorMessage = 'Calendar permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load available calendars
      _allCalendars = await _calendarRepository.getUserCalendars();

      // Set selected calendars based on input parameter or default to all calendars
      if (selectedCalendar != null) {
        // Find matching calendars by display name
        _selectedCalendars = _allCalendars.where(
          (cal) => cal.displayName == selectedCalendar.displayName
        ).toList();

      } else {
        // Default to all calendars when none are provided
        _selectedCalendars = List.from(_allCalendars);
      }
      
      // Directly load events for the selected calendars
      final startDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      _events = await _calendarRepository.getEvents(
        _selectedCalendars, 
        const Duration(days: 7),
        startDate,
      );
      
    } catch (e) {
      _errorMessage = 'Initialization error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convert UserCalendarEvents to CalendarEventData for the calendar_view package
  List<CalendarEventData> getCalendarEventData() {
    final List<UserCalendarEvent> filteredEvents = _events.where((event) {
      // Check if this event's calendar is in the selected calendars
      return _selectedCalendars.any((cal) => 
        cal.calendarId == event.userCalendar.calendarId
      );
    }).toList();

    return filteredEvents.map((event) {
      // Generate a color based on calendar ID for visual differentiation
      final color = Colors.primaries[event.userCalendar.calendarId.hashCode % Colors.primaries.length];

      return CalendarEventData(
        title: event.title,
        date: event.localStart,
        description: event.description,
        startTime: event.localStart,
        endTime: event.localEnd,
        color: color,
        // Store the original event for reference
        event: event,
      );
    }).toList();
  }
  
  // Helper method for formatting event time
  String formatEventTime(UserCalendarEvent? event) {
    if (event == null) return 'No time specified';

    final startTime = event.localStart;
    final endTime = event.localEnd;

    final startFormat = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormat = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$startFormat - $endFormat';
  }
  
  // Extract building abbreviation from location
  String getBuildingAbbreviation(String location) {
    final List<String> parts = location.split(" ");
    return parts[0] != location ? parts[0] : '';
  }
}