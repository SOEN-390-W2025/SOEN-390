import 'package:geolocator/geolocator.dart';
import '../domain-model/concordia_building.dart';
import '../domain-model/concordia_campus.dart';
import '../domain-model/location.dart';
import '../repositories/building_repository.dart';
import 'map_service.dart';

class IndoorRoutingService {
  //IndoorRoute getRoute(Location origin, Location destination) {}

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
    final MapService _mapService = MapService();

    try {
      
      final bool serviceEnabled = await _mapService.isLocationServiceEnabled();
      final bool hasPermission = await _mapService.checkAndRequestLocationPermission();
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
}
