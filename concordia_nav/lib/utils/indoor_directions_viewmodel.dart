// ignore_for_file: prefer_final_locals, avoid_catches_without_on_clauses, prefer_final_fields

import 'package:flutter/material.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concrete_floor_routable_point.dart';
import '../data/domain-model/connection.dart';
import '../data/domain-model/floor_routable_point.dart';
import '../data/domain-model/indoor_route.dart';
import '../data/repositories/building_data.dart';
import '../data/repositories/building_data_manager.dart';
import '../data/services/indoor_routing_service.dart';
import '../data/services/routecalculation_service.dart';
import 'building_viewmodel.dart';

import 'dart:developer' as dev;

class IndoorDirectionsViewModel extends ChangeNotifier {
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  
  bool _isAccessibilityMode = false;
  String eta = 'Calculating...';
  String distance = 'Calculating...';
  IndoorRoute? _calculatedRoute;
  Offset _startLocation = Offset.zero;
  Offset _endLocation = Offset.zero;
  
  
  // Getters
  bool get isAccessibilityMode => _isAccessibilityMode;
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
    final ConcordiaBuilding building = BuildingViewModel().getBuildingByName(buildingName)!;
    final String abbreviation = building.abbreviation.toUpperCase();

    // Use BuildingDataManager instead of direct YAML loading
    final BuildingData? buildingData = await BuildingDataManager.getBuildingData(abbreviation);

    if (buildingData == null) {
      return null;
    }

    // Get the list of rooms for the given floor
    final rooms = buildingData.roomsByFloor[floor];

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
      try {
        final roomFound = rooms.firstWhere(
          (room) => room.roomNumber == roomNumber,
        );

        // Return the entrancePoint if the room is found
        return roomFound.entrancePoint;
      } catch (e) {
        // Room not found
        return null;
      }
    }

    // Return null if the floor or room wasn't found
    return null;
  }

  Future<ConcordiaFloorPoint?> getStartPoint(
    String buildingName, String floor, bool disability) async {

    // Get the building by name
    final ConcordiaBuilding building = BuildingViewModel().getBuildingByName(buildingName)!;

    // Load building data
    final buildingData = await BuildingDataManager.getBuildingData(building.abbreviation.toUpperCase());
    
    // If floor is "1", simply return the outdoor exit point
    if (floor == '1') {
      return buildingData!.outdoorExitPoint;
    }
    
    // Find appropriate connection based on accessibility needs
    if (disability) {
      // If person has disability, look for accessible elevators
      Connection? elevatorConnection;
      try {
        elevatorConnection = buildingData!.connections.firstWhere(
          (conn) => conn.name.toLowerCase().contains("main elevators") && conn.isAccessible
        );
        
        final floorPoints = elevatorConnection.floorPoints[floor];
        if (floorPoints != null && floorPoints.isNotEmpty) {
          return floorPoints.first;
        }
      } catch (e) {
        // No matching elevator found
      }
    } else {
      // Try escalators first if no disability
      try {
        Connection escalatorConnection = buildingData!.connections.firstWhere(
          (conn) => conn.name.toLowerCase().contains("escalators")
        );
        
        final floorPoints = escalatorConnection.floorPoints[floor];
        if (floorPoints != null && floorPoints.isNotEmpty) {
          return floorPoints.first;
        }
      } catch (e) {
        // No matching escalator found
      }
      
      // Try stairs as fallback if no escalators for this floor
      try {
        Connection stairsConnection = buildingData!.connections.firstWhere(
          (conn) => conn.name.toLowerCase().contains("stairs")
        );
        
        final floorPoints = stairsConnection.floorPoints[floor];
        if (floorPoints != null && floorPoints.isNotEmpty) {
          // Use a specific stair point (third in the list, if available)
          return floorPoints.length > 3 ? floorPoints[3] : floorPoints.first;
        }
      } catch (e) {
        // No matching stairs found
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


  Future<void> calculateRoute(String building, String floor, String sourceRoom, String endRoom, bool disability) async {
    try {
      final sourceRoomClean = sourceRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');
      final endRoomClean = endRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');

      final buildingAbbreviation = _buildingViewModel.getBuildingAbbreviation(building)!;

      // Get the building data using BuildingDataManager
      final BuildingData? buildingData = await BuildingDataManager.getBuildingData(buildingAbbreviation);

      if (buildingData == null) {
        throw Exception('Building data not found for $building');
      }

      ConcordiaFloorPoint? startPositionPoint;

      // Get start location (elevator point)
      if (sourceRoomClean == 'Your Location') {
        dev.log(disability.toString());
        startPositionPoint = await getStartPoint(building, floor, disability);
      } else {
        startPositionPoint = await getPositionPoint(building, floor, sourceRoomClean);
      }

      // Get end location (room point)
      final endPositionPoint = await getPositionPoint(building, floor, endRoomClean);

      if (startPositionPoint != null && endPositionPoint != null) {
        _startLocation = Offset(startPositionPoint.positionX, startPositionPoint.positionY);
        _endLocation = Offset(endPositionPoint.positionX, endPositionPoint.positionY);

        final ConcordiaBuilding buildingObj = _buildingViewModel.getBuildingByName(building)!;
        final currentFloor = ConcordiaFloor(floor, buildingObj);

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
        _calculatedRoute = IndoorRoutingService.getIndoorRoute(
          buildingData,
          startRoutablePoint,
          endRoutablePoint,
          _isAccessibilityMode
        );

        // Calculate ETA and distance using the shared service
        if (_calculatedRoute != null) {
          double totalDistance = RouteCalculationService.calculateTotalDistanceFromRoute(_calculatedRoute!);

          // Convert pixels to meters 
          double conversionFactor = _getPixelToMeterConversionFactor(building, floor);
          double distanceInMeters = totalDistance * conversionFactor;

          // Get travel time
          double travelTimeSeconds = _calculatedRoute!.getIndoorTravelTimeSeconds();

          // Format outputs using the shared service
          eta = RouteCalculationService.formatDetailedTime(travelTimeSeconds);
          distance = RouteCalculationService.formatDistance(distanceInMeters);
        } else {
          eta = "Unknown";
          distance = "Unknown";
        }

        notifyListeners();
      }
    } catch (e) {
      eta = "Unknown";
      distance = "Unknown";
      rethrow;
    }
  }

  double _getPixelToMeterConversionFactor(String building, String floor) {
    return 0.01;
  }

  Future<Size> getSvgDimensions(String svgPath) async {
    return await IndoorRoutingService().getSvgDimensions(svgPath);
  }
}