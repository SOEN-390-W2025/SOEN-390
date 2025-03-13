// ignore_for_file: avoid_catches_without_on_clauses

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import '../data/repositories/calendar.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _calendarRepository = CalendarRepository();
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
  
  // Extract building information from location string
  String getFloorPlanName(String location) {
    // Split the string by spaces
    final List<String> parts = location.split(" ");
    if (parts.length < 2) {
      return location; // Return original if no space found
    }
    
    final String building = parts[0];
    final String roomNumber = parts[1];
    
    // Check if roomNumber starts with a letter
    if (roomNumber.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(roomNumber[0])) {
      // If roomNumber starts with a letter, return building + first two characters
      if (roomNumber.length > 1) {
        return building + roomNumber[0] + roomNumber[1];
      } else {
        return building + roomNumber[0];
      }
    } else {
      // For regular cases, return building + first character of roomNumber
      if (roomNumber.isNotEmpty) {
        return building + roomNumber[0];
      }
    }
    
    return building; // Fallback if roomNumber is empty
  }
  
  // Extract building abbreviation from location
  String getBuildingAbbreviation(String location) {
    final List<String> parts = location.split(" ");
    return parts.isNotEmpty ? parts[0] : '';
  }
}