// ignore_for_file: prefer_final_fields

import "package:google_maps_flutter/google_maps_flutter.dart";
import "../data/domain-model/concordia_building.dart";
import "../data/domain-model/concordia_campus.dart";
import "../data/domain-model/concordia_room.dart";
import "../data/repositories/building_data.dart";
import "../data/repositories/building_data_manager.dart";
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
    return BuildingService.getBuildingByName(name);
  }

  String? getBuildingAbbreviation(String name) {
    final building = getBuildingByName(name);
    return building?.abbreviation;
  }

  ConcordiaBuilding? getBuildingByAbbreviation(String abbreviation) {
    return _buildingService.getBuildingByAbbreviation(abbreviation);
  }

  LatLng? getBuildingLocationByAbbreviation(String abbreviation) {
    return _buildingService.getBuildingLocationByAbbreviation(abbreviation);
  }

  LatLng? getBuildingLocationByName(String name) {
    final building = getBuildingByName(name);
    return building != null ? LatLng(building.lat, building.lng) : null;
  }

  Future<List<String>> getFloorsForBuilding(String buildingName) async {
    final ConcordiaBuilding building = getBuildingByName(buildingName)!;
    final String abbreviation = building.abbreviation.toUpperCase();

    // Use BuildingDataManager to get the building data
    final BuildingData? buildingData =
        await BuildingDataManager.getBuildingData(abbreviation);

    if (buildingData == null) {
      return [];
    }

    // Map floors to a list of strings with the floor number
    return buildingData.floors
        .map((floor) => "Floor ${floor.floorNumber}")
        .toList();
  }

  Future<List<ConcordiaRoom>> getRoomsForFloor(
      String buildingName, String floorName) async {
    final ConcordiaBuilding building = getBuildingByName(buildingName)!;
    final String abbreviation = building.abbreviation.toUpperCase();

    // Use BuildingDataManager to get the building data
    final BuildingData? buildingData =
        await BuildingDataManager.getBuildingData(abbreviation);

    if (buildingData == null) {
      return [];
    }

    // Extract floor number from the floor name
    final String floorNumber = floorName.replaceFirst("Floor ", "");

    // Return rooms for the specified floor, or an empty list if not found
    return buildingData.roomsByFloor[floorNumber] ?? [];
  }

  // Get building from a location string (e.g., "H 1140")
  ConcordiaBuilding? getBuildingFromLocation(String location) {
    final List<String> parts = location.split(" ");
    if (parts.isEmpty) return null;

    final String abbreviation = parts[0];
    return getBuildingByAbbreviation(abbreviation);
  }
  
  /// Get only buildings that have available data
  Future<List<String>> getAvailableBuildings() async {
    final List<String> availableBuildings = [];
    final List<String> allBuildings = getBuildings();
    
    for (final buildingName in allBuildings) {
      final building = getBuildingByName(buildingName);
      if (building != null) {
        // Check if building data exists
        final buildingData = await BuildingDataManager.getBuildingData(building.abbreviation);
        if (buildingData != null) {
          availableBuildings.add(buildingName);
        }
      }
    }
    
    return availableBuildings;
  }
}