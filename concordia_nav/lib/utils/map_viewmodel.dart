// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/map_repository.dart';
import '../data/domain-model/concordia_campus.dart';
import '../../data/services/map_service.dart';
import '../data/domain-model/concordia_building.dart';
import '../../data/repositories/building_repository.dart';

class MapViewModel extends ChangeNotifier{
  MapRepository _mapRepository = MapRepository();
  MapService _mapService = MapService();

  ValueNotifier<ConcordiaBuilding?> selectedBuildingNotifier = ValueNotifier<ConcordiaBuilding?>(null);

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

    return buildings.map((building) {
      return Marker(
        markerId: MarkerId(building.abbreviation),
        position: LatLng(building.lat, building.lng),
        // When the marker is tapped, update selectedBuilding
        onTap: () {
          selectBuilding(building);
        },
      );
    }).toSet();
  }

  /// Sets the selected building and notifies listeners.
  void selectBuilding(ConcordiaBuilding building) {
    selectedBuildingNotifier.value = building;
  }

  void unselectBuilding() {
    selectedBuildingNotifier.value = null;
  }
}
