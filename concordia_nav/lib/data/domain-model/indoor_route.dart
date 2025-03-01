import 'dart:math';

import 'concordia_building.dart';
import 'connection.dart';
import 'floor_routable_point.dart';
//import 'location.dart';

/// The route should be presented to the user as follows:
/// 1. The firstIndoorPortionToConnection will contain either a single Location
/// or a list of ConcordiaRooms within the same floor. Draw a path between these
///
/// 2. If a firstIndoorConnection is present, extend the previously drawn path
/// to the location of this connection
///
/// 3. Draw a path from the connection to the ConcordiaRooms of the
/// firstIndoorPortionFromConnection which will be on the same floor as the
/// connection exit.
///
/// 4. Do outdoor navigation from the firstPortionLastLocation() to the
/// secondPortionFirstLocation()
///
/// 5. All over again... the secondIndoorPortionToConnection will contain either
/// a single location or a list of ConcordiaRooms within the same floor. Draw a
/// path between these.
///
/// 6. If there is a secondIndoorConnection, extend the previously drawn path
/// to the location of this connection
///
/// 7. Draw a path from the connection to the ConcordiaRooms of the
/// secondIndoorPositionFromConnection which will be on the same floor as the
/// connection exit.
///
/// It is possible to have a route where indoor connections are not defined. In
/// that case, skip steps 2, 3, 6, and 7.
///
/// It is also possible to have a route without any secondIndoorPortions, if the
/// locations are in the same building.
class IndoorRoute {
  List<FloorRoutablePoint>? firstIndoorPortionToConnection;
  Connection? firstIndoorConnection;
  List<FloorRoutablePoint>? firstIndoorPortionFromConnection;
  ConcordiaBuilding firstBuilding;
  List<FloorRoutablePoint>? secondIndoorPortionToConnection;
  Connection? secondIndoorConnection;
  List<FloorRoutablePoint>? secondIndoorPortionFromConnection;
  ConcordiaBuilding? secondBuilding;

  IndoorRoute(
    this.firstBuilding,
    this.firstIndoorPortionToConnection,
    this.firstIndoorConnection,
    this.firstIndoorPortionFromConnection,
    this.secondBuilding,
    this.secondIndoorPortionToConnection,
    this.secondIndoorConnection,
    this.secondIndoorPortionFromConnection,
  );

  static double getDistanceBetweenPoints(
      FloorRoutablePoint point1, FloorRoutablePoint point2) {
    return sqrt(pow(point2.positionX - point1.positionX, 2) +
        pow(point2.positionY - point1.positionY, 2));
  }

  double getFloorRoutablePointListTravelTime(List<FloorRoutablePoint> points) {
    if (points.length < 2) return 0.0;
    double distanceSumPixels = 0.0;
    for (int i = 1; i < points.length; i++) {
      distanceSumPixels += getDistanceBetweenPoints(points[i], points[i - 1]);
    }
    return distanceSumPixels / points[0].floor.pixelsPerSecond;
  }

  double getIndoorTravelTimeSeconds() {
    double sum = 0.0;
    if (firstIndoorPortionToConnection != null) {
      sum +=
          getFloorRoutablePointListTravelTime(firstIndoorPortionToConnection!);
      if (firstIndoorPortionFromConnection != null) {
        sum += getFloorRoutablePointListTravelTime(
            firstIndoorPortionFromConnection!);
        sum += firstIndoorConnection?.getWaitTime(
                firstIndoorPortionToConnection![0].floor,
                firstIndoorPortionFromConnection![0].floor) ??
            0;
      }
    }
    if (secondIndoorPortionToConnection != null) {
      sum +=
          getFloorRoutablePointListTravelTime(secondIndoorPortionToConnection!);
      if (secondIndoorPortionFromConnection != null) {
        sum += getFloorRoutablePointListTravelTime(
            secondIndoorPortionFromConnection!);
        sum += secondIndoorConnection?.getWaitTime(
                secondIndoorPortionToConnection![0].floor,
                secondIndoorPortionFromConnection![0].floor) ??
            0;
      }
    }
    return sum;
  }
}
