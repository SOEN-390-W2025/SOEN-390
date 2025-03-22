import 'dart:developer' as dev;
import '../../domain-model/location.dart';

/// Generates a UUID based on [base] by appending a counter suffix if needed.
String generateUniqueId(String base, Set<String> usedIds) {
  String id = base;
  int counter = 1;
  while (usedIds.contains(id)) {
    id = "${base}_$counter";
    counter++;
  }
  usedIds.add(id);
  return id;
}

/// Rebases [parsedTime] onto the day of [planDay].
/// Returns a new DateTime with the year, month, and day from [planDay] and the
/// time from [parsedTime].
DateTime rebaseTime(DateTime parsedTime, DateTime planDay) {
  return DateTime(
    planDay.year,
    planDay.month,
    planDay.day,
    parsedTime.hour,
    parsedTime.minute,
    parsedTime.second,
  );
}

/// Validates and filters a list of events so that:
/// - Each event is on the same day as [planDay],
/// - Each event's start is before its end,
/// - And events do not overlap (i.e. each event starts at or after the previous
///  event ends).
List<(String, Location, DateTime, DateTime)> validateEvents(
  List<(String, Location, DateTime, DateTime)> events,
  DateTime planDay,
) {
  final List<(String, Location, DateTime, DateTime)> validEvents = [];
  events.sort((a, b) => a.$3.compareTo(b.$3));
  DateTime? lastEnd;
  for (var event in events) {
    final eventStart = event.$3;
    final eventEnd = event.$4;
    final eventDay =
        DateTime(eventStart.year, eventStart.month, eventStart.day);
    if (eventDay != planDay) {
      dev.log(
          "Event ${event.$1} is not on the same day as the plan: skipping.");
      continue;
    }
    if (lastEnd != null && eventStart.isBefore(lastEnd)) {
      dev.log("Event ${event.$1} overlaps with previous event: skipping.");
      continue;
    }
    validEvents.add(event);
    lastEnd = eventEnd;
  }
  return validEvents;
}
