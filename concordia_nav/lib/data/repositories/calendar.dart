import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/building_viewmodel.dart';
import '../domain-model/concordia_floor.dart';
import '../domain-model/concordia_room.dart';
import '../domain-model/room_category.dart';

/// This class represents calendars that are available. The UI should present a
/// checkbox list that allows certain calendars to be selected by the user, and
/// pass these choices back when requesting events.
class UserCalendar {
  String calendarId;
  String? displayName;
  late bool isPreferred;

  UserCalendar(this.calendarId, this.displayName);

  @override
  bool operator ==(Object other) {
    return other is UserCalendar && calendarId == other.calendarId;
  }

  @override
  int get hashCode => calendarId.hashCode;
}

/// This class provides a simplified representation of calendar events. All-day
/// events are excluded.
class UserCalendarEvent {
  UserCalendar userCalendar;
  String eventId;
  String? description;
  DateTime localStart;
  DateTime localEnd;
  String title;
  String? locationField;

  UserCalendarEvent(this.userCalendar, this.eventId, this.description,
      this.localStart, this.localEnd, this.title, this.locationField);
}

class CalendarRepository {
  var plugin = DeviceCalendarPlugin();
  var prefs = SharedPreferencesAsync();

  /// Attempts to obtain calendar permissions on the device, and returns whether
  /// or not they are available.
  Future<bool> checkPermissions() async {
    final hasPermissions = await plugin.hasPermissions();
    if (hasPermissions.isSuccess && hasPermissions.data!) return true;

    final requestResult = await plugin.requestPermissions();
    return (requestResult.isSuccess && requestResult.data!);
  }

  /// Returns a list of User Calendars so that events can be retrieved.
  Future<List<UserCalendar>> getUserCalendars(
      {preferredCalendarsOnly = false}) async {
    final List<UserCalendar> returnData = [];
    if (!(await checkPermissions())) return returnData;

    final systemUserCalendars = await plugin.retrieveCalendars();
    if (!systemUserCalendars.isSuccess) {
      throw Exception("Unable to retrieve system user calendars.");
    }

    for (var systemUserCalendar
        in systemUserCalendars.data as UnmodifiableListView<Calendar>) {
      // Calendars without IDs cannot be referred to in future calls
      if (systemUserCalendar.id != null) {
        final UserCalendar cal =
            UserCalendar(systemUserCalendar.id!, systemUserCalendar.name);
        cal.isPreferred = await isCalendarPreferred(cal);
        if (preferredCalendarsOnly && !cal.isPreferred) continue;
        returnData.add(cal);
      }
    }

    return returnData;
  }

  /// Checks user preferences to see if a calendar is preferred. If the calendar ID is
  /// not found in user preferences, it will be saved and returned as true
  Future<bool> isCalendarPreferred(UserCalendar cal) async {
    final bool? prefsResult =
        await prefs.getBool("CalendarRepository-Preference-${cal.calendarId}");
    if (prefsResult != null) {
      return prefsResult;
    }

    // No preference found, default to true
    cal.isPreferred = true;
    await setUserCalendarPreferredState(cal);
    return cal.isPreferred;
  }

  /// Sets the calendar preference preferred state and returns that same state.
  Future<bool> setUserCalendarPreferredState(UserCalendar cal) async {
    await prefs.setBool(
        "CalendarRepository-Preference-${cal.calendarId}", cal.isPreferred);
    return cal.isPreferred;
  }

  /// Retrieves events from the list of selected calendars for the given
  /// duration.
  Future<List<UserCalendarEvent>> getEvents(
      List<UserCalendar>? selectedCalendars,
      Duration timeSpan,
      DateTime? utcStart) async {
    // If selected calendars not passed, use all calendars
    final calendars = selectedCalendars ??
        await getUserCalendars(preferredCalendarsOnly: true);
    final List<UserCalendarEvent> returnData = [];
    final startDate = (utcStart ?? DateTime.now().toUtc());
    final endDate = startDate.add(timeSpan);

    for (var userCalendar in calendars) {
      final systemCalendarEvents = await plugin.retrieveEvents(
          userCalendar.calendarId,
          RetrieveEventsParams(startDate: startDate, endDate: endDate));
      if (!systemCalendarEvents.isSuccess) continue;
      for (var systemCalendarEvent in systemCalendarEvents.data!) {
        if ((systemCalendarEvent.allDay != null &&
                systemCalendarEvent.allDay == true) ||
            systemCalendarEvent.eventId == null ||
            systemCalendarEvent.title == null ||
            systemCalendarEvent.start == null ||
            systemCalendarEvent.end == null) {
          continue;
        }
        returnData.add(UserCalendarEvent(
            userCalendar,
            systemCalendarEvent.eventId!,
            systemCalendarEvent.description,
            systemCalendarEvent.start!,
            systemCalendarEvent.end!,
            systemCalendarEvent.title!,
            systemCalendarEvent.location));
      }
    }

    return returnData;
  }

  /// Helper method to get events on a given local date from today. Pass 0 to
  /// get today's events.
  Future<List<UserCalendarEvent>> getEventsOnLocalDate(
      List<UserCalendar>? selectedCalendars, int offset) async {
    var startDate = DateTime.now().add(Duration(days: offset));
    startDate =
        DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0, 0, 0);
    startDate = startDate.toUtc();
    return await getEvents(
        selectedCalendars, const Duration(days: 1), startDate);
  }

  /// Gets the next upcoming class event from the selected calendars.
  Future<UserCalendarEvent?> getNextClassEvent(
      List<UserCalendar>? selectedCalendars) async {
    final events = await getEvents(
      selectedCalendars,
      const Duration(days: 365 * 100),
      DateTime.now().toUtc(),
    );
    if (events.isEmpty) return null;
    events.sort((a, b) => a.localStart.compareTo(b.localStart));
    return events.first;
  }

  /// Gets the next class room from the selected calendars.
  Future<ConcordiaRoom?> getNextClassRoom(
    List<UserCalendar>? selectedCalendars,
    BuildingViewModel buildingViewModel,
  ) async {
    final nextEvent = await getNextClassEvent(selectedCalendars);

    if (nextEvent == null || nextEvent.locationField == null) {
      return null;
    }

    final parsed = _parseCalendarLocation(nextEvent.locationField!);

    final buildingCode = parsed['buildingCode'];
    if (buildingCode == null) return null;

    final building = buildingViewModel.getBuildingByAbbreviation(buildingCode);
    if (building == null) return null;

    final floorNumber = parsed['floor'] ?? '1';
    final roomNumber = parsed['room'] ?? '0001';

    final floor = ConcordiaFloor(floorNumber, building);

    return ConcordiaRoom(
      roomNumber,
      RoomCategory.classroom,
      floor,
      null,
    );
  }

  /// Parses a location string into a map with buildingCode, floor, and room.
  Map<String, String> _parseCalendarLocation(String locationField) {
    // Example input: "MB S2.330"
    final parts = locationField.split(' ');

    if (parts.isEmpty) return {};

    final buildingCode = parts[0]; // "MB"
    String? floor;
    String? room;

    if (parts.length > 1) {
      final subParts = parts[1].split('.');
      if (subParts.isNotEmpty) {
        floor = subParts[0]; // "S2"
      }
      if (subParts.length > 1) {
        room = subParts[1]; // "330"
      }
    }

    return {
      'buildingCode': buildingCode,
      'floor': floor ?? '',
      'room': room ?? '',
    };
  }
}
