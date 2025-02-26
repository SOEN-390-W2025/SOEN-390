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
}
