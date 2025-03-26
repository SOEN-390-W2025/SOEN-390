// ignore_for_file: prefer_final_locals, avoid_catches_without_on_clauses, prefer_final_fields

import 'package:flutter/material.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concrete_floor_routable_point.dart';
import '../data/domain-model/connection.dart';
import '../data/domain-model/indoor_route.dart';
import '../data/domain-model/poi.dart';
import '../data/repositories/building_data.dart';
import '../data/repositories/building_data_manager.dart';
import '../data/services/indoor_routing_service.dart';
import '../data/services/routecalculation_service.dart';
import 'building_viewmodel.dart';

import 'dart:developer' as dev;

class IndoorDirectionsViewModel extends ChangeNotifier {
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  final String mainEntranceString = "main entrance";

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAccessibilityMode = false;
  String eta = 'N/A';
  String distance = 'N/A';
  IndoorRoute? _calculatedRoute;
  Offset _startLocation = Offset.zero;
  Offset _endLocation = Offset.zero;
  String measurementUnit = 'Metric';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAccessibilityMode => _isAccessibilityMode;
  IndoorRoute? get calculatedRoute => _calculatedRoute;
  Offset get startLocation => _startLocation;
  Offset get endLocation => _endLocation;

  set endLocation(Offset? value) {
    _endLocation = value!;
    notifyListeners(); // Assuming you're using a state management library
  }
  
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
    final String abbreviation = building.abbreviation.toUpperCase();

    // Use BuildingDataManager instead of direct YAML loading
    final BuildingData? buildingData =
        await BuildingDataManager.getBuildingData(abbreviation);

    if (buildingData == null) {
      return null;
    }

    if (room.toLowerCase() == mainEntranceString) {
      return buildingData.outdoorExitPoint;
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

  ConcordiaFloorPoint? getRegularStartPoint(
      BuildingData buildingData, String floor,
      {String? connection}) {
    if (floor == '1' && connection != 'connection') {
      return buildingData.outdoorExitPoint;
    }

    // Try escalators first if no disability
    try {
      Connection escalatorConnection = buildingData.connections
          .firstWhere((conn) => conn.name.toLowerCase().contains("escalators"));

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

  Future<ConcordiaFloorPoint?> getStartPoint(String buildingName, String floor,
      bool disability, String connection) async {
    final ConcordiaBuilding building =
        BuildingViewModel().getBuildingByName(buildingName)!;
    final buildingData = await BuildingDataManager.getBuildingData(
        building.abbreviation.toUpperCase());

    // If floor is "1", return the outdoor exit point
    if (((connection == mainEntranceString) || (connection != "connection")) &&
        floor == '1') {
      return buildingData!.outdoorExitPoint;
    }

    // Try to find a start point based on accessibility needs
    if (disability) {
      return await _getAccessibleStartPoint(buildingData!, floor);
    }

    // For non-disability case, try regular start points
    return getRegularStartPoint(buildingData!, floor, connection: connection);
  }

  Future<ConcordiaFloorPoint?> _getAccessibleStartPoint(
      BuildingData buildingData, String floor) async {
    try {
      Connection elevatorConnection = buildingData.connections.firstWhere(
          (conn) =>
              conn.name.toLowerCase().contains("main elevators") &&
              conn.isAccessible);

      final floorPoints = elevatorConnection.floorPoints[floor];
      if (floorPoints != null && floorPoints.isNotEmpty) {
        return floorPoints.first;
      }
    } catch (e) {
      // No matching elevator found
    }
    return null;
  }

  Future<ConcordiaFloorPoint?> _getStartPoint(String sourceRoomClean,
      String building, String floor, bool disability) async {
    ConcordiaFloorPoint? startPositionPoint;
    if (sourceRoomClean == 'Your Location') {
      startPositionPoint = await getStartPoint(building, floor, disability, '');
    } else if (sourceRoomClean == 'connection') {
      startPositionPoint =
          await getStartPoint(building, floor, disability, 'connection');
    } else {
      startPositionPoint =
          await getPositionPoint(building, floor, sourceRoomClean);
    }
    return startPositionPoint;
  }

  Future<void> calculateRoute(
    String building,
    String floor,
    String sourceRoom,
    String endRoom,
    bool disability, {
    POI? destinationPOI,
  }) async {
    try {
      final sourceRoomClean =
          sourceRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');
      final endRoomClean = endRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');

      final buildingAbbreviation =
          _buildingViewModel.getBuildingAbbreviation(building)!;

      // Get the building data using BuildingDataManager
      final BuildingData? buildingData =
          await BuildingDataManager.getBuildingData(buildingAbbreviation);

      if (buildingData == null) {
        throw Exception('Building data not found for $building');
      }

      ConcordiaFloorPoint? startPositionPoint;
      ConcordiaFloorPoint? endPositionPoint;

      dev.log('Source room: $sourceRoomClean');
      dev.log('End room: $endRoomClean');
      dev.log('Floor: $floor');
      if (destinationPOI != null) {
        dev.log(
            'Using POI destination: ${destinationPOI.name} at (${destinationPOI.x}, ${destinationPOI.y})');
      }

      // Get start location
      startPositionPoint =
          await _getStartPoint(sourceRoomClean, building, floor, disability);

      // Get end location
      if (destinationPOI != null) {
        // Create a ConcordiaFloor object for the POI's floor
        final ConcordiaBuilding buildingObj = _buildingViewModel
            .getBuildingByAbbreviation(destinationPOI.buildingId)!;
        final poiFloor = ConcordiaFloor(destinationPOI.floor, buildingObj);

        // Use POI coordinates directly with the correct floor
        endPositionPoint = ConcordiaFloorPoint(
          poiFloor,
          destinationPOI.x.toDouble(),
          destinationPOI.y.toDouble(),
        );
      } else if (endRoomClean == 'Your Location') {
        endPositionPoint = await getStartPoint(building, floor, disability, '');
      } else if (endRoomClean == 'connection') {
        endPositionPoint =
            await getStartPoint(building, floor, disability, 'connection');
      } else if (endRoomClean.toLowerCase() == 'ma') {
        endPositionPoint = await getStartPoint(
            building, floor, disability, mainEntranceString);
      } else {
        endPositionPoint =
            await getPositionPoint(building, floor, endRoomClean);
      }

      if (startPositionPoint != null && endPositionPoint != null) {
        _startLocation =
            Offset(startPositionPoint.positionX, startPositionPoint.positionY);
        _endLocation =
            Offset(endPositionPoint.positionX, endPositionPoint.positionY);

        final ConcordiaBuilding buildingObj =
            _buildingViewModel.getBuildingByName(building)!;
        final currentFloor = ConcordiaFloor(floor, buildingObj);

        // Create FloorRoutablePoint for start and end
        final startRoutablePoint = ConcreteFloorRoutablePoint(
          floor: startPositionPoint.floor,
          positionX: startPositionPoint.positionX,
          positionY: startPositionPoint.positionY,
        );

        final endRoutablePoint = ConcreteFloorRoutablePoint(
          floor: endPositionPoint.floor,
          positionX: endPositionPoint.positionX,
          positionY: endPositionPoint.positionY,
        );

        // Calculate route based on accessibility mode
        _calculatedRoute = IndoorRoutingService.getIndoorRoute(
          buildingData,
          startRoutablePoint,
          endRoutablePoint,
          _isAccessibilityMode,
        );

        // Calculate ETA and distance using the shared service
        if (_calculatedRoute != null) {
          double totalDistance =
              RouteCalculationService.calculateTotalDistanceFromRoute(
                  _calculatedRoute!);

          // Convert pixels to meters
          double conversionFactor =
              _getPixelToMeterConversionFactor(currentFloor);
          double distanceInMeters = totalDistance * conversionFactor;

          // Get travel time
          double travelTimeSeconds =
              _calculatedRoute!.getIndoorTravelTimeSeconds();

          // Format outputs using the shared service
          eta = RouteCalculationService.formatDetailedTime(travelTimeSeconds);
          distance = RouteCalculationService.formatDistance(distanceInMeters,
              measurementUnit: measurementUnit);
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

  double _getPixelToMeterConversionFactor(ConcordiaFloor floor) {
    if (floor.pixelsPerSecond > 0) {
      // Calculate meters per pixel based on pixels per second
      // Assuming an average walking speed of 1.4 meters per second
      const double metersPerSecond = 1.4;
      return metersPerSecond / floor.pixelsPerSecond;
    }

    // Default conversion factor if no data is available
    return 0.05;
  }

  // A single method to check if directions are available for a location
  Future<bool> areDirectionsAvailableForLocation(String? location) async {
    if (location == null) return false;

    // Extract floor plan name from location
    final String floorPlanName = _getFloorPlanName(location);
    final String floorPlanPath =
        'assets/maps/indoor/floorplans/$floorPlanName.svg';

    // Check if floor plan exists
    return await checkFloorPlanExists(floorPlanPath);
  }

  // Helper to extract floor plan name - moved from calendar view
  String _getFloorPlanName(String location) {
    // Split the string by spaces
    final List<String> parts = location.split(" ");
    if (parts.length < 2) {
      return location; // Return original if no space found
    }

    final String building = parts[0];
    final String roomNumber = parts[1];

    // Check if roomNumber starts with a letter
    if (roomNumber.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(roomNumber[0])) {
      // If roomNumber starts with a letter, return building + first two characters
      if (roomNumber.length > 1) {
        return building + roomNumber[0] + roomNumber[1];
      } else {
        return building + roomNumber[0];
      }
    } else {
      // For regular cases, return building + first character of roomNumber
      if (roomNumber.isNotEmpty) {
        return building + roomNumber[0];
      }
    }

    return building; // Fallback if roomNumber is empty
  }

  Future<bool> checkFloorPlanExists(String floorPlanPath) async {
    return await IndoorRoutingService().checkFloorPlanExists(floorPlanPath);
  }

  Future<Size> getSvgDimensions(String svgPath) async {
    return await IndoorRoutingService().getSvgDimensions(svgPath);
  }

  void forceEndLocation(Offset location) {
    _endLocation = location;
    notifyListeners();
  }
}
