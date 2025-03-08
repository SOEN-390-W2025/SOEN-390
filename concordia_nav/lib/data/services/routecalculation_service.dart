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
  static String formatDistance(double meters) {
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
      // Determine which diagonal
      if (dx > 0 && dy > 0) return 'SouthEast';
      if (dx > 0 && dy < 0) return 'NorthEast';
      if (dx < 0 && dy > 0) return 'SouthWest';
      if (dx < 0 && dy < 0) return 'NorthWest';
    }

    // For non-diagonal movement
    if (absX > absY) {
      return dx > 0 ? 'East' : 'West';
    } else {
      return dy > 0 ? 'South' : 'North';
    }
  }

  // Get turn type
  static String getDetailedTurnType(String fromDirection, String toDirection) {
    // Define a map of direction changes to turn types with more generalized terminology
    final Map<String, Map<String, String>> turnTypes = {
      'North': {
        'North': 'Continue straight',
        'East': 'Turn right',
        'West': 'Turn left',
        'South': 'Make a U-turn',
        'NorthEast': 'Turn right',
        'NorthWest': 'Turn left',
        'SouthEast': 'Turn right',
        'SouthWest': 'Turn left',
      },
      'South': {
        'South': 'Continue straight',
        'East': 'Turn left',
        'West': 'Turn right',
        'North': 'Make a U-turn',
        'SouthEast': 'Turn left',
        'SouthWest': 'Turn right',
        'NorthEast': 'Turn left',
        'NorthWest': 'Turn right',
      },
      'East': {
        'East': 'Continue straight',
        'North': 'Turn left',
        'South': 'Turn right',
        'West': 'Make a U-turn',
        'NorthEast': 'Turn left',
        'SouthEast': 'Turn right',
        'NorthWest': 'Turn left',
        'SouthWest': 'Turn right',
      },
      'West': {
        'West': 'Continue straight',
        'North': 'Turn right',
        'South': 'Turn left',
        'East': 'Make a U-turn',
        'NorthWest': 'Turn right',
        'SouthWest': 'Turn left',
        'NorthEast': 'Turn right',
        'SouthEast': 'Turn left',
      },
      'NorthEast': {
        'NorthEast': 'Continue straight',
        'North': 'Turn left',
        'East': 'Turn right',
        'South': 'Turn right',
        'West': 'Turn left',
        'SouthWest': 'Make a U-turn',
        'NorthWest': 'Turn left',
        'SouthEast': 'Turn right',
      },
      'NorthWest': {
        'NorthWest': 'Continue straight',
        'North': 'Turn right',
        'West': 'Turn left',
        'South': 'Turn left',
        'East': 'Turn right',
        'SouthEast': 'Make a U-turn',
        'NorthEast': 'Turn right',
        'SouthWest': 'Turn left',
      },
      'SouthEast': {
        'SouthEast': 'Continue straight',
        'South': 'Turn left',
        'East': 'Turn right',
        'North': 'Turn left',
        'West': 'Turn right',
        'NorthWest': 'Make a U-turn',
        'SouthWest': 'Turn left',
        'NorthEast': 'Turn right',
      },
      'SouthWest': {
        'SouthWest': 'Continue straight',
        'South': 'Turn right',
        'West': 'Turn left',
        'North': 'Turn right',
        'East': 'Turn left',
        'NorthEast': 'Make a U-turn',
        'SouthEast': 'Turn right',
        'NorthWest': 'Turn left',
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