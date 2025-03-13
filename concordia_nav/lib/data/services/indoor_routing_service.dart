// ignore_for_file: prefer_final_locals, avoid_catches_without_on_clauses, unused_local_variable

import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../domain-model/concordia_building.dart';
import '../domain-model/concordia_campus.dart';
import '../domain-model/concordia_floor.dart';
import '../domain-model/concordia_floor_point.dart';
import '../domain-model/concordia_room.dart';
import '../domain-model/connection.dart';
import '../domain-model/floor_routable_point.dart';
import '../domain-model/indoor_route.dart';
import '../domain-model/location.dart';
import '../repositories/building_data.dart';
import '../repositories/building_data_manager.dart';
import '../repositories/building_repository.dart';
import '../repositories/calendar.dart';
import '../repositories/indoor_feature_repository.dart';
import 'map_service.dart';

class IndoorRoutingService {
  static const roundingMinimumProximityMeters = 30.0;

  static final firstRoomNumberParsingExp = RegExp(r'([A-Za-z -]+)(.+)');
  static CalendarRepository calendarRepository = CalendarRepository();
  static MapService mapService = MapService();

  /// Takes a string (as might appear in a calendar event location field) and parse it
  /// into a room number.
  ///
  /// - first trim whitespace
  /// - take all the letters and space characters off the left, trim, and match to a
  ///   building abbreviation (null will be returned if this fails)
  /// - then, if the rest of the string has a dot:
  ///   - split the string on the first dot (only)
  ///   - the left portion of the split is the floor and the right portion is the room
  ///     number
  /// - else (no dot):
  ///   - if the rest of the string is 3 chars, first char is the floor and right 2
  ///     chars are the room number
  ///   - if the rest of the string is 4 chars, first 2 chars is the floor and right 2
  ///     chars are the room number
  ///
  /// The canonical format is BBX.Y where BB is building abbreviation, X is floorNo
  /// and Y is roomNumber. But this supports some other common formats.
  ///
  /// If there is room-level data for the floor, this will be returned, if not, only
  /// the floor will be returned
  ///
  /// Examples:
  ///   "EV2.260", "ev 2.260", "EV-2.260" -> EV, 2, 260
  ///   "H6.55", "H655", "H 655" -> H, 6, 55
  ///   "EV2260" -> EV (building level precision only, no floor 22 exists)
  static Future<Location?> parseRoomNumber(String input) async {
    Location? returnLocation;
    var trimmed = input.trim();

    // Check if the regex matches the input
    var matches = firstRoomNumberParsingExp.allMatches(trimmed);

    if (matches.isEmpty) {
      return returnLocation; // Return null or handle this case differently if needed
    }

    // Now, it's safe to access the first match
    var firstLevelMatch = matches.elementAt(0);

    var buildingAbbrPortion = firstLevelMatch.group(1);
    if (buildingAbbrPortion == null) {
      return returnLocation;
    }

    buildingAbbrPortion = buildingAbbrPortion.trim().toUpperCase();
    returnLocation =
        BuildingRepository.buildingByAbbreviation[buildingAbbrPortion];
    if (returnLocation == null) {
      return returnLocation;
    }

    var buildingData =
        await BuildingDataManager.getBuildingData(buildingAbbrPortion);
    var floorAndRoomPortion = firstLevelMatch.group(2);
    if (floorAndRoomPortion == null || buildingData == null) {
      return returnLocation;
    }

    String? floorNumber;
    String? roomNumber;
    if (floorAndRoomPortion.contains('.')) {
      var parts = floorAndRoomPortion.split('.');
      floorNumber = parts[0].trim().toUpperCase();
      roomNumber = parts.elementAtOrNull(1)?.trim();
    } else {
      if (floorAndRoomPortion.length == 3) {
        floorNumber = floorAndRoomPortion.substring(0, 1);
        roomNumber = floorAndRoomPortion.substring(1, 3);
      } else if (floorAndRoomPortion.length == 4) {
        floorNumber = floorAndRoomPortion.substring(0, 2);
        roomNumber = floorAndRoomPortion.substring(2, 4);
      }
    }

    if (floorNumber != null) {
      for (ConcordiaFloor candidate in buildingData.floors) {
        if (candidate.floorNumber == floorNumber) {
          returnLocation = candidate;
          break;
        }
      }
    }

    if (roomNumber != null &&
        buildingData.roomsByFloor.containsKey(floorNumber)) {
      for (ConcordiaRoom candidate
          in buildingData.roomsByFloor[floorNumber] ?? []) {
        if (candidate.roomNumber == roomNumber) {
          returnLocation = candidate;
          break;
        }
      }
    }

    return returnLocation;
  }

  /// Returns at minimum a Location object with latitide and longitude based on
  /// the device location. If the device is within the minimum rounding
  /// proximity of a ConcordiaBuilding, it will return that ConcordiaBuilding
  /// which is closest to the user.
  ///
  /// Returns null if permission is denied or location services are not
  /// available.
  static Future<Location?> getRoundedGeolocation() async {
    List<ConcordiaBuilding>? searchCandidates;
    final Position userPosition;

    try {
      final bool serviceEnabled = await mapService.isLocationServiceEnabled();
      final bool hasPermission =
          await mapService.checkAndRequestLocationPermission();
      // check if location services are enabled
      if (!serviceEnabled) {
        return null;
      }
      // check if location permissions are granted
      if (!hasPermission) {
        return null;
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

  /// Iterates the events list. Returns a location if there is an event happening now or
  /// within the specified tolerance of minutes and it has a parseable location. Takes
  /// a now parameter to avoid inconsistent behaviour due to the clock ticking during
  /// the execution of the method.
  /// Otherwise returns null.
  static Future<Location?> _iterateEventListWithTolerance(
      ConcordiaBuilding? currentBuilding,
      DateTime now,
      List<UserCalendarEvent> eventsToday,
      int minutesTolerance) async {
    for (UserCalendarEvent event in eventsToday) {
      var startTime = event.localStart;
      var endTime = event.localEnd;
      if (minutesTolerance > 0) {
        startTime = startTime.subtract(Duration(minutes: minutesTolerance));
      }
      if (minutesTolerance < 0) {
        endTime = endTime.add(Duration(minutes: minutesTolerance));
      }
      if (startTime.isBefore(now) &&
          endTime.isAfter(now) &&
          event.locationField != null) {
        var eventLocation = await parseRoomNumber(event.locationField!);
        if (eventLocation != null) return eventLocation;
      }
    }
    return null;
  }

  /// If there is an in-progress calendar event, this will return the location of that
  /// event if there is a parseable one (as above) or null if not.
  ///
  /// If there is no in-progress calendar event, it will first look back 15 minutes to
  /// see if that event is parseable (eg. class ran overtime).
  ///
  /// If no previous event location was found, it will then look ahead 15 minutes to
  /// see if that event is parseable for a location.
  ///
  /// If no location is found from these events, it will return null.
  ///
  /// If a ConcordiaBuilding is passed, only locations in this building will be accepted
  /// in doing the evaluation.
  static Future<Location?> getProximalCalendarEventLocation(
      ConcordiaBuilding? currentBuilding) async {
    // TODO we need to maintain some state for which calendars the user has selected
    // in the settings. Right now we are looking at all calendars.
    var eventsToday = await calendarRepository.getEventsOnLocalDate(null, 0);
    var now = DateTime.now();
    return await _iterateEventListWithTolerance(
            currentBuilding, now, eventsToday, 0) ??
        await _iterateEventListWithTolerance(
            currentBuilding, now, eventsToday, -15) ??
        await _iterateEventListWithTolerance(
            currentBuilding, now, eventsToday, 15);
  }

  /// This method uses geolocation and calendar data to decide where the user is to the
  /// room level.
  ///
  /// If both geolocation and calendar are available/return a location, and the calendar
  /// location is in the same building as the geolocation, it will return the calendar
  /// event location.
  ///
  /// If both geolocation and calendar are available but disagree, it will return the
  /// building-rounded geolocation.
  ///
  /// If either of the two sources are not available, it will return from the other
  /// source.
  ///
  /// If neither of the two sources are available, it will return null.
  static Future<Location?> getCurrentClassroom() async {
    Location? geolocation = await getRoundedGeolocation();

    if (geolocation != null && geolocation.runtimeType == ConcordiaBuilding) {
      var calendarLocation = await getProximalCalendarEventLocation(
          geolocation as ConcordiaBuilding);
      if (calendarLocation != null) {
        return calendarLocation;
      }
    }

    if (geolocation != null) return geolocation;

    var calendarLocation = await getProximalCalendarEventLocation(null);
    if (calendarLocation != null) return calendarLocation;

    return null;
  }

  static IndoorRoute _getDifferentBuildingRoute(
      BuildingData buildingData,
      FloorRoutablePoint origin,
      FloorRoutablePoint destination,
      bool isAccessible) {
    final IndoorRoute returnRoute = IndoorRoute(origin.floor.building, null,
        null, null, destination.floor.building, null, null, null);

    // We need to combine the route from this building
    // to its exit, to the exit of the next building to the room there
    final FloorRoutablePoint? originExitPoint = IndoorFeatureRepository
        .outdoorExitPointsByBuilding[origin.floor.building.abbreviation];
    if (originExitPoint != null) {
      dev.log("Origin exit point not null - getting route in origin building");
      final IndoorRoute originPortion =
          getIndoorRoute(buildingData, origin, originExitPoint, isAccessible);
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
      final IndoorRoute destinationPortion = getIndoorRoute(
          buildingData, destinationExitPoint, destination, isAccessible);
      returnRoute.secondIndoorPortionToConnection =
          destinationPortion.firstIndoorPortionToConnection;
      returnRoute.secondIndoorConnection =
          destinationPortion.firstIndoorConnection;
      returnRoute.secondIndoorPortionFromConnection =
          destinationPortion.secondIndoorPortionFromConnection;
    }

    return returnRoute;
  }

  static IndoorRoute _getDifferentFloorRoute(
      BuildingData buildingData,
      FloorRoutablePoint origin,
      FloorRoutablePoint destination,
      bool isAccessible) {
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

    final returnRoute = IndoorRoute(origin.floor.building, null, bestConnection,
        null, null, null, null, null);
    if (bestConnection == null) {
      dev.log("Couldn't find connection between floor "
          "${origin.floor.floorNumber} and ${destination.floor.floorNumber}");
      // No known way to connect these floors - need to return an indoor route
      // with just the building
      return returnRoute;
    }

    final originConnectionPoints =
        bestConnection.floorPoints[origin.floor.floorNumber];
    if (originConnectionPoints != null && originConnectionPoints.isNotEmpty) {
      dev.log("Origin conn points available - getting intra-floor route");

      // Select the closest connection point to the origin
      final ConcordiaFloorPoint closestOriginPoint =
          _findClosestConnectionPoint(origin, originConnectionPoints);

      final originFloorPortion = getIndoorRoute(
          buildingData, origin, closestOriginPoint, isAccessible);
      returnRoute.firstIndoorPortionToConnection =
          originFloorPortion.firstIndoorPortionToConnection;
    }

    final destinationConnectionPoints =
        bestConnection.floorPoints[destination.floor.floorNumber];
    if (destinationConnectionPoints != null &&
        destinationConnectionPoints.isNotEmpty) {
      dev.log("Dest conn points available - getting intra-floor route");

      // Select the closest connection point to the destination
      final ConcordiaFloorPoint closestDestPoint =
          _findClosestConnectionPoint(destination, destinationConnectionPoints);

      final destinationFloorPortion = getIndoorRoute(
          buildingData, closestDestPoint, destination, isAccessible);
      // The mismatch here is deliberate - intra-floor directions always
      // returned in firstIndoorPortionToConnection
      returnRoute.firstIndoorPortionFromConnection =
          destinationFloorPortion.firstIndoorPortionToConnection;
    }

    return returnRoute;
  }

  static IndoorRoute? _isSpecialCase(
      int? originWaypointIndex,
      int? destinationWaypointIndex,
      FloorRoutablePoint origin,
      FloorRoutablePoint destination,
      List<FloorRoutablePoint> waypointsOnFloor) {
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
    } else {
      return null;
    }
  }

  static List<int?> _getClosestWaypoint(
      List<FloorRoutablePoint> waypointsOnFloor,
      FloorRoutablePoint origin,
      FloorRoutablePoint destination) {
    int? originWaypointIndex;
    double? originWaypointDistance;
    int? destinationWaypointIndex;
    double? destinationWaypointDistance;
    for (int i = 0; i < waypointsOnFloor.length; i++) {
      final distanceFromOrigin =
          IndoorRoute.getDistanceBetweenPoints(origin, waypointsOnFloor[i]);
      final distanceFromDestination = IndoorRoute.getDistanceBetweenPoints(
          destination, waypointsOnFloor[i]);
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
    return [originWaypointIndex, destinationWaypointIndex];
  }

  static IndoorRoute _noBestNeighbor(
      List<int> route, FloorRoutablePoint origin) {
    for (int i = 0; i < route.length; i++) {
      dev.log("Climb: i=${i.toString()}, route[i]=${route[i].toString()}");
    }
    return IndoorRoute(
        origin.floor.building, null, null, null, null, null, null, null);
  }

  static Object _getClosestWaypointToDestination(
      int originWaypointIndex,
      int destinationWaypointIndex,
      Map<int, List<int>> waypointNavigability,
      List<FloorRoutablePoint> waypointsOnFloor,
      FloorRoutablePoint origin) {
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

        final distanceFromDestination = IndoorRoute.getDistanceBetweenPoints(
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
        return _noBestNeighbor(route, origin);
      }

      route.add(bestNeighbour);
    }
    return route;
  }

  static IndoorRoute getIndoorRoute(
      BuildingData buildingData,
      FloorRoutablePoint origin,
      FloorRoutablePoint destination,
      bool isAccessible) {
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
      return _getDifferentBuildingRoute(
          buildingData, origin, destination, isAccessible);
    }

    // Points are now in the same building but on different floors - find the
    // best connection between these floors, then recurse down to 2 intra-floor
    // routes
    if (origin.floor.floorNumber != destination.floor.floorNumber) {
      dev.log("Origin and destination points on different floors");
      return _getDifferentFloorRoute(
          buildingData, origin, destination, isAccessible);
    }

    // Points are now within the same floor - this is where we will do
    // steepest-ascent hill climbing to find a route.
    dev.log("getIndoorRoute - finding intra-floor route");

    //use the data directly from buildingData
    final Map<String, ConcordiaFloor> floorMap = {
      for (var f in buildingData.floors) f.floorNumber: f
    };

    final waypointsByFloor = buildingData.waypointsByFloor;
    final waypointNavigabilityGroupsByFloor = buildingData.waypointNavigability;

    final waypointsOnFloor = waypointsByFloor[origin.floor.floorNumber];
    final waypointNavigability =
        waypointNavigabilityGroupsByFloor[origin.floor.floorNumber];

    if (waypointsOnFloor == null || waypointNavigability == null) {
      // No floor routing data for this floor, need to return the null route
      dev.log("No indoor routing data for floor ${origin.floor.floorNumber}");
      return IndoorRoute(
          origin.floor.building, null, null, null, null, null, null, null);
    }

    // Find the closest waypoint to the origin and destination
    final closestWaypoints =
        _getClosestWaypoint(waypointsOnFloor, origin, destination);

    final originWaypointIndex = closestWaypoints[0];
    final destinationWaypointIndex = closestWaypoints[1];

    // Special cases
    final specialCase = _isSpecialCase(originWaypointIndex,
        destinationWaypointIndex, origin, destination, waypointsOnFloor);
    if (specialCase != null) {
      return specialCase;
    }

    // Now we do our hill-climbing - find a navigable waypoint that
    // takes us closest to our destination
    List<int> route = [originWaypointIndex!];
    final result = _getClosestWaypointToDestination(
        originWaypointIndex,
        destinationWaypointIndex!,
        waypointNavigability,
        waypointsOnFloor,
        origin);
    if (result is List<int>) {
      route = result;
    } else {
      return result as IndoorRoute;
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

  /// Finds the closest connection point to a given position
  static ConcordiaFloorPoint _findClosestConnectionPoint(
      FloorRoutablePoint position, List<ConcordiaFloorPoint> connectionPoints) {
    ConcordiaFloorPoint closest = connectionPoints.first;
    double minDistance = double.infinity;

    for (var point in connectionPoints) {
      // Simple Manhattan distance
      final double distance = (point.positionX - position.positionX).abs() +
          (point.positionY - position.positionY).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = point;
      }
    }

    return closest;
  }

  Future<Size> getSvgDimensions(String svgPath) async {
    // Default size in case we can't determine
    Size defaultSize = const Size(1024, 1024);

    try {
      // Load the SVG file
      final String svgString = await rootBundle.loadString(svgPath);

      // Parse the SVG to extract width and height
      // This is a simple regex approach - for production you might want a more robust parser
      final RegExp widthRegex = RegExp(r'width="([^"]*)"');
      final RegExp heightRegex = RegExp(r'height="([^"]*)"');

      final widthMatch = widthRegex.firstMatch(svgString);
      final heightMatch = heightRegex.firstMatch(svgString);

      if (widthMatch != null && heightMatch != null) {
        final width =
            double.tryParse(widthMatch.group(1)!) ?? defaultSize.width;
        final height =
            double.tryParse(heightMatch.group(1)!) ?? defaultSize.height;
        return Size(width, height);
      }

      // Try to get viewBox dimensions if width/height are not specified directly
      final RegExp viewBoxRegex = RegExp(r'viewBox="([^"]*)"');
      final viewBoxMatch = viewBoxRegex.firstMatch(svgString);

      if (viewBoxMatch != null) {
        final String viewBox = viewBoxMatch.group(1)!;
        final List<String> parts = viewBox.split(' ');

        if (parts.length >= 4) {
          final width = double.tryParse(parts[2]) ?? defaultSize.width;
          final height = double.tryParse(parts[3]) ?? defaultSize.height;
          return Size(width, height);
        }
      }

      return defaultSize;
    } catch (e) {
      dev.log('Error getting SVG dimensions: $e');
      return defaultSize;
    }
  }
}
