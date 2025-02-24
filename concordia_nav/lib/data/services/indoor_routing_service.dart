import 'package:geolocator/geolocator.dart';
import '../domain-model/concordia_building.dart';
import '../domain-model/concordia_campus.dart';
import '../domain-model/connection.dart';
import '../domain-model/floor_routable_point.dart';
import '../domain-model/indoor_route.dart';
import '../domain-model/location.dart';
import '../repositories/building_repository.dart';
import '../repositories/indoor_feature_repository.dart';
import 'map_service.dart';

class IndoorRoutingService {
  static const roundingMinimumProximityMeters = 30.0;

  /// Returns at minimum a Location object with latitide and longitude based on
  /// the device location. If the device is within the minimum rounding
  /// proximity of a ConcordiaBuilding, it will return that ConcordiaBuilding
  /// which is closest to the user.
  ///
  /// Returns null if permission is denied or location services are not
  /// available.
  static Future<Location?> getRoundedLocation() async {
    List<ConcordiaBuilding>? searchCandidates;
    final Position userPosition;
    final MapService mapService = MapService();

    try {
      final bool serviceEnabled = await mapService.isLocationServiceEnabled();
      final bool hasPermission =
          await mapService.checkAndRequestLocationPermission();
      // check if location services are enabled
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
      // check if location permissions are granted
      if (!hasPermission) {
        return Future.error('Location permissions are denied.');
      }

      // Get the user's current location
      userPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation));
    } on Exception {
      return null;
    }

    // Discard location if wildly inaccurate
    if (userPosition.accuracy > 50.0) return null;

    // Search through the appropriate list of buildings if the user is close to
    // either campus
    if (Geolocator.distanceBetween(
            ConcordiaCampus.sgw.lat,
            ConcordiaCampus.sgw.lng,
            userPosition.latitude,
            userPosition.longitude) <
        1000) {
      searchCandidates = BuildingRepository
          .buildingByCampusAbbreviation[ConcordiaCampus.sgw.abbreviation];
    } else if (Geolocator.distanceBetween(
            ConcordiaCampus.loy.lat,
            ConcordiaCampus.loy.lng,
            userPosition.latitude,
            userPosition.longitude) <
        1000) {
      searchCandidates = BuildingRepository
          .buildingByCampusAbbreviation[ConcordiaCampus.loy.abbreviation];
    }

    ConcordiaBuilding? bestCandidate;
    double bestCandidateDistance = double.infinity;

    if (searchCandidates != null) {
      for (final candidateBuilding in searchCandidates) {
        final double distance = Geolocator.distanceBetween(
            candidateBuilding.lat,
            candidateBuilding.lng,
            userPosition.latitude,
            userPosition.longitude);
        if (distance < roundingMinimumProximityMeters &&
            distance < bestCandidateDistance) {
          bestCandidate = candidateBuilding;
          bestCandidateDistance = distance;
        }
      }
    }

    if (bestCandidate != null) {
      return bestCandidate;
    } else {
      return Location(userPosition.latitude, userPosition.longitude,
          "Current Location", null, null, null, null);
    }
  }

  static IndoorRoute getIndoorRoute(FloorRoutablePoint origin,
      FloorRoutablePoint destination, bool isAccessible) {
    // Points are the same - return a route with no instructions
    if (origin == destination) {
      return IndoorRoute(
          origin.floor.building, null, null, null, null, null, null, null);
    }
    // Points are in different buildings - recurse down to two indoor routes
    // within the same building, and combine them. Other code will take care
    // of the outdoor route between.
    if (origin.floor.building.abbreviation !=
        destination.floor.building.abbreviation) {
      final IndoorRoute returnRoute = IndoorRoute(origin.floor.building, null,
          null, null, destination.floor.building, null, null, null);
      // Inter-building route - we need to combine the route from this building
      // to its exit, to the exit of the next building to the room there
      final FloorRoutablePoint? originExitPoint = IndoorFeatureRepository
          .outdoorExitPointsByBuilding[origin.floor.building.abbreviation];
      if (originExitPoint != null) {
        final IndoorRoute originPortion =
            getIndoorRoute(origin, originExitPoint, isAccessible);
        returnRoute.firstIndoorPortionToConnection =
            originPortion.firstIndoorPortionToConnection;
        returnRoute.firstIndoorConnection = originPortion.firstIndoorConnection;
        returnRoute.firstIndoorPortionFromConnection =
            originPortion.firstIndoorPortionFromConnection;
      }
      final FloorRoutablePoint? destinationExitPoint = IndoorFeatureRepository
          .outdoorExitPointsByBuilding[destination.floor.building.abbreviation];
      if (destinationExitPoint != null) {
        final IndoorRoute destinationPortion =
            getIndoorRoute(destinationExitPoint, destination, isAccessible);
        returnRoute.secondIndoorPortionToConnection =
            destinationPortion.firstIndoorPortionToConnection;
        returnRoute.secondIndoorConnection =
            destinationPortion.firstIndoorConnection;
        returnRoute.secondIndoorPortionFromConnection =
            destinationPortion.secondIndoorPortionFromConnection;
      }
      return returnRoute;
    }
    // Points are now in the same building but on different floors - find the
    // best connection between these floors, then recurse down to 2 intra-floor
    // routes
    if (origin.floor.floorNumber != destination.floor.floorNumber) {
      final possibleConnections = IndoorFeatureRepository
          .connectionsByBuilding[origin.floor.building.abbreviation];
      Connection? bestConnection;
      double? bestWaitTime;
      for (var connection in (possibleConnections ?? [])) {
        final double? waitTime =
            connection.getWaitTime(origin.floor, destination.floor);
        if (waitTime != null &&
            (bestWaitTime == null || waitTime < bestWaitTime) &&
            (!isAccessible || connection.isAccessible)) {
          bestConnection = connection;
          bestWaitTime = waitTime;
        }
      }

      final returnRoute = IndoorRoute(origin.floor.building, null,
          bestConnection, null, null, null, null, null);
      if (bestConnection == null) {
        // No known way to connect these floors - need to return an indoor route
        // with just the building
        return returnRoute;
      }

      final originConnectionPoint =
          bestConnection.floorPoints[origin.floor.floorNumber];
      if (originConnectionPoint != null) {
        final originFloorPortion =
            getIndoorRoute(origin, originConnectionPoint, isAccessible);
        returnRoute.firstIndoorPortionToConnection =
            originFloorPortion.firstIndoorPortionToConnection;
      }
      final destinationConnectionPoint =
          bestConnection.floorPoints[destination.floor.floorNumber];
      if (destinationConnectionPoint != null) {
        final destinationFloorPortion = getIndoorRoute(
            destinationConnectionPoint, destination, isAccessible);
        // The mismatch here is deliberate - intra-floor directions always
        // returned in firstIndoorPortionToConnection
        returnRoute.firstIndoorPortionFromConnection =
            destinationFloorPortion.firstIndoorPortionToConnection;
      }
    }
    // Points are now within the same floor - this is where we do our BFS of
    // floor points to find a route
    // TODO implement this
  }
}
