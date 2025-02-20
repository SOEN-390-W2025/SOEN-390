import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../data/domain-model/concordia_campus.dart';
import '../../data/services/map_service.dart';
import '../data/services/helpers/icon_loader.dart';

class MapViewModel {
  final MapRepository _mapRepository;
  final MapService _mapService;

  MapViewModel({MapRepository? mapRepository, MapService? mapService})
      : _mapRepository = mapRepository ?? MapRepository(),
        _mapService = mapService ?? MapService();

  // Holds the current set of polylines to be rendered.
  Set<Polyline> _polylines = {};

  /// Getter for polylines
  Set<Polyline> get polylines => _polylines;

  // Destination marker for the route.
  Marker? _destinationMarker;
  Marker? get destinationMarker => _destinationMarker;

  /// Exposes the MapService.
  MapService get mapService => _mapService;

  /// Returns the initial camera position for the given campus.
  Future<CameraPosition> getInitialCameraPosition(
      ConcordiaCampus campus) async {
    return _mapRepository.getCameraPosition(campus);
  }

  /// Fetches the route and updates the polyline and destination marker.
  Future<void> fetchRoute(
      String? originAddress, String destinationAddress) async {
    try {
      // Get the route as a list of LatLng coordinates.
      final List<LatLng> routePoints =
          await _mapService.getRoutePath(originAddress, destinationAddress);

      // Create a new polyline with a dashed pattern.
      final Polyline polyline = Polyline(
        polylineId:
            PolylineId('${originAddress ?? "current"}_$destinationAddress'),
        color: const Color(0xFF0c79fe),
        width: 5,
        points: routePoints,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      );

      _polylines = {polyline};

      // Create a marker for the end user to visualize the destination coords.
      if (routePoints.isNotEmpty) {
        _destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: routePoints.last,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: await IconLoader.loadBitmapDescriptor(
              'assets/icons/destination.png'),
        );
      }
    } catch (e) {
      throw Exception("Failed to load directions: $e");
    }
  }

  /// Handles map creation and initializes the map service.
  void onMapCreated(GoogleMapController controller) {
    _mapService.setMapController(controller);
  }

  /// Moves the map to the given location.
  void moveToLocation(LatLng location) {
    _mapService.moveCamera(location);
  }

  /// Switches the map camera to a new campus.
  void switchCampus(ConcordiaCampus campus) {
    _mapService.moveCamera(LatLng(campus.lat, campus.lng));
  }

  /// Fetches both polygons and labeled icons for a given campus building.
  Future<Map<String, dynamic>> getCampusPolygonsAndLabels(
      ConcordiaCampus campus) {
    return _mapService.getCampusPolygonsAndLabels(campus);
  }

  /// Fetches the current location without moving the map.
  Future<LatLng?> fetchCurrentLocation() async {
    return await _mapService.getCurrentLocation();
  }

  /// Checks if location services are enabled and requests permission.
  Future<bool> checkLocationAccess() async {
    final bool serviceEnabled = await _mapService.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final bool hasPermission =
        await _mapService.checkAndRequestLocationPermission();
    return hasPermission;
  }

  /// Fetches current location and moves the camera.
  Future<bool> moveToCurrentLocation(BuildContext? context) async {
    final bool hasAccess = await checkLocationAccess();
    if (!hasAccess) {
      if (context!.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location services or permissions are not available. Please enable them in settings.",
            ),
          ),
        );
      }
      return false;
    }

    final LatLng? currentLocation = await fetchCurrentLocation();
    if (currentLocation != null) {
      _mapService.moveCamera(currentLocation);
      return true;
    }
    return false;
  }

  /// Zoom in function
  Future<void> zoomIn() async {
    await _mapService.zoomIn();
  }

  /// Zoom out function
  Future<void> zoomOut() async {
    await _mapService.zoomOut();
  }

  /// Calculates the distance between two points using the service.
  double getDistance(LatLng point1, LatLng point2) {
    return _mapService.calculateDistance(point1, point2);
  }
}
