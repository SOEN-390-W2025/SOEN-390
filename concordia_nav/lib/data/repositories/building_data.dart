import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../domain-model/concordia_building.dart';
import '../domain-model/concordia_floor.dart';
import '../domain-model/concordia_floor_point.dart';
import '../domain-model/concordia_room.dart';
import '../domain-model/connection.dart';
import '../domain-model/room_category.dart';
import 'building_repository.dart';

/// Data holder for a building's indoor features.
class BuildingData {
  final ConcordiaBuilding building;
  final List<ConcordiaFloor> floors;
  final Map<String, List<ConcordiaRoom>> roomsByFloor;
  final Map<String, List<ConcordiaFloorPoint>> waypointsByFloor;
  final Map<String, Map<int, List<int>>> waypointNavigability;
  final List<Connection> connections;
  final ConcordiaFloorPoint outdoorExitPoint;

  static const String dataPath = 'assets/maps/indoor/data/';

  BuildingData({
    required this.building,
    required this.floors,
    required this.roomsByFloor,
    required this.waypointsByFloor,
    required this.waypointNavigability,
    required this.connections,
    required this.outdoorExitPoint,
  });
}

List<dynamic> _loadFloors(dynamic yamlData, ConcordiaBuilding building) {
  final List<ConcordiaFloor> floors = [];
  for (var floorYaml in yamlData['floors']) {
    floors.add(ConcordiaFloor(
      floorYaml['number'],
      building,
      (floorYaml['pixelsPerSecond'] as num).toDouble(),
    ));
  }

  final Map<String, ConcordiaFloor> floorMap = {
    for (var f in floors) f.floorNumber: f
  };
  return [floors, floorMap];
}

Map<String, List<ConcordiaRoom>> _loadRooms(
    dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
  final Map<String, List<ConcordiaRoom>> roomsByFloor = {};
  final roomsYaml = yamlData['rooms'] as Map;
  roomsYaml.forEach((floorStr, roomList) {
    roomsByFloor[floorStr] = [];
    for (var roomYaml in roomList) {
      final entrancePointYaml = roomYaml['entrancePoint'];
      final entrancePoint = (entrancePointYaml != null)
          ? ConcordiaFloorPoint(
              floorMap[roomYaml['floor']]!,
              (entrancePointYaml['x'] as num).toDouble(),
              (entrancePointYaml['y'] as num).toDouble())
          : null;
      final categoryStr = roomYaml['category'] as String;
      final roomCategory = RoomCategory.values.firstWhere(
        (e) => e.toString().split('.').last == categoryStr,
        orElse: () => RoomCategory.office, // fallback if necessary
      );
      roomsByFloor[floorStr]!.add(ConcordiaRoom(
        roomYaml['roomNumber'],
        roomCategory,
        floorMap[roomYaml['floor']]!,
        entrancePoint,
      ));
    }
  });
  return roomsByFloor;
}

Map<String, List<ConcordiaFloorPoint>> _loadWaypoints(
      dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
  final Map<String, List<ConcordiaFloorPoint>> waypointsByFloor = {};
  final wpYaml = yamlData['waypoints'] as Map;
  wpYaml.forEach((floorStr, points) {
    waypointsByFloor[floorStr] = [];
    for (var pointYaml in points) {
      waypointsByFloor[floorStr]!.add(ConcordiaFloorPoint(
        floorMap[floorStr]!,
        (pointYaml['x'] as num).toDouble(),
        (pointYaml['y'] as num).toDouble(),
      ));
    }
  });
  return waypointsByFloor;
}

Map<String, Map<int, List<int>>> _loadWaypointNavigability(dynamic yamlData) {
  final Map<String, Map<int, List<int>>> waypointNavigability = {};
  final navYaml = yamlData['waypointNavigability'] as Map;
  navYaml.forEach((floorStr, mapping) {
    final Map<int, List<int>> floorMapping = {};
    (mapping as Map).forEach((key, value) {
      final int index = int.parse(key.toString());
      floorMapping[index] = List<int>.from(value);
    });
    waypointNavigability[floorStr] = floorMapping;
  });
  return waypointNavigability;
}

List<Connection> _loadConnections(
      dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
  final List<Connection> connections = [];
  for (var connYaml in yamlData['connections']) {
    // Convert floor numbers to actual floor objects.
    final List<ConcordiaFloor> connFloors = [];
    for (var floorStr in connYaml['floors']) {
      if (floorMap.containsKey(floorStr)) {
        connFloors.add(floorMap[floorStr]!);
      }
    }
    // Convert the floorPoints mapping.
    final Map<String, List<ConcordiaFloorPoint>> floorPoints = {};
    (connYaml['floorPoints'] as Map).forEach((floorKey, pointData) {
      if (pointData is List) {
        // Handle list of points for this floor
        floorPoints[floorKey] = pointData
            .map((pointYaml) => ConcordiaFloorPoint(
                  floorMap[pointYaml['floor']]!,
                  (pointYaml['x'] as num).toDouble(),
                  (pointYaml['y'] as num).toDouble(),
                ))
            .toList();
      } else {
        // Handle single point for this floor
        floorPoints[floorKey] = [
          ConcordiaFloorPoint(
            floorMap[pointData['floor']]!,
            (pointData['x'] as num).toDouble(),
            (pointData['y'] as num).toDouble(),
          )
        ];
      }
    });
    connections.add(Connection(
      connFloors,
      floorPoints,
      connYaml['accessible'],
      connYaml['name'],
      (connYaml['fixedWaitTimeSeconds'] as num).toDouble(),
      (connYaml['waitTimePerFloorSeconds'] as num).toDouble(),
    ));
  }
  return connections;
}

/// Loader class to parse a building's YAML file and create objects.
class BuildingDataLoader {
  final String buildingAbbreviation;

  BuildingDataLoader(this.buildingAbbreviation);

  Future<BuildingData?> load() async {
    final String yamlString;
    try {
      yamlString = await rootBundle
        .loadString('${BuildingData.dataPath}$buildingAbbreviation.yaml');
    } on FlutterError {
      return null;
    } on Exception {
      return null;
    }
    
    final dynamic yamlData = loadYaml(yamlString);

    final building =
        BuildingRepository.buildingByAbbreviation[buildingAbbreviation]!;

    // -------------------
    // 1. Load Floors
    // -------------------
    final loadedFloors = _loadFloors(yamlData, building);
    final List<ConcordiaFloor> floors = loadedFloors[0];

    final Map<String, ConcordiaFloor> floorMap = loadedFloors[1];

    // -------------------
    // 2. Load Rooms
    // -------------------
    Map<String, List<ConcordiaRoom>> roomsByFloor = {};
    if (yamlData['rooms'] != null) {
      roomsByFloor = _loadRooms(yamlData, floorMap);
    }

    // -------------------
    // 3. Load Waypoints
    // -------------------
    Map<String, List<ConcordiaFloorPoint>> waypointsByFloor = {};
    if (yamlData['waypoints'] != null) {
      waypointsByFloor = _loadWaypoints(yamlData, floorMap);
    }

    // ------------------------------
    // 4. Load Waypoint Navigability
    // ------------------------------
    Map<String, Map<int, List<int>>> waypointNavigability = {};
    if (yamlData['waypointNavigability'] != null) {
      waypointNavigability = _loadWaypointNavigability(yamlData);
    }

    // -------------------
    // 5. Load Connections
    // -------------------
    List<Connection> connections = [];
    if (yamlData['connections'] != null) {
      connections = _loadConnections(yamlData, floorMap);
    }

    // ------------------------------
    // 6. Load Outdoor Exit Point
    // ------------------------------
    final exitYaml = yamlData['outdoorExitPoint'];
    final outdoorExitPoint = ConcordiaFloorPoint(
      floorMap[exitYaml['floor']]!,
      (exitYaml['x'] as num).toDouble(),
      (exitYaml['y'] as num).toDouble(),
    );

    return BuildingData(
      building: building,
      floors: floors,
      roomsByFloor: roomsByFloor,
      waypointsByFloor: waypointsByFloor,
      waypointNavigability: waypointNavigability,
      connections: connections,
      outdoorExitPoint: outdoorExitPoint,
    );
  }
}
