import 'package:flutter/material.dart';

/// Parses a travelTime string (ex. "1 hour 18 mins") into seconds.
///
/// In case of an error, the duration time gets returned as 0 seconds.
int parseDurationStringToSeconds(String durationText) {
  try {
    if (durationText.trim() == "--") return 0;
    int totalSeconds = 0;
    final regExp =
        RegExp(r'(\d+)\s*(day|hour|min|sec)s?', caseSensitive: false);

    for (final match in regExp.allMatches(durationText)) {
      final value = int.parse(match.group(1)!);
      final unit = match.group(2)!.toLowerCase();
      switch (unit) {
        case 'day':
          totalSeconds += value * 86400;
          break;
        case 'hour':
          totalSeconds += value * 3600;
          break;
        case 'min':
          totalSeconds += value * 60;
          break;
        case 'sec':
          totalSeconds += value;
          break;
      }
    }
    return totalSeconds;
  } on Error catch (e) {
    debugPrint("Error parsing duration string: $e");
    return 0;
  }
}
