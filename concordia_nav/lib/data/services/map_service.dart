import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/outdoor_directions_service.dart';
import '../domain-model/campus.dart';

class MapService {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  final DirectionsService _directionsService = DirectionsService();

  /// Sets the Google Maps controller.
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Returns the camera position for the given [campus].
  CameraPosition getInitialCameraPosition(Campus campus) {
    return CameraPosition(
      target: LatLng(campus.lat, campus.lng),
      zoom: 17.0,
    );
  }

  /// Moves the camera to a new position.
  void moveCamera(LatLng position, {double zoom = 17.0}) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  /// Adds markers for buildings (this method can be expanded).
  Set<Marker> getCampusMarkers(List<LatLng> buildingLocations) {
    return buildingLocations.map((latLng) {
      return Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
      );
    }).toSet();
  }

  /// Fetches route polyline and updates the map
  Future<List<LatLng>> getRoutePath(String originAddress, String destinationAddress) async {
    List<LatLng> routePoints = await _directionsService.fetchRoute(originAddress, destinationAddress);
    
    Polyline polyline = Polyline(
      polylineId: PolylineId('$originAddress\_$destinationAddress'),
      color: const Color(0xFF2196F3),
      width: 5,
      points: routePoints,
    );
    print("Created Polyline: ${polyline.polylineId} with ${polyline.points.length} points");
    _polylines.add(polyline);
    print("Polylines Set: $_polylines");
    return routePoints;
  }

  /// Returns all polylines
  Set<Polyline> getPolylines() {
    return _polylines;
  }
}