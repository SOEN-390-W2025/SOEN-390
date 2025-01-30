import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';

/// This class represents calendars that are available. The UI should present a
/// checkbox list that allows certain calendars to be selected by the user, and
/// pass these choices back when requesting events.
class UserCalendar {
  String calendarId;
  String? displayName;

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

  /// Attempts to obtain calendar permissions on the device, and returns whether
  /// or not they are available.
  Future<bool> checkPermissions() async {
    final hasPermissions = await plugin.hasPermissions();
    if (hasPermissions.isSuccess && hasPermissions.data!) return true;

    final requestResult = await plugin.requestPermissions();
    return (requestResult.isSuccess && requestResult.data!);
  }

  /// Returns a list of User Calendars so that events can be retrieved.
  Future<List<UserCalendar>> getUserCalendars() async {
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
        returnData
            .add(UserCalendar(systemUserCalendar.id!, systemUserCalendar.name));
      }
    }

    return returnData;
  }

  /// Retrieves events from the list of selected calendars for the given
  /// duration.
  Future<List<UserCalendarEvent>> getEvents(
      List<UserCalendar> selectedCalendars,
      Duration timeSpan,
      DateTime? utcStart) async {
    final List<UserCalendarEvent> returnData = [];
    final startDate = (utcStart ?? DateTime.now().toUtc());
    final endDate = startDate.add(timeSpan);

    for (var userCalendar in selectedCalendars) {
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
            systemCalendarEvent.start!.toLocal(),
            systemCalendarEvent.end!.toLocal(),
            systemCalendarEvent.title!,
            systemCalendarEvent.location));
      }
    }

    return returnData;
  }

  /// Helper method to get events on a given local date from today. Pass 0 to
  /// get today's events.
  Future<List<UserCalendarEvent>> getEventsOnLocalDate(
      List<UserCalendar> selectedCalendars, int offset) async {
    var startDate = DateTime.now().add(Duration(days: offset));
    startDate =
        DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0, 0, 0);
    startDate = startDate.toUtc();
    return await getEvents(
        selectedCalendars, const Duration(days: 1), startDate);
  }
}
