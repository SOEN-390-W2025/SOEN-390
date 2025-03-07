import 'package:flutter/material.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_room.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/domain-model/concrete_floor_routable_point.dart';
import '../data/domain-model/connection.dart';
import '../data/domain-model/indoor_route.dart';
import '../data/repositories/building_data.dart';
import '../data/services/indoor_routing_service.dart';
import 'building_viewmodel.dart';

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
    final ConcordiaBuilding building = BuildingViewModel().getBuildingByName(buildingName)!;

    // Load YAML data for the building
    final dynamic yamlData = await BuildingViewModel().getYamlDataForBuilding(building.abbreviation.toUpperCase());
    
    // Load floors and rooms from the YAML data
    final loadedFloors = loadFloors(yamlData, building);
    final Map<String, ConcordiaFloor> floorMap = loadedFloors[1];
    final Map<String, List<ConcordiaRoom>> roomsByFloor = loadRooms(yamlData, floorMap);

    // Get the list of rooms for the given floor
    final rooms = roomsByFloor[floor];

    // Remove the floor part of the room identifier
    String roomNumber = room.replaceFirst(floor, '');

    // Remove the leading '0' if it exists
    if (roomNumber.startsWith('0')) {
      roomNumber = roomNumber.substring(1);
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

  Future<ConcordiaFloorPoint?> getElevatorPoint(
    String buildingName, String floor) async {

    // Get the building by name
    final ConcordiaBuilding building = BuildingViewModel().getBuildingByName(buildingName)!;

    // Load YAML data for the building
    final dynamic yamlData = await BuildingViewModel().getYamlDataForBuilding(building.abbreviation.toUpperCase());

    // Load floors and rooms from the YAML data
    final loadedFloors = loadFloors(yamlData, building);
    final Map<String, ConcordiaFloor> floorMap = loadedFloors[1];
    final List<Connection> connections = loadConnections(yamlData, floorMap);

    // Search through connections to find the elevator for the given floor
    for (var connection in connections) {

      if (connection.name.toLowerCase().contains("main elevators")) {  // Check if the connection is an elevator
        final floorPoints = connection.floorPoints[floor];
        if (floorPoints != null && floorPoints.isNotEmpty) {
          // Return the first point for the given floor
          return floorPoints.first;
        }
      }
    }

    // Return null if no elevator is found for the floor
    return null;
  }

  Future<void> calculateRoute(String building, String floor, String sourceRoom, String endRoom) async {
    try {
      final buildingAbbreviation = _buildingViewModel.getBuildingAbbreviation(building)!;
      final dynamic yamlData = await _buildingViewModel.getYamlDataForBuilding(buildingAbbreviation);

      // Get start location (elevator point)
      final startPositionPoint = await getElevatorPoint(building, floor);

      // Get end location (room point)
      final endPositionPoint = await getPositionPoint(building, floor, endRoom);

      if (startPositionPoint != null && endPositionPoint != null) {
        // Update location points
        _startLocation = Offset(startPositionPoint.positionX, startPositionPoint.positionY);
        _endLocation = Offset(endPositionPoint.positionX, endPositionPoint.positionY);

        final ConcordiaBuilding buildingData = _buildingViewModel.getBuildingByName(building)!;

        // Create ConcordiaFloor for the current floor
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
        _calculatedRoute = IndoorRoutingService.getIndoorRoute(
          yamlData,
          startRoutablePoint,
          endRoutablePoint,
          _isAccessibilityMode
        );

        notifyListeners();
      }
    } catch (e) {
      rethrow; // Let the view handle the error
    }
  }

  Future<Size> getSvgDimensions(String svgPath) async {
    return await IndoorRoutingService().getSvgDimensions(svgPath);
  }
}