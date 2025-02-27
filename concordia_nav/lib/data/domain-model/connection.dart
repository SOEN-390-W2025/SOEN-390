import 'concordia_floor.dart';
import 'concordia_floor_point.dart';

class Connection {
  final List<ConcordiaFloor> floors;
  final Map<String, List<ConcordiaFloorPoint>>
      floorPoints; // Key is floor number, value is list of points

  final bool isAccessible;
  final String name;
  final double fixedWaitTimeSeconds;
  final double waitTimePerFloorSeconds;

  Connection(this.floors, this.floorPoints, this.isAccessible, this.name,
      this.fixedWaitTimeSeconds, this.waitTimePerFloorSeconds);

  /// Returns the wait time between two floors if they are both in this
  /// connection, or null if not. Wait time is in seconds.
  double? getWaitTime(ConcordiaFloor floor1, ConcordiaFloor floor2) {
    bool found = false;
    int delta = 0;
    for (int i = 0; i < floors.length; i++) {
      if (floors[i] == floor1 || floors[i] == floor2) {
        if (found) {
          return fixedWaitTimeSeconds + waitTimePerFloorSeconds * delta;
        }
        found = true;
      }
      if (found) delta += 1;
    }

    return null;
  }
}
