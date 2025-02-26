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

/// Loader class to parse a building's YAML file and create objects.
class BuildingDataLoader {
  final String buildingAbbreviation;

  BuildingDataLoader(this.buildingAbbreviation);

  Future<BuildingData> load() async {
    final String yamlString = await rootBundle
        .loadString('assets/maps/indoor/$buildingAbbreviation.yaml');
    final dynamic yamlData = loadYaml(yamlString);

    final building =
        BuildingRepository.buildingByAbbreviation[buildingAbbreviation]!;

    // -------------------
    // 1. Load Floors
    // -------------------
    final floors = _loadFloors(yamlData, building);

    final floorMap = _createFloorMap(floors);

    // -------------------
    // 2. Load Rooms
    // -------------------
    final roomsByFloor = _loadRooms(yamlData, floorMap);

    // -------------------
    // 3. Load Waypoints
    // -------------------
    final waypointsByFloor = _loadWaypoints(yamlData, floorMap);

    // ------------------------------
    // 4. Load Waypoint Navigability
    // ------------------------------
    final waypointNavigability = _loadWaypointNavigability(yamlData);

    // -------------------
    // 5. Load Connections
    // -------------------
    final connections = _loadConnections(yamlData, floorMap);

    // ------------------------------
    // 6. Load Outdoor Exit Point
    // ------------------------------
    final outdoorExitPoint = _loadOutdoorExitPoint(yamlData, floorMap);

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

  List<ConcordiaFloor> _loadFloors(
      dynamic yamlData, ConcordiaBuilding building) {
    final List<ConcordiaFloor> floors = [];
    for (var floorYaml in yamlData['floors']) {
      floors.add(ConcordiaFloor(
        floorYaml['number'],
        building,
        (floorYaml['pixelsPerSecond'] as num).toDouble(),
      ));
    }
    return floors;
  }

  Map<String, ConcordiaFloor> _createFloorMap(List<ConcordiaFloor> floors) {
    return {for (var f in floors) f.floorNumber: f};
  }

  Map<String, List<ConcordiaRoom>> _loadRooms(
      dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
    final Map<String, List<ConcordiaRoom>> roomsByFloor = {};
    if (yamlData['rooms'] != null) {
      final roomsYaml = yamlData['rooms'] as Map;
      roomsYaml.forEach((floorStr, roomList) {
        roomsByFloor[floorStr] = [];
        for (var roomYaml in roomList) {
          roomsByFloor[floorStr]!.add(_createRoom(roomYaml, floorMap));
        }
      });
    }
    return roomsByFloor;
  }

  ConcordiaRoom _createRoom(
      Map roomYaml, Map<String, ConcordiaFloor> floorMap) {
    final entrancePointYaml = roomYaml['entrancePoint'];
    final entrancePoint = entrancePointYaml != null
        ? ConcordiaFloorPoint(
            floorMap[roomYaml['floor']]!,
            (entrancePointYaml['x'] as num).toDouble(),
            (entrancePointYaml['y'] as num).toDouble(),
          )
        : null;
    final categoryStr = roomYaml['category'] as String;
    final roomCategory = RoomCategory.values.firstWhere(
      (e) => e.toString().split('.').last == categoryStr,
      orElse: () => RoomCategory.office, // fallback if necessary
    );
    return ConcordiaRoom(
      roomYaml['roomNumber'],
      roomCategory,
      floorMap[roomYaml['floor']]!,
      entrancePoint,
    );
  }

  Map<String, List<ConcordiaFloorPoint>> _loadWaypoints(
      dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
    final Map<String, List<ConcordiaFloorPoint>> waypointsByFloor = {};
    if (yamlData['waypoints'] != null) {
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
    }
    return waypointsByFloor;
  }

  Map<String, Map<int, List<int>>> _loadWaypointNavigability(dynamic yamlData) {
    final Map<String, Map<int, List<int>>> waypointNavigability = {};
    if (yamlData['waypointNavigability'] != null) {
      final navYaml = yamlData['waypointNavigability'] as Map;
      navYaml.forEach((floorStr, mapping) {
        final Map<int, List<int>> floorMapping = {};
        (mapping as Map).forEach((key, value) {
          final int index = int.parse(key.toString());
          floorMapping[index] = List<int>.from(value);
        });
        waypointNavigability[floorStr] = floorMapping;
      });
    }
    return waypointNavigability;
  }

  List<Connection> _loadConnections(
      dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
    final List<Connection> connections = [];
    if (yamlData['connections'] != null) {
      for (var connYaml in yamlData['connections']) {
        final connFloors = _loadConnectionFloors(connYaml, floorMap);
        final floorPoints = _loadConnectionFloorPoints(connYaml, floorMap);
        connections.add(Connection(
          connFloors,
          floorPoints,
          connYaml['accessible'],
          connYaml['name'],
          (connYaml['fixedWaitTimeSeconds'] as num).toDouble(),
          (connYaml['waitTimePerFloorSeconds'] as num).toDouble(),
        ));
      }
    }
    return connections;
  }

  List<ConcordiaFloor> _loadConnectionFloors(
      Map connYaml, Map<String, ConcordiaFloor> floorMap) {
    final connFloors = <ConcordiaFloor>[];
    for (var floorStr in connYaml['floors']) {
      if (floorMap.containsKey(floorStr)) {
        connFloors.add(floorMap[floorStr]!);
      }
    }
    return connFloors;
  }

  Map<String, ConcordiaFloorPoint> _loadConnectionFloorPoints(
      Map connYaml, Map<String, ConcordiaFloor> floorMap) {
    final Map<String, ConcordiaFloorPoint> floorPoints = {};
    (connYaml['floorPoints'] as Map).forEach((floorKey, pointYaml) {
      floorPoints[floorKey] = ConcordiaFloorPoint(
        floorMap[pointYaml['floor']]!,
        (pointYaml['x'] as num).toDouble(),
        (pointYaml['y'] as num).toDouble(),
      );
    });
    return floorPoints;
  }

  ConcordiaFloorPoint _loadOutdoorExitPoint(
      dynamic yamlData, Map<String, ConcordiaFloor> floorMap) {
    final exitYaml = yamlData['outdoorExitPoint'];
    return ConcordiaFloorPoint(
      floorMap[exitYaml['floor']]!,
      (exitYaml['x'] as num).toDouble(),
      (exitYaml['y'] as num).toDouble(),
    );
  }
}
