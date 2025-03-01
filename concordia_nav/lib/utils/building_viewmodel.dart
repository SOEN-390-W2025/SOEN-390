// ignore_for_file: prefer_final_fields

import "package:google_maps_flutter/google_maps_flutter.dart";
import "../data/domain-model/concordia_building.dart";
import "../data/domain-model/concordia_campus.dart";
import "../data/domain-model/concordia_room.dart";
import "../data/repositories/indoor_feature_repository.dart";
import "../data/services/building_service.dart";

class BuildingViewModel {
  BuildingService _buildingService = BuildingService();

  BuildingViewModel({BuildingService? buildingService})
      : _buildingService = buildingService ?? BuildingService();

  List<String> getBuildingsByCampus(ConcordiaCampus campus) {
    return _buildingService.getBuildingNamesForCampus(campus);
  }

  List<String> getBuildings() {
    final sgwBuildings =
        _buildingService.getBuildingNamesForCampus(ConcordiaCampus.sgw);
    final loyBuildings =
        _buildingService.getBuildingNamesForCampus(ConcordiaCampus.loy);

    final allBuildings = [...sgwBuildings, ...loyBuildings];

    // Return the combined list of buildings
    return allBuildings;
  }

  /// Use the BuildingService to get the building by name
  ConcordiaBuilding? getBuildingByName(String name) {
    return BuildingService.getbuildingByName(name);
  }

  String? getBuildingAbbreviation(String name) {
    final building = getBuildingByName(name);
    return building?.abbreviation;
  }

  LatLng? getBuildingLocationByAbbreviation(String abbreviation) {
    return _buildingService.getBuildingLocationByAbbreviation(abbreviation);
  }

  LatLng? getBuildingLocationByName(String name) {
    final building = getBuildingByName(name);
    return building != null ? LatLng(building.lat, building.lng) : null;
  }

  List<String> getFloorsForBuilding(String buildingName) {
    final String? abbreviation = getBuildingAbbreviation(buildingName);
    if (abbreviation == null) return [];
    
    return IndoorFeatureRepository.floorsByBuilding[abbreviation]
            ?.map((floor) => "Floor ${floor.floorNumber}")
            .toList() ?? [];
  }

  List<ConcordiaRoom> getRoomsForFloor(String buildingName, String floorName) {
    final String? abbreviation = getBuildingAbbreviation(buildingName);
    if (abbreviation == null) return [];
    final String floorNumber = floorName.replaceFirst("Floor ", "");

    return IndoorFeatureRepository.roomsByFloor[abbreviation]?[floorNumber] ?? [];
  }
}
