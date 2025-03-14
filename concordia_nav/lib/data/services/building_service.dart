// ignore_for_file: prefer_final_locals
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/concordia_building.dart';
import '../domain-model/concordia_campus.dart';
import '../repositories/building_repository.dart';

class BuildingService {
  // Retrieve all buildings
  List<ConcordiaBuilding> getAllBuildings() {
    return [
      ...BuildingRepository
          .buildingByCampusAbbreviation[ConcordiaCampus.sgw.abbreviation]!,
      ...BuildingRepository
          .buildingByCampusAbbreviation[ConcordiaCampus.loy.abbreviation]!,
    ];
  }

  // Get buildings by campus abbreviation (SGW or Loyola)
  List<ConcordiaBuilding> getBuildingsByCampus(String campusAbbreviation) {
    return BuildingRepository
            .buildingByCampusAbbreviation[campusAbbreviation] ??
        [];
  }

  // Retrieve building details based on abbreviation
  ConcordiaBuilding? getBuildingByAbbreviation(String abbreviation) {
    return BuildingRepository
        .buildingByAbbreviation[abbreviation.toUpperCase()];
  }

  // Retrieve building names for a specific campus
  List<String> getBuildingNamesForCampus(ConcordiaCampus campus) {
    final buildings =
        BuildingRepository.buildingByCampusAbbreviation[campus.abbreviation];
    if (buildings != null) {
      return buildings.map((building) => building.name).toList();
    }
    return [];
  }

  // Retrieve the location (LatLng) of a building by abbreviation
  LatLng? getBuildingLocationByAbbreviation(String abbreviation) {
    final building =
        BuildingRepository.buildingByAbbreviation[abbreviation.toUpperCase()];
    if (building != null) {
      return LatLng(building.lat, building.lng);
    }
    return null;
  }

  // Retrieve a building by its name
  static ConcordiaBuilding? getBuildingByName(String name) {
    // Iterates through all buildings and finds the one with the matching name
    for (var building in BuildingRepository.buildingByAbbreviation.values) {
      if (building.name == name) {
        return building;
      }
    }
    return null; // Return null if no building matches the name
  }

  // Retrieve a building by its abbreviation
  static ConcordiaBuilding? getbuildingByAbbreviation(String abbreviation) {
    // Iterates through all buildings and finds the one with the matching abbreviation
    for (var building in BuildingRepository.buildingByAbbreviation.values) {
      if (building.abbreviation == abbreviation) {
        return building;
      }
    }
    return null; // Return null if no building matches the abbreviation
  }
}
