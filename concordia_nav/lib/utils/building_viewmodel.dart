// ignore_for_file: prefer_final_fields

import "package:flutter/services.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:yaml/yaml.dart";
import "../data/domain-model/concordia_building.dart";
import "../data/domain-model/concordia_campus.dart";
import "../data/domain-model/concordia_floor.dart";
import "../data/domain-model/concordia_room.dart";
import "../data/repositories/building_data.dart";
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

  Future<List<String>> getFloorsForBuilding(String buildingName) async {
    final ConcordiaBuilding building = getBuildingByName(buildingName)!;

    // Load YAML data for the building
    final dynamic yamlData = await getYamlDataForBuilding(building.abbreviation.toUpperCase());

    // Load floors based on the YAML data
    final loadedFloors = loadFloors(yamlData, building);
    final List<ConcordiaFloor> floors = loadedFloors[0];

    // Map floors to a list of strings with the floor number
    return floors.map((floor) => "Floor ${floor.floorNumber}").toList();
  }

  // Load YAML data for a building
  Future<dynamic> getYamlDataForBuilding(String abbreviation) async {
    final String yamlString = await rootBundle.loadString('${BuildingData.dataPath}$abbreviation.yaml');

    final dynamic yamlData = loadYaml(yamlString);

    return yamlData;
  }

  Future<List<ConcordiaRoom>> getRoomsForFloor(String buildingName, String floorName) async{
    final ConcordiaBuilding building = getBuildingByName(buildingName)!;

    // Load YAML data for the building
    final dynamic yamlData = await getYamlDataForBuilding(building.abbreviation.toUpperCase());
    final loadedFloors = loadFloors(yamlData, building);

    // Create a map of floors for easier lookup
    final Map<String, ConcordiaFloor> floorMap = loadedFloors[1];

    // Load rooms by floor using floorMap
    final Map<String, List<ConcordiaRoom>> roomsByFloor = loadRooms(yamlData, floorMap);

    final String floorNumber = floorName.replaceFirst("Floor ", "");

    // Return rooms for the specified floor, or an empty list if not found
    return roomsByFloor[floorNumber] ?? [];
  }
}
