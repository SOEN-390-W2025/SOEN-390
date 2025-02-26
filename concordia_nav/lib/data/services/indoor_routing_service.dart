import 'dart:math';
import 'dart:developer' as dev;

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

  /// Returns distance between points in pixels/arbitrary units based on
  /// Pythagorean theorem
  static double getDistanceBetweenPoints(
      FloorRoutablePoint point1, FloorRoutablePoint point2) {
    return sqrt(pow(point2.positionX - point1.positionX, 2) +
        pow(point2.positionY - point1.positionY, 2));
  }

  static IndoorRoute getIndoorRoute(FloorRoutablePoint origin,
      FloorRoutablePoint destination, bool isAccessible) {
    // Points are the same - return a route with no instructions
    if (origin == destination) {
      dev.log("getIndoorRoute - origin and destination same, returning null");
      return IndoorRoute(
          origin.floor.building, null, null, null, null, null, null, null);
    }

    // Points are in different buildings - recurse down to two indoor routes
    // within the same building, and combine them. Other code will take care
    // of the outdoor route between.
    if (origin.floor.building.abbreviation !=
        destination.floor.building.abbreviation) {
      dev.log("getIndoorRoute - origin and destination buildings not same");
      final IndoorRoute returnRoute = IndoorRoute(origin.floor.building, null,
          null, null, destination.floor.building, null, null, null);

      // We need to combine the route from this building
      // to its exit, to the exit of the next building to the room there
      final FloorRoutablePoint? originExitPoint = IndoorFeatureRepository
          .outdoorExitPointsByBuilding[origin.floor.building.abbreviation];
      if (originExitPoint != null) {
        dev.log(
            "Origin exit point not null - getting route in origin building");
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
        dev.log("Dest exit point not null - getting route in dest building");
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
      dev.log("Origin and destination points on different floors");
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
        dev.log("Couldn't find connection between floor "
            "${origin.floor.floorNumber} and ${destination.floor.floorNumber}");
        // No known way to connect these floors - need to return an indoor route
        // with just the building
        return returnRoute;
      }

      final originConnectionPoint =
          bestConnection.floorPoints[origin.floor.floorNumber];
      if (originConnectionPoint != null) {
        dev.log("Origin conn point is not null - getting intra-floor route");
        final originFloorPortion =
            getIndoorRoute(origin, originConnectionPoint, isAccessible);
        returnRoute.firstIndoorPortionToConnection =
            originFloorPortion.firstIndoorPortionToConnection;
      }

      final destinationConnectionPoint =
          bestConnection.floorPoints[destination.floor.floorNumber];
      if (destinationConnectionPoint != null) {
        dev.log("Dest conn point is not null - getting intra-floor route");
        final destinationFloorPortion = getIndoorRoute(
            destinationConnectionPoint, destination, isAccessible);
        // The mismatch here is deliberate - intra-floor directions always
        // returned in firstIndoorPortionToConnection
        returnRoute.firstIndoorPortionFromConnection =
            destinationFloorPortion.firstIndoorPortionToConnection;
      }

      return returnRoute;
    }

    // Points are now within the same floor - this is where we will do
    // steepest-ascent hill climbing to find a route. But first there will be
    // some prep. We want the route to follow waypoints and permitted
    // navigations to ensure the user doesn't walk through walls. We will start
    // by finding the closet waypoint to the origin and to the destination.
    //
    // If the closest waypoint to the origin and the destination is the same
    // waypoint, we will have a 3-stop route (origin, waypoint, destination)
    //
    // If these waypoints are *not* the same, we will use steepest-ascent hill
    // climbing to find a route.
    dev.log("getIndoorRoute - finding intra-floor route");
    final waypointsOnFloor = IndoorFeatureRepository
            .waypointsByFloor[origin.floor.building.abbreviation]
        ?[origin.floor.floorNumber];
    final waypointNavigability =
        IndoorFeatureRepository.waypointNavigabilityGroupsByFloor[
            origin.floor.building.abbreviation]?[origin.floor.floorNumber];
    if (waypointsOnFloor == null || waypointNavigability == null) {
      // No floor routing data for this floor, need to return the null route
      dev.log("No indoor routing data for floor ${origin.floor.floorNumber}");
      return IndoorRoute(
          origin.floor.building, null, null, null, null, null, null, null);
    }

    // Find the closest waypoint to the origin and destination
    int? originWaypointIndex;
    double? originWaypointDistance;
    int? destinationWaypointIndex;
    double? destinationWaypointDistance;
    for (int i = 0; i < waypointsOnFloor.length; i++) {
      final distanceFromOrigin =
          getDistanceBetweenPoints(origin, waypointsOnFloor[i]);
      final distanceFromDestination =
          getDistanceBetweenPoints(destination, waypointsOnFloor[i]);
      if (originWaypointDistance == null ||
          distanceFromOrigin < originWaypointDistance) {
        originWaypointIndex = i;
        originWaypointDistance = distanceFromOrigin;
      }
      if (destinationWaypointDistance == null ||
          distanceFromDestination < destinationWaypointDistance) {
        destinationWaypointIndex = i;
        destinationWaypointDistance = distanceFromDestination;
      }
    }

    // Special case - couldn't find waypoints
    if (originWaypointIndex == null || destinationWaypointIndex == null) {
      // No floor routing data for this floor, need to return the null route
      dev.log("Waypoint setup failed");
      return IndoorRoute(
          origin.floor.building, null, null, null, null, null, null, null);
    }
    // Special case - same waypoints
    if (originWaypointIndex == destinationWaypointIndex) {
      return IndoorRoute(
          origin.floor.building,
          [origin, waypointsOnFloor[originWaypointIndex], destination],
          null,
          null,
          null,
          null,
          null,
          null);
    }

    // Now we do our hill-climbing - find the a navigable waypoint that
    // takes us closest to our destination
    final List<int> route = [originWaypointIndex];
    while (route.last != destinationWaypointIndex) {
      final neighbours = waypointNavigability[route.last];
      int? bestNeighbour;
      double? bestNeighbourDistanceToDest;
      for (int neighbourIndex in neighbours ?? []) {
        // Found our destination?
        if (neighbourIndex == destinationWaypointIndex) {
          bestNeighbour = neighbourIndex;
          bestNeighbourDistanceToDest = 0.0;
          break;
        }
        // Skip if visited
        if (route.contains(neighbourIndex)) {
          continue;
        }

        final distanceFromDestination = getDistanceBetweenPoints(
            waypointsOnFloor[neighbourIndex],
            waypointsOnFloor[destinationWaypointIndex]);
        if (bestNeighbourDistanceToDest == null ||
            distanceFromDestination < bestNeighbourDistanceToDest) {
          bestNeighbour = neighbourIndex;
          bestNeighbourDistanceToDest = distanceFromDestination;
        }
      }

      // Can't continue to the destination - couldn't find a bestNeighbour not
      // already visited
      if (bestNeighbour == null) {
        dev.log("Hill climbing failed - couldn't find a bestNeighbour");
        for (int i = 0; i < route.length; i++) {
          dev.log("Climb: i=${i.toString()}, route[i]=${route[i].toString()}");
        }
        return IndoorRoute(
            origin.floor.building, null, null, null, null, null, null, null);
      }

      route.add(bestNeighbour);
    }

    // Build a return list of FloorRoutablePoints, including those not part of
    // the free space waypoints.
    final List<FloorRoutablePoint> intrafloorRoute = [origin];
    for (int index in route) {
      intrafloorRoute.add(waypointsOnFloor[index]);
    }
    intrafloorRoute.add(destination);
    return IndoorRoute(origin.floor.building, intrafloorRoute, null, null, null,
        null, null, null);
  }
}
