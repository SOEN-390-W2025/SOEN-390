import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/concordia_campus.dart';
import 'package:geolocator/geolocator.dart';

class MapService {
  late GoogleMapController _mapController;

  /// Sets the Google Maps controller.
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Returns the camera position for the given [campus].
  CameraPosition getInitialCameraPosition(ConcordiaCampus campus) {
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
}
