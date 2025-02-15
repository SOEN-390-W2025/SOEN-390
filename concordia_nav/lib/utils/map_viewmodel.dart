// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../../data/domain-model/campus.dart';
import '../../data/services/map_service.dart';

class MapViewModel {
  MapRepository _mapRepository = MapRepository();
  MapService _mapService = MapService();

  MapViewModel({MapRepository? mapRepository, MapService? mapService})
      : _mapRepository = mapRepository ?? MapRepository(),
        _mapService = mapService ?? MapService();

  /// Mapservice getter
  MapService get mapService => _mapService;

  /// Fetches the initial camera position for the given campus.
  Future<CameraPosition> getInitialCameraPosition(Campus campus) async {
    return _mapRepository.getCameraPosition(campus);
  }

  /// Get outdoor routing
  Future<List<LatLng>> getRoutePolyline(String originAddress, String destinationAddress) async {
    return await _mapService.getRoutePath(originAddress, destinationAddress);
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
  void switchCampus(Campus campus) {
    _mapService.moveCamera(LatLng(campus.lat, campus.lng));
  }

  /// Retrieves markers for campus buildings.
  Set<Marker> getCampusMarkers(List<LatLng> buildingLocations) {
    return _mapService.getCampusMarkers(buildingLocations);
  }
  
    /// Fetches the current location without moving the map.
  Future<LatLng?> fetchCurrentLocation() async {
    return await _mapService.getCurrentLocation();
  }

  /// Checks if location services are enabled and requests permission.
  Future<bool> checkLocationAccess() async {
    final bool serviceEnabled = await _mapService.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final bool hasPermission = await _mapService.checkAndRequestLocationPermission();
    return hasPermission;
  }

  /// Fetches current location and moves the camera.
  Future<bool> moveToCurrentLocation(BuildContext context) async {
    final bool hasAccess = await checkLocationAccess();
    if (!hasAccess) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services or permissions are not available.")),
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
}