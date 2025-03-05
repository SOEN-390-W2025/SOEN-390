import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/domain-model/concordia_floor.dart';
import '../data/domain-model/concordia_floor_point.dart';
import '../data/domain-model/concordia_room.dart';
import '../data/domain-model/concordia_building.dart';
import '../data/repositories/building_data.dart';
import 'map_viewmodel.dart';
import 'building_viewmodel.dart';

class IndoorDirectionsViewModel extends MapViewModel {
  final ValueNotifier<Set<Marker>> markersNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> polylinesNotifier = ValueNotifier({});

  ConcordiaRoom? selectedRoom;

  Future<CameraPosition> getInitialCameraPositionFloor(ConcordiaFloor floor) async {
    return CameraPosition(
      target: LatLng(floor.lat, floor.lng),
      zoom: 18.0,
    );
  }

  @override
  Future<void> fetchRoutesForAllModes(String originAddress, String destinationAddress) async {
    
  }

  void calculateDirections() {
    // directions logic

  }

  void updateMarkers() {
    // marker logic
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

    print(roomNumber);  // For debugging, you can print the room number

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
}