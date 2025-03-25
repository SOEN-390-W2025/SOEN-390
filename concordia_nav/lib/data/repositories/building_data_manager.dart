// ignore_for_file: avoid_catches_without_on_clauses, prefer_final_locals

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain-model/concordia_floor_point.dart';
import '../domain-model/concordia_room.dart';
import '../domain-model/connection.dart';
import '../domain-model/room_category.dart';
import 'building_data.dart';
import '../domain-model/poi.dart';

import 'dart:developer' as dev;

class BuildingDataManager {
  static Map<String, BuildingData>? buildingDataCache;
  static List<String>? buildingDataPaths;

  // Injected AssetManifest instance
  static AssetManifest? _assetManifest;

  // Constructor to inject the AssetManifest for testing purposes
  static void setAssetManifest(AssetManifest? assetManifest) {
    _assetManifest = assetManifest;
  }

  // Loader as a class variable
  static BuildingDataLoader? _loader;

  // Optionally, set the loader for testing
  static void setLoader(BuildingDataLoader? loader) {
    _loader = loader;
  }

  /// Returns a map of building data by abbreviation
  static Future<Map<String, BuildingData>> getAllBuildingData() async {
    buildingDataPaths ??= await getBuildingDataPaths();

    // Check if cache exists and contains all buildings
    if (buildingDataCache != null) {
      final Set<String> allBuildingAbbrs = buildingDataPaths!
          .map((path) => path.split('/').last.split('.').first.toUpperCase())
          .toSet();

      // Check if all buildings are in the cache
      final bool isComplete = allBuildingAbbrs
          .every((abbr) => buildingDataCache!.containsKey(abbr));

      if (isComplete) {
        return buildingDataCache!;
      }
      dev.log('Cache incomplete, loading all building data');
    }

    buildingDataCache = await loadAllBuildingData();
    return buildingDataCache!;
  }

  /// Gets building data for a specific abbreviation
  static Future<BuildingData?> getBuildingData(String abbreviation) async {
    final String upperAbbr = abbreviation.toUpperCase();

    // Initialize cache if needed
    buildingDataCache ??= {};

    if (buildingDataCache!.containsKey(upperAbbr)) {
      return buildingDataCache![upperAbbr];
    }

    try {
      // Load only the specific building data using the loader class variable
      final dataLoader = _loader ?? BuildingDataLoader(upperAbbr);
      final buildingData = await dataLoader.load();

      buildingDataCache![upperAbbr] = buildingData;
      return buildingData;
    // ignore: unused_catch_stack
    } on FlutterError catch (e, stackTrace) {
      // dev.log('Error loading building data for $upperAbbr: $e',
      //     error: e, stackTrace: stackTrace);
      return null;
    } 
    // ignore: unused_catch_stack
    on Exception catch (e, stackTrace) {
      // dev.log('Error loading building data for $upperAbbr: $e',
      //     error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get the list of available building files using the AssetManifest API
  static Future<List<String>?> getBuildingDataPaths() async {
    if (buildingDataPaths != null) {
      return buildingDataPaths;
    }

    // Use injected AssetManifest instance
    final assetManifest =
        _assetManifest ?? await AssetManifest.loadFromAssetBundle(rootBundle);

    try {
      final indoorMapPaths = assetManifest
          .listAssets()
          .where((path) =>
              path.startsWith(BuildingData.dataPath) && path.endsWith('.yaml'))
          .toList();

      buildingDataPaths = indoorMapPaths;
      return indoorMapPaths;
    } on FileSystemException catch (e, stackTrace) {
      dev.log('File system error for ${BuildingData.dataPath}: $e',
          error: e, stackTrace: stackTrace);
      rethrow; // Rethrow the exception instead of returning null
    } on Exception catch (e, stackTrace) {
      dev.log('Error loading building data form ${BuildingData.dataPath}: $e',
          error: e, stackTrace: stackTrace);
      rethrow; // Re-throws the caught exception
    }
  }

  static Future<dynamic> loadBuildingData(String abbreviation) async {
    try {
      // Use the class-level loader if it's set, or create a new one
      final dataLoader = _loader ?? BuildingDataLoader(abbreviation);
      final buildingData = await dataLoader.load();
      return buildingData;
    } on FormatException catch (e, stackTrace) {
      dev.log('Format error in YAML for $abbreviation: $e',
          error: e, stackTrace: stackTrace);
      return e;
    } on FileSystemException catch (e, stackTrace) {
      dev.log('File system error for $abbreviation: $e',
          error: e, stackTrace: stackTrace);
      return e;
    } on ArgumentError catch (e, stackTrace) {
      dev.log('Invalid argument in building data for $abbreviation: $e',
          error: e, stackTrace: stackTrace);
      return e;
    } on Exception catch (e, stackTrace) {
      dev.log('Error loading building data for $abbreviation: $e',
          error: e, stackTrace: stackTrace);
      return e;
    }
  }

  /// Loads all building data from YAML files in assets/maps/indoor
  /// Skip files that are already loaded in the cache
  static Future<Map<String, BuildingData>> loadAllBuildingData() async {
    // Start with existing cache data if available, or create empty map
    final Map<String, BuildingData> result = buildingDataCache != null
        ? Map<String, BuildingData>.from(buildingDataCache!)
        : {};

    try {
      final indoorMapPaths = await getBuildingDataPaths();

      if (indoorMapPaths == null || indoorMapPaths.isEmpty) {
        dev.log('No indoor YAML files found in ${BuildingData.dataPath}');
        return result;
      } else {
        dev.log('Found indoor YAML files: $indoorMapPaths');
      }

      for (final path in indoorMapPaths) {
        final fileName = path.split('/').last;
        final abbreviation = fileName.split('.').first.toUpperCase();

        // Skip if already in cache
        if (result.containsKey(abbreviation)) {
          dev.log("Skipping $abbreviation, already loaded");
          continue;
        }

        final buildingData = await loadBuildingData(abbreviation);
        if (buildingData is BuildingData) {
          result[abbreviation] = buildingData;
        } else {
          throw Exception(buildingData);
        }
      }
    } on Exception catch (e, stackTrace) {
      dev.log('Error loading building data files: $e',
          error: e, stackTrace: stackTrace);
    }

    return result;
  }

  /// Initialize the manager (call this at app startup)
  static Future<void> initialize() async {
    await getBuildingDataPaths();
  }

  static Future<void> toJson() async {
    await getAllBuildingData();

    try {
      // Create a map to hold serialized building data
      final Map<String, dynamic> serializedData = {};

      // Convert each building data object to a serializable format
      buildingDataCache!.forEach((abbr, data) {
        serializedData[abbr] = {
          'building': {
            'name': data.building.name,
            'abbreviation': data.building.abbreviation,
            'address': data.building.streetAddress,
            'city': data.building.city,
            'province': data.building.province,
            'postalCode': data.building.postalCode,
            'campus': data.building.campus.name,
            'location': {'lat': data.building.lat, 'lng': data.building.lng}
          },
          'floors': data.floors
              .map((floor) => {
                    'number': floor.floorNumber,
                    'pixelsPerSecond': floor.pixelsPerSecond
                  })
              .toList(),
          'roomsByFloor':
              Map.fromEntries(data.roomsByFloor.entries.map((entry) => MapEntry(
                  entry.key,
                  entry.value
                      .map((room) => {
                            'roomNumber': room.roomNumber,
                            'category':
                                room.category.toString().split('.').last,
                            'entrancePoint': room.entrancePoint != null
                                ? {
                                    'x': room.entrancePoint!.positionX,
                                    'y': room.entrancePoint!.positionY,
                                    'floor':
                                        room.entrancePoint!.floor.floorNumber
                                  }
                                : null
                          })
                      .toList()))),
          'waypointsByFloor': Map.fromEntries(data.waypointsByFloor.entries.map(
              (entry) => MapEntry(
                  entry.key,
                  entry.value
                      .map((point) => {
                            'x': point.positionX,
                            'y': point.positionY,
                            'floor': point.floor.floorNumber
                          })
                      .toList()))),
          'waypointNavigability': Map.fromEntries(
              data.waypointNavigability.entries.map((entry) => MapEntry(
                  entry.key,
                  Map.fromEntries(entry.value.entries.map((navEntry) =>
                      MapEntry(navEntry.key.toString(), navEntry.value)))))),
          'connections': data.connections
              .map((conn) => {
                    'name': conn.name,
                    'accessible': conn.isAccessible,
                    'fixedWaitTimeSeconds': conn.fixedWaitTimeSeconds,
                    'waitTimePerFloorSeconds': conn.waitTimePerFloorSeconds,
                    'floors':
                        conn.floors.map((floor) => floor.floorNumber).toList(),
                    'floorPoints': Map.fromEntries(
                        conn.floorPoints.entries.map((entry) => MapEntry(
                            entry.key,
                            entry.value
                                .map((point) => {
                                      'floor': point.floor.floorNumber,
                                      'x': point.positionX,
                                      'y': point.positionY,
                                    })
                                .toList()))),
                  })
              .toList(),
          'outdoorExitPoint': {
            'floor': data.outdoorExitPoint.floor.floorNumber,
            'x': data.outdoorExitPoint.positionX,
            'y': data.outdoorExitPoint.positionY
          }
        };
      });

      // Convert to JSON string (one line)
      final String jsonData =
          const JsonEncoder.withIndent(null).convert(serializedData);

      // Log the JSON data
      dev.log('Building data as JSON:', error: jsonData);
    } catch (e, stackTrace) {
      dev.log('Error exporting building data to JSON',
          error: e, stackTrace: stackTrace);
    }
  }

  // Method to extract all POIs from all building files
  static Future<List<POI>> getAllPOIs() async {
    List<POI> allPOIs = [];

    try {
      // Get all building data paths
      final buildingPaths = await BuildingDataManager.getBuildingDataPaths();
      if (buildingPaths == null || buildingPaths.isEmpty) {
        return allPOIs;
      }

      // Extract building IDs from file paths
      final buildingIds = buildingPaths
          .map((path) => path.split('/').last.split('.').first.toUpperCase())
          .toList();

      // Process each building
      for (final buildingId in buildingIds) {
        final pois = await extractPOIsFromBuilding(buildingId);
        allPOIs.addAll(pois);
      }
    } catch (e, stackTrace) {
      dev.log('Error extracting POIs', error: e, stackTrace: stackTrace);
    }

    return allPOIs;
  }

  static POI? _extractPOIsFromRoom(ConcordiaRoom room, String buildingId) {
    // Skip rooms with categories we want to exclude or without entrance points
    if (room.entrancePoint == null ||
        room.category == RoomCategory.unknown ||
        room.category == RoomCategory.auditorium ||
        room.category == RoomCategory.classroom ||
        room.category == RoomCategory.lab ||
        room.category == RoomCategory.office ||
        room.category == RoomCategory.maintenance) {
      return null;
    }

    // Get POI category
    POICategory poiCategory;
    switch (room.category) {
      case RoomCategory.washroom:
        poiCategory = POICategory.washroom;
        break;
      case RoomCategory.waterFountain:
        poiCategory = POICategory.waterFountain;
        break;
      case RoomCategory.restaurant:
        poiCategory = POICategory.restaurant;
        break;
      case RoomCategory.police:
        poiCategory = POICategory.police;
        break;
      default:
        poiCategory = POICategory.other;
        break;
    }

    // Add the POI with its category as the name
    if (room.category != RoomCategory.unknown) {
      final String name = _formatCategoryName(room.category.toString().split('.').last);
      return POI(
        id: '$buildingId-${room.entrancePoint!.floor.floorNumber}-${room.roomNumber}',
        name: name,
        buildingId: buildingId,
        floor: room.entrancePoint!.floor.floorNumber.toString(),
        category: poiCategory,
        x: room.entrancePoint!.positionX,
        y: room.entrancePoint!.positionY,
      );
    }
    return null;
  }

  static List<POI> _addMultiplePoints(
      List<POI> pois, List<ConcordiaFloorPoint> points, String buildingId, 
      Connection connection, POICategory poiCategory) {
    List<POI> poisPerFloor = pois;
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      poisPerFloor.add(POI(
        id: '$buildingId-${point.floor.floorNumber}-${connection.name.replaceAll(" ", "-")}-$i',
        name: connection.name,
        buildingId: buildingId,
        floor: point.floor.floorNumber.toString(),
        category: poiCategory,
        x: point.positionX,
        y: point.positionY,
      ));
    }
    return poisPerFloor;
  }

  static List<POI> _pointsPerFloor(List<POI> pois, List<ConcordiaFloorPoint> points, String buildingId, 
      Connection connection, POICategory poiCategory) {
    List<POI> poisPerFloor = pois;
    if (points.isNotEmpty) {
      if (points.length == 1) {
        // Single point
        final point = points.first;
        poisPerFloor.add(POI(
          id: '$buildingId-${point.floor.floorNumber}-${connection.name.replaceAll(" ", "-")}',
          name: connection.name,
          buildingId: buildingId,
          floor: point.floor.floorNumber.toString(),
          category: poiCategory,
          x: point.positionX,
          y: point.positionY,
        ));
      } else {
        // Multiple points - add with index suffix
        poisPerFloor = _addMultiplePoints(poisPerFloor, points, buildingId, connection, poiCategory);
      }
    }
    return poisPerFloor;
  }

  static POICategory _getPOICategory(Connection connection){
    if (connection.name.toLowerCase().contains('elevator')) {
      return POICategory.elevator;
    } else if (connection.name.toLowerCase().contains('escalator')) {
      return POICategory.escalator;
    } else if (connection.name.toLowerCase().contains('stair')) {
      return POICategory.stairs;
    } else {
      return POICategory.other;
    }
  }

  // Method to extract POIs from a specific building
  static Future<List<POI>> extractPOIsFromBuilding(String buildingId) async {
    List<POI> pois = [];

    try {
      // Get building data
      final buildingData = await BuildingDataManager.getBuildingData(buildingId);
      if (buildingData == null) return [];

      // Extract POIs from rooms
      buildingData.roomsByFloor.forEach((floor, rooms) {
        for (final room in rooms) {
          final poi = _extractPOIsFromRoom(room, buildingId);
          if (poi != null) {
            pois.add(poi);
          }
        }
      });

      // Extract POIs from connections
      for (final connection in buildingData.connections) {
        POICategory poiCategory = _getPOICategory(connection);

        // For each floor in the connection
        connection.floorPoints.forEach((floorKey, points) {
          // Handle both single point and multiple points per floor
          pois = _pointsPerFloor(pois, points, buildingId, connection, poiCategory);
        });
      }

      // Add outdoor exit point
      final exitPoint = buildingData.outdoorExitPoint;
      pois.add(POI(
        id: '$buildingId-${exitPoint.floor.floorNumber}-exit',
        name: 'Exit',
        buildingId: buildingId,
        floor: exitPoint.floor.floorNumber.toString(),
        category: POICategory.exit,
        x: exitPoint.positionX,
        y: exitPoint.positionY,
      ));

    } catch (e, stackTrace) {
      dev.log('Error extracting POIs from building $buildingId', 
          error: e, stackTrace: stackTrace);
    }

    return pois;
  }

  // Helper method to format category names
  static String _formatCategoryName(String category) {
    // Convert camelCase to Title Case with spaces
    final result = category.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => ' ${m.group(0)}'
    );

    return '${result[0].toUpperCase()}${result.substring(1)}';
  }
}