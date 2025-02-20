import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/outdoor_directions_service.dart';
import '../data/services/map_service.dart';

class DirectionsViewModel {
  final DirectionsService _directionsService = DirectionsService();
  final MapService _mapService = MapService();

  /// Returns a polyline (as a list of LatLng) for the given route.
  /// If no origin is provided, the current location is fetched.
  Future<List<LatLng>> getRoutePolyline(
      String? originAddress, String destinationAddress) async {
    String origin;
    if (originAddress == null || originAddress.isEmpty) {
      final LatLng? currentLocation = await _mapService.getCurrentLocation();
      if (currentLocation == null) {
        throw Exception("Unable to fetch current location.");
      }
      origin = "${currentLocation.latitude},${currentLocation.longitude}";
    } else {
      origin = originAddress;
    }

    return _directionsService.fetchRoute(origin, destinationAddress);
  }
}
