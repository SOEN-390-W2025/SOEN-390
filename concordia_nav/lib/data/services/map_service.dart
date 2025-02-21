// ignore_for_file: prefer_final_locals

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/outdoor_directions_service.dart';
import '../domain-model/concordia_campus.dart';
import 'helpers/icon_loader.dart';

class MapService {
  late GoogleMapController _mapController;
  final Set<Polyline> _polylines = {};
  ODSDirectionsService _directionsService = ODSDirectionsService();

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void setDirectionsService(ODSDirectionsService directionsService) {
    _directionsService = directionsService;
  }

  /// Returns the camera position for the given [campus].
  CameraPosition getInitialCameraPosition(ConcordiaCampus campus) {
    return CameraPosition(
      target: LatLng(campus.lat, campus.lng),
      zoom: 17.0,
    );
  }

  void moveCamera(LatLng position, {double zoom = 17.0}) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  /// Loads a custom icon for each label from /assets/icons/{name}.png.
  Future<BitmapDescriptor> getCustomIcon(String name) async {
    final String iconPath = 'assets/icons/$name.png';
    return IconLoader.loadBitmapDescriptor(iconPath);
  }

  /// Zoom in function
  Future<void> zoomIn() async {
    final currentZoom = await _mapController.getZoomLevel();
    await _mapController.animateCamera(CameraUpdate.zoomTo(currentZoom + 1));
  }

  /// Zoom out function
  Future<void> zoomOut() async {
    final currentZoom = await _mapController.getZoomLevel();
    await _mapController.animateCamera(CameraUpdate.zoomTo(currentZoom - 1));
  }

  /// Checks if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks and requests location permissions.
  Future<bool> checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Permission denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Permission permanently denied
    }

    return true; // Permission granted
  }

  /// Fetches the user's current location.
  Future<LatLng?> getCurrentLocation() async {
    final bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    final bool hasPermission = await checkAndRequestLocationPermission();
    if (!hasPermission) {
      return Future.error('Location permissions are denied.');
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  /// Returns the distance (in meters) between two locations.
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Fetches route polyline using addresses or current location
  Future<List<LatLng>> getRoutePath(
      String? originAddress, String destinationAddress) async {
    List<LatLng> routePoints;

    if (originAddress == null || originAddress.isEmpty) {
      final LatLng? currentLocation = await getCurrentLocation();
      if (currentLocation == null) {
        throw Exception("Unable to fetch current location.");
      }
      routePoints = await _directionsService.fetchRouteFromCoords(
        currentLocation,
        destinationAddress,
      );
    } else {
      routePoints = await _directionsService.fetchRoute(
          originAddress, destinationAddress);
    }

    final Polyline polyline = Polyline(
      polylineId:
          PolylineId('${originAddress ?? "current"}_$destinationAddress'),
      color: const Color(0xFF2196F3),
      width: 5,
      points: routePoints,
    );
    _polylines.add(polyline);
    return routePoints;
  }

  /// Returns all polylines
  Set<Polyline> getPolylines() {
    return _polylines;
  }
}
