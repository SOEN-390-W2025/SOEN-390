// A new utility class to share route calculation functionality
import 'package:flutter/material.dart';

import '../domain-model/concordia_floor.dart';
import '../domain-model/connection.dart';
import '../domain-model/floor_routable_point.dart';
import '../domain-model/indoor_route.dart';

class RouteCalculationService {
  // Shared method to calculate total distance from a route
  static double calculateTotalDistanceFromRoute(IndoorRoute route) {
    double totalDistance = 0.0;
    
    // Calculate distance for first indoor portion
    if (route.firstIndoorPortionToConnection != null &&
        route.firstIndoorPortionToConnection!.length > 1) {
      totalDistance += _calculateSegmentDistance(route.firstIndoorPortionToConnection!);
    }
    
    // Calculate distance for first indoor portion after connection
    if (route.firstIndoorPortionFromConnection != null &&
        route.firstIndoorPortionFromConnection!.length > 1) {
      totalDistance += _calculateSegmentDistance(route.firstIndoorPortionFromConnection!);
    }

    // Calculate distance for second indoor portion
    if (route.secondIndoorPortionToConnection != null &&
        route.secondIndoorPortionToConnection!.length > 1) {
      totalDistance += _calculateSegmentDistance(route.secondIndoorPortionToConnection!);
    }

    // Calculate distance for second indoor portion after connection
    if (route.secondIndoorPortionFromConnection != null &&
        route.secondIndoorPortionFromConnection!.length > 1) {
      totalDistance += _calculateSegmentDistance(route.secondIndoorPortionFromConnection!);
    }

    return totalDistance;
  }

  // Helper method to calculate distance for a segment
  static double _calculateSegmentDistance(List<FloorRoutablePoint> points) {
    double distance = 0.0;
    for (int i = 1; i < points.length; i++) {
      distance += IndoorRoute.getDistanceBetweenPoints(points[i-1], points[i]);
    }
    return distance;
  }

  // Shared method to calculate metrics for route segments
  static void calculateSegmentMetrics(
    List<FloorRoutablePoint>? points, 
    {required Function(double distanceMeters, int timeSeconds) onResult}
  ) {
    if (points == null || points.length < 2) {
      onResult(0.0, 0);
      return;
    }

    // Calculate distance
    final double distancePixels = _calculateSegmentDistance(points);

    // Convert pixels to meters using floor's scale
    final double distanceMeters = distancePixels / (points[0].floor.pixelsPerSecond*60);

    // Calculate time in seconds
    final double timeSeconds = distancePixels / points[0].floor.pixelsPerSecond;

    onResult(distanceMeters, timeSeconds.round());
  }

  // Shared method to get connection wait time
  static int getConnectionWaitTime(Connection connection, String fromFloor, String toFloor) {
    return connection.getWaitTime(fromFloor as ConcordiaFloor, toFloor as ConcordiaFloor)?.round() ?? 0;
  }

  // Shared method to get connection focus point
  static Offset getConnectionFocusPoint(Connection connection, String floor, Offset startLocation, Offset endLocation) {
    // Get the specific point for the current floor
    final floorKey = floor;
    final points = connection.floorPoints[floorKey];

    if (points != null && points.isNotEmpty) {
      return Offset(points.first.positionX, points.first.positionY);
    }

    // Fallback to center between start and end
    return Offset(
      (startLocation.dx + endLocation.dx) / 2,
      (startLocation.dy + endLocation.dy) / 2
    );
  }

  // Shared formatting methods
  static String formatDistance(double meters,
      {String measurementUnit = 'Metric'}) {
    if (measurementUnit == 'Imperial') {
      final double yards = meters * 1.09361;
      if (yards < 10) {
        return "${yards.toStringAsFixed(1)} yd";
      } else if (yards < 100) {
        return "${yards.round()} yd";
      } else if (yards < 1000) {
        return "${yards.round()} yd";
      } else {
        final miles = yards / 1760;
        return "${miles.toStringAsFixed(1)} mi";
      }
    } else {
      if (meters < 10) {
        return "${meters.toStringAsFixed(1)} m";
      } else if (meters < 100) {
        return "${meters.round()} m";
      } else if (meters < 1000) {
        return "${meters.round()} m";
      } else {
        final kilometers = meters / 1000;
        return "${kilometers.toStringAsFixed(1)} km";
      }
    }
  }

  static String formatTime(int seconds) {
    if (seconds < 60) {
      return "$seconds sec";
    } else {
      final minutes = (seconds / 60).ceil();
      return "$minutes min";
    }
  }

  // Shared detailed time format
  static String formatDetailedTime(double seconds) {
    if (seconds < 60) {
      return "${seconds.round()} sec";
    } else {
      final int minutes = (seconds / 60).floor();
      final int remainingSeconds = (seconds % 60).round();
      return "$minutes min${remainingSeconds > 0 ? " $remainingSeconds sec" : ""}";
    }
  }

  static String? _getDiagonal(double dx, double dy){
    // Determine which diagonal
      if (dx > 0 && dy > 0) return 'SouthEast';
      if (dx > 0 && dy < 0) return 'NorthEast';
      if (dx < 0 && dy > 0) return 'SouthWest';
      if (dx < 0 && dy < 0) return 'NorthWest';
      return null;
  }

  // Get direction between points
  static String getDetailedDirectionBetweenPoints(Offset point1, Offset point2) {
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;

    // Determine primary movement direction
    final double absX = dx.abs();
    final double absY = dy.abs();

    // Use a threshold to detect diagonal movement
    // If x and y components are similar in magnitude, it's diagonal
    final bool isDiagonal = absX > 0.3 && absY > 0.3 && absX / absY < 3 && absY / absX < 3;

    if (isDiagonal) {
      final diagonal = _getDiagonal(dx, dy);
      if (diagonal != null){
        return diagonal;
      }
    }

    // For non-diagonal movement
    if (absX > absY) {
      return dx > 0 ? 'East' : 'West';
    } else {
      return dy > 0 ? 'South' : 'North';
    }
  }

  static const straight = 'Continue straight';
  static const right = 'Turn right';
  static const left = 'Turn left';
  static const uturn = 'Make a U-turn';

  // Get turn type
  static String getDetailedTurnType(String fromDirection, String toDirection) {
    // Define a map of direction changes to turn types with more generalized terminology
    final Map<String, Map<String, String>> turnTypes = {
      'North': {
        'North': straight,
        'East': right,
        'West': left,
        'South': uturn,
        'NorthEast': right,
        'NorthWest': left,
        'SouthEast': right,
        'SouthWest': left,
      },
      'South': {
        'South': straight,
        'East': left,
        'West': right,
        'North': uturn,
        'SouthEast': left,
        'SouthWest': right,
        'NorthEast': left,
        'NorthWest': right,
      },
      'East': {
        'East': straight,
        'North': left,
        'South': right,
        'West': uturn,
        'NorthEast': left,
        'SouthEast': right,
        'NorthWest': left,
        'SouthWest': right,
      },
      'West': {
        'West': straight,
        'North': right,
        'South': left,
        'East': uturn,
        'NorthWest': right,
        'SouthWest': left,
        'NorthEast': right,
        'SouthEast': left,
      },
      'NorthEast': {
        'NorthEast': straight,
        'North': left,
        'East': right,
        'South': right,
        'West': left,
        'SouthWest': uturn,
        'NorthWest': left,
        'SouthEast': right,
      },
      'NorthWest': {
        'NorthWest': straight,
        'North': right,
        'West': left,
        'South': left,
        'East': right,
        'SouthEast': uturn,
        'NorthEast': right,
        'SouthWest': left,
      },
      'SouthEast': {
        'SouthEast': straight,
        'South': left,
        'East': right,
        'North': left,
        'West': right,
        'NorthWest': uturn,
        'SouthWest': left,
        'NorthEast': right,
      },
      'SouthWest': {
        'SouthWest': straight,
        'South': right,
        'West': left,
        'North': right,
        'East': left,
        'NorthEast': uturn,
        'SouthEast': right,
        'NorthWest': left,
      },
    };

    // Return the turn type if defined, otherwise return a generic "Change direction"
    return turnTypes[fromDirection]?[toDirection] ?? 'Change direction';
  }

  // Get appropriate navigation icon based on turn instruction
  static IconData getTurnIcon(String turnInstruction) {
    if (turnInstruction.contains('right')) {
      return Icons.turn_right;
    } else if (turnInstruction.contains('left')) {
      return Icons.turn_left;
    } else if (turnInstruction.contains('diagonal')) {
      // For diagonal turns
      if (turnInstruction.contains('right')) {
        return Icons.turn_slight_right;
      } else {
        return Icons.turn_slight_left;
      }
    } else if (turnInstruction.contains('U-turn')) {
      return Icons.u_turn_right;
    } else {
      return Icons.straight;
    }
  }
}