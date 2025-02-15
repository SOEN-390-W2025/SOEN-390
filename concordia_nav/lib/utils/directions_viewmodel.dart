import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/outdoor_directions_service.dart';

class DirectionsViewModel {
  final DirectionsService _directionsService = DirectionsService();
  ///Fetch route polyline and return it
  Future<Polyline> getRoutePolyline(String originAddress, String destinationAddress) async {
    List<LatLng> routePoints = await _directionsService.fetchRoute(originAddress, destinationAddress);

    return Polyline(
      polylineId: const PolylineId("route"),
      points: routePoints,
      color: const Color(0xFF4285F4),
      width: 5,
    );
  }
}