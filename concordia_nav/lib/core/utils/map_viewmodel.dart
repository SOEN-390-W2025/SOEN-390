import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../../data/domain-model/campus.dart';
import '../../data/services/map_service.dart';

class MapViewModel {
  final MapRepository _mapRepository = MapRepository();
  final MapService _mapService = MapService();

  /// Fetches the initial camera position for the given campus.
  Future<CameraPosition> getInitialCameraPosition(Campus campus) async {
    return _mapRepository.getCameraPosition(campus);
  }

  /// Handles map creation and initializes the map service.
  void onMapCreated(GoogleMapController controller) {
    _mapService.setMapController(controller);
  }

  /// Switches the map camera to a new campus.
  void switchCampus(Campus campus) {
    _mapService.moveCamera(LatLng(campus.lat, campus.lng));
  }

  /// Retrieves markers for campus buildings.
  Set<Marker> getCampusMarkers(List<LatLng> buildingLocations) {
    return _mapService.getCampusMarkers(buildingLocations);
  }
}
