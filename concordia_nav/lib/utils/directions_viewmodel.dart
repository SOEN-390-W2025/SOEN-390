import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/outdoor_directions_service.dart';
import '../data/services/map_service.dart';

class DirectionsViewModel {
  final DirectionsService _directionsService = DirectionsService();
  final MapService _mapService = MapService();

  /// Fetch route polyline and return it
  Future<List<LatLng>> getRoutePolyline(String? originAddress, String destinationAddress) async {
    String origin;

    if (originAddress == null || originAddress.isEmpty) {
      LatLng? currentLocation = await _mapService.getCurrentLocation();
      if (currentLocation == null) {
        throw Exception("Unable to fetch current location.");
      }
      origin = "${currentLocation.latitude},${currentLocation.longitude}";
    } else {
      origin = originAddress;
    }

    // Fetch the route from the DirectionsService
    List<LatLng> routePoints = await _directionsService.fetchRoute(origin, destinationAddress);
    return routePoints;
  }
}