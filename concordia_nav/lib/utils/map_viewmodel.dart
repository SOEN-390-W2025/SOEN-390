// ignore_for_file: prefer_final_fields

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../data/domain-model/concordia_campus.dart';
import '../../data/services/map_service.dart';
import '../data/domain-model/concordia_building.dart';
import '../../data/repositories/building_repository.dart';

class MapViewModel {
  MapRepository _mapRepository = MapRepository();
  MapService _mapService = MapService();

  MapViewModel({MapRepository? mapRepository, MapService? mapService})
      : _mapRepository = mapRepository ?? MapRepository(),
        _mapService = mapService ?? MapService();

  /// Fetches the initial camera position for the given campus.
  Future<CameraPosition> getInitialCameraPosition(
      ConcordiaCampus campus) async {
    return _mapRepository.getCameraPosition(campus);
  }

  /// Handles map creation and initializes the map service.
  void onMapCreated(GoogleMapController controller) {
    _mapService.setMapController(controller);
  }

  /// Switches the map camera to a new campus.
  void switchCampus(ConcordiaCampus campus) {
    _mapService.moveCamera(LatLng(campus.lat, campus.lng));
  }

  /// Retrieves markers for campus buildings.
  Set<Marker> getCampusMarkers(String campusAbbreviation) {
    final List<ConcordiaBuilding> buildings =
        BuildingRepository.buildingByCampusAbbreviation[campusAbbreviation] ?? [];

    final List<LatLng> buildingLocations =
        buildings.map((b) => LatLng(b.lat, b.lng)).toList();

    return _mapService.getCampusMarkers(buildingLocations); // ✅ Uses existing method
  }
}
