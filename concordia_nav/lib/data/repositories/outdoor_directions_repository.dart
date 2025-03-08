import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/map_viewmodel.dart';

class ShuttleRouteRepository {
  final AssetBundle assetBundle;

  ShuttleRouteRepository({AssetBundle? assetBundle})
      : assetBundle = assetBundle ?? rootBundle;

  /// Loads the shuttle coordinates based on the given [direction].
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

    final String jsonString = await assetBundle.loadString(filePath);
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((item) {
      return LatLng(
        (item['lat'] as num).toDouble(),
        (item['lng'] as num).toDouble(),
      );
    }).toList();
  }

  /// Loads the shuttle schedule based on the given [dayType].
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

    final String jsonString = await assetBundle.loadString(filePath);
    return json.decode(jsonString);
  }

  /// Checks if the shuttle is available based on the current time and day.
  Future<bool> isShuttleAvailable() async {
    final DateTime now = DateTime.now();
    final String? dayType = getDayType(now);

    final Map<String, dynamic> schedule;
    try {
      schedule = await loadShuttleSchedule(dayType ?? 'Monday-Thursday');
    } catch (e) {
      return false; // In case of an error, assume the shuttle is unavailable.
    }

    final String lastDepartureLOY = schedule['last_departure']['LOY'];
    final String lastDepartureSGW = schedule['last_departure']['SGW'];

    final DateTime lastLOYTime = _parseTime(lastDepartureLOY);
    final DateTime lastSGWTime = _parseTime(lastDepartureSGW);

    // If it's the weekend, return false even if times are parsed.
    if (dayType == null) return false;

    // Shuttle is available if the current time is before either last departure.
    return now.isBefore(lastLOYTime) || now.isBefore(lastSGWTime);
  }

  /// Helper method to determine the range that maps to today's day of the week.
  String? getDayType(DateTime now) {
    const weekday = 'Monday-Thursday';
    const Map<int, String> dayTypeMapping = {
      DateTime.monday: weekday,
      DateTime.tuesday: weekday,
      DateTime.wednesday: weekday,
      DateTime.thursday: weekday,
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
