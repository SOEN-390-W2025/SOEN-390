import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/domain-model/campus.dart';

class MapService {
  late GoogleMapController _mapController;

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
}
