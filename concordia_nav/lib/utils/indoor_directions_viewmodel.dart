// ignore_for_file: prefer_final_locals, avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_room.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concrete_floor_routable_point.dart';
import '../data/domain-model/connection.dart';
import '../data/domain-model/indoor_route.dart';
import '../data/repositories/building_data.dart';
import '../data/repositories/building_data_manager.dart';
import '../data/services/indoor_routing_service.dart';
import 'building_viewmodel.dart';

import 'dart:developer' as dev;

class IndoorDirectionsViewModel extends ChangeNotifier {
  final BuildingViewModel _buildingViewModel = BuildingViewModel();

  bool _isAccessibilityMode = false;
  final String _eta = '5 min';
  IndoorRoute? _calculatedRoute;
  Offset _startLocation = Offset.zero;
  Offset _endLocation = Offset.zero;

  // Getters
  bool get isAccessibilityMode => _isAccessibilityMode;
  String get eta => _eta;
  IndoorRoute? get calculatedRoute => _calculatedRoute;
  Offset get startLocation => _startLocation;
  Offset get endLocation => _endLocation;

  // Method to toggle accessibility mode
  void toggleAccessibilityMode(bool value) {
    _isAccessibilityMode = value;
    notifyListeners();
  }

  Future<ConcordiaFloorPoint?> getPositionPoint(
      String buildingName, String floor, String room) async {
    // Get the building by name
    final ConcordiaBuilding building =
        BuildingViewModel().getBuildingByName(buildingName)!;

    // Load YAML data for the building
    final dynamic yamlData = await BuildingViewModel()
        .getYamlDataForBuilding(building.abbreviation.toUpperCase());

    // Load floors and rooms from the YAML data
    final loadedFloors = loadFloors(yamlData, building);
    final Map<String, ConcordiaFloor> floorMap = loadedFloors[1];
    final Map<String, List<ConcordiaRoom>> roomsByFloor =
        loadRooms(yamlData, floorMap);

    // Get the list of rooms for the given floor
    final rooms = roomsByFloor[floor];

    // Remove the floor part of the room identifier
    String roomNumber = room.replaceFirst(floor, '');

    // Remove the leading '0' if it exists
    if (roomNumber.startsWith('0')) {
      int leadingZerosCount = 0;
      for (int i = 0; i < roomNumber.length; i++) {
        if (roomNumber[i] == '0') {
          leadingZerosCount++;
        } else {
          break;
        }
      }

      // If there's more than one leading zero, remove the first one
      if (leadingZerosCount == 1) {
        roomNumber = roomNumber.substring(1);
      }
    }

    if (rooms != null) {
      // Find the room by its number
      final roomFound = rooms.firstWhere(
        (room) => room.roomNumber == roomNumber,
      );

      // Return the entrancePoint if the room is found
      return roomFound.entrancePoint;
    }

    // Return null if the floor or room wasn't found
    return null;
  }

  ConcordiaFloorPoint? _getRegularStartPoint(BuildingData buildingData, String floor) {
    // Try escalators first if no disability
    try {
      Connection escalatorConnection = buildingData.connections.firstWhere(
          (conn) => conn.name.toLowerCase().contains("escalators"));

      final floorPoints = escalatorConnection.floorPoints[floor];
      if (floorPoints != null && floorPoints.isNotEmpty) {
        return floorPoints.first;
      }
    } catch (e) {
      // No matching escalator found
      return null;
    }

    // Try stairs as fallback if no escalators for this floor
    try {
      Connection stairsConnection = buildingData.connections
          .firstWhere((conn) => conn.name.toLowerCase().contains("stairs"));

      final floorPoints = stairsConnection.floorPoints[floor];
      if (floorPoints != null && floorPoints.isNotEmpty) {
        // Use a specific stair point (third in the list, if available)
        return floorPoints.length > 3 ? floorPoints[3] : floorPoints.first;
      }
    } catch (e) {
      // No matching stairs found
      return null;
    }
    return null;
  }

  Future<ConcordiaFloorPoint?> getStartPoint(
      String buildingName, String floor, bool disability) async {
    // Get the building by name
    final ConcordiaBuilding building =
        BuildingViewModel().getBuildingByName(buildingName)!;

    // Load building data
    final buildingData = await BuildingDataManager.getBuildingData(
        building.abbreviation.toUpperCase());

    // If floor is "1", simply return the outdoor exit point
    if (floor == '1') {
      return buildingData!.outdoorExitPoint;
    }

    // Find appropriate connection based on accessibility needs
    if (disability) {
      // If person has disability, look for accessible elevators
      Connection? elevatorConnection;
      try {
        elevatorConnection = buildingData!.connections.firstWhere((conn) =>
            conn.name.toLowerCase().contains("main elevators") &&
            conn.isAccessible);

        final floorPoints = elevatorConnection.floorPoints[floor];
        if (floorPoints != null && floorPoints.isNotEmpty) {
          return floorPoints.first;
        }
      } catch (e) {
        // No matching elevator found
      }
    } else {
      final regularStartPoint = _getRegularStartPoint(buildingData!, floor);
      if (regularStartPoint != null){
        return regularStartPoint;
      }
    }

    // If no appropriate connection found, try any available connection
    for (var connection in buildingData!.connections) {
      final floorPoints = connection.floorPoints[floor];
      if (floorPoints != null && floorPoints.isNotEmpty) {
        return floorPoints.first;
      }
    }

    // Return null if no point found for the floor
    return null;
  }

  Future<void> calculateRoute(String building, String floor, String sourceRoom,
      String endRoom, bool disability) async {
    try {
      final sourceRoomClean =
          sourceRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');
      final endRoomClean = endRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');

      final buildingAbbreviation =
          _buildingViewModel.getBuildingAbbreviation(building)!;
      final dynamic yamlData =
          await _buildingViewModel.getYamlDataForBuilding(buildingAbbreviation);

      ConcordiaFloorPoint? startPositionPoint;
      ConcordiaFloorPoint? endPositionPoint;

      // Get start location (elevator point)
      if (sourceRoomClean == 'Your Location') {
        dev.log(disability.toString());
        startPositionPoint = await getStartPoint(building, floor, disability);
      } else {
        startPositionPoint =
            await getPositionPoint(building, floor, sourceRoomClean);
      }

      // Get end location (room point), handle "Your Location"
      if (endRoomClean == 'Your Location') {
        dev.log('End room is "Your Location", using current position');
        endPositionPoint = await getStartPoint(
            building, floor, disability); // Assuming same logic as start
      } else {
        endPositionPoint =
            await getPositionPoint(building, floor, endRoomClean);
      }

      if (startPositionPoint != null && endPositionPoint != null) {
        _startLocation =
            Offset(startPositionPoint.positionX, startPositionPoint.positionY);
        _endLocation =
            Offset(endPositionPoint.positionX, endPositionPoint.positionY);

        final ConcordiaBuilding buildingData =
            _buildingViewModel.getBuildingByName(building)!;
        final currentFloor = ConcordiaFloor(floor, buildingData);

        // Create FloorRoutablePoint for start and end
        final startRoutablePoint = ConcreteFloorRoutablePoint(
          floor: currentFloor,
          positionX: startPositionPoint.positionX,
          positionY: startPositionPoint.positionY,
        );

        final endRoutablePoint = ConcreteFloorRoutablePoint(
          floor: currentFloor,
          positionX: endPositionPoint.positionX,
          positionY: endPositionPoint.positionY,
        );

        // Calculate route based on accessibility mode
        _calculatedRoute = IndoorRoutingService.getIndoorRoute(yamlData,
            startRoutablePoint, endRoutablePoint, _isAccessibilityMode);

        notifyListeners();
      } else {
        // Handle case when start or end point is null (you may want to show an error or fallback logic)
      }
    } catch (e) {
      rethrow; // Let the view handle the error
    }
  }

  Future<Size> getSvgDimensions(String svgPath) async {
    return await IndoorRoutingService().getSvgDimensions(svgPath);
  }
}
