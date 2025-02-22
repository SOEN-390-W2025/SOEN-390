// ignore_for_file: prefer_final_fields

import "package:google_maps_flutter/google_maps_flutter.dart";
import "../data/domain-model/concordia_building.dart";
import "../data/domain-model/concordia_campus.dart";
import "../data/services/building_service.dart";

class BuildingViewModel {
  BuildingService _buildingService = BuildingService();

  BuildingViewModel({BuildingService? buildingService})
  : _buildingService = buildingService ?? BuildingService();

  List<String> getBuildingsByCampus(ConcordiaCampus campus) {
    return _buildingService.getBuildingNamesForCampus(campus);
  }

  List<String> getBuildings() {
    final sgwBuildings = _buildingService.getBuildingNamesForCampus(ConcordiaCampus.sgw);
    final loyBuildings = _buildingService.getBuildingNamesForCampus(ConcordiaCampus.loy);

    final allBuildings = [...sgwBuildings, ...loyBuildings];

    // Return the combined list of buildings
    return allBuildings;
  }

  /// Use the BuildingService to get the building by name
  ConcordiaBuilding? getBuildingByName(String name) {
    return BuildingService.getbuildingByName(name);
  }


  LatLng? getBuildingLocationByAbbreviation(String abbreviation) {
    return _buildingService.getBuildingLocationByAbbreviation(abbreviation);
  }

  LatLng? getBuildingLocationByName(String name) {
    final building = getBuildingByName(name);
    return building != null ? LatLng(building.lat, building.lng) : null;
  }


}