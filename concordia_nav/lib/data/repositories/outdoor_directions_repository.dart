import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/map_viewmodel.dart';

class ShuttleRouteRepository {
  /// Loads the shuttle coordinates based on the given [direction].
  /// The term [direction] corresponds to the given route.
  ///
  /// Example: The shuttle bus route between LOY campus to SGW campus.
  Future<List<LatLng>> loadShuttleRoute(ShuttleRouteDirection direction) async {
    String filePath;

    switch (direction) {
      case ShuttleRouteDirection.SGWtoLOY:
        filePath = 'assets/maps/outdoor/shuttle_bus_routes/sgw_to_loy.json';
        break;
      case ShuttleRouteDirection.LOYtoSGW:
        filePath = 'assets/maps/outdoor/shuttle_bus_routes/loy_to_sgw.json';
        break;
    }

    final String jsonString = await rootBundle.loadString(filePath);
    final List<dynamic> jsonData = json.decode(jsonString);

    final List<LatLng> coordinates = jsonData.map((item) {
      return LatLng(
          (item['lat'] as num).toDouble(), (item['lng'] as num).toDouble());
    }).toList();

    return coordinates;
  }

  /// Loads the shuttle schedule based on the given [dayType].
  /// [dayType] can be 'Monday-Thursday' or 'Friday'.
  Future<Map<String, dynamic>> loadShuttleSchedule(String dayType) async {
    String filePath;

    switch (dayType) {
      case 'Monday-Thursday':
        filePath =
            'assets/maps/outdoor/shuttle_bus_schedules/monday_thursday.json';
        break;
      case 'Friday':
        filePath = 'assets/maps/outdoor/shuttle_bus_schedules/friday.json';
        break;
      default:
        throw Exception('Invalid day type: $dayType');
    }

    final String jsonString = await rootBundle.loadString(filePath);
    return json.decode(jsonString);
  }

  /// Checks if the shuttle is available based on the current time and day.
  Future<bool> isShuttleAvailable() async {
    final DateTime now = DateTime.now();
    final String? dayType = getDayType(now);

    // The Concordia shuttle bus does not operate on weekends; it only runs
    // Monday through Friday, i.e. it does not pass on weekends or holidays.
    if (dayType == null) return false;

    final Map<String, dynamic> schedule = await loadShuttleSchedule(dayType);
    final String lastDepartureLOY = schedule['last_departure']['LOY'];
    final String lastDepartureSGW = schedule['last_departure']['SGW'];

    final DateTime lastLOYTime = _parseTime(lastDepartureLOY);
    final DateTime lastSGWTime = _parseTime(lastDepartureSGW);

    // Shuttle is available if the current time is before either last departure.
    return now.isBefore(lastLOYTime) || now.isBefore(lastSGWTime);
  }

  /// Helper method to determine the range that maps to today's day of the week.
  String? getDayType(DateTime now) {
    const Map<int, String> dayTypeMapping = {
      DateTime.monday: 'Monday-Thursday',
      DateTime.tuesday: 'Monday-Thursday',
      DateTime.wednesday: 'Monday-Thursday',
      DateTime.thursday: 'Monday-Thursday',
      DateTime.friday: 'Friday',
    };
    return dayTypeMapping[now.weekday]; // Returns null for Saturday/Sunday.
  }

  /// Helper method to parse HH:mm time string into DateTime on today's date.
  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(":");
    return DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
