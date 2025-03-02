import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'building_data.dart';
import 'dart:developer' as dev;

class BuildingDataManager {
  static Map<String, BuildingData>? _buildingDataCache;
  static List<String>? _buildingDataPaths;

  /// Returns a map of building data by abbreviation
  static Future<Map<String, BuildingData>> getAllBuildingData() async {
    _buildingDataPaths ??= await _getBuildingDataPaths();

    // Check if cache exists and contains all buildings
    if (_buildingDataCache != null) {
      final Set<String> allBuildingAbbrs = _buildingDataPaths!
          .map((path) => path.split('/').last.split('.').first.toUpperCase())
          .toSet();

      // Check if all buildings are in the cache
      final bool isComplete = allBuildingAbbrs
          .every((abbr) => _buildingDataCache!.containsKey(abbr));

      if (isComplete) {
        return _buildingDataCache!;
      }
      dev.log('Cache incomplete, loading all building data');
    }

    _buildingDataCache = await _loadAllBuildingData();
    return _buildingDataCache!;
  }

  /// Gets building data for a specific abbreviation
  static Future<BuildingData?> getBuildingData(String abbreviation) async {
    final String upperAbbr = abbreviation.toUpperCase();

    // Initialize cache if needed
    _buildingDataCache ??= {};

    if (_buildingDataCache!.containsKey(upperAbbr)) {
      return _buildingDataCache![upperAbbr];
    }

    try {
      // Load only the specific building data
      final loader = BuildingDataLoader(upperAbbr);
      final buildingData = await loader.load();

      _buildingDataCache![upperAbbr] = buildingData;
      return buildingData;
    } on Exception catch (e, stackTrace) {
      dev.log('Error loading building data for $upperAbbr: $e',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get the list of available building files using the AssetManifest API
  static Future<List<String>?> _getBuildingDataPaths() async {
    if (_buildingDataPaths != null) {
      return _buildingDataPaths;
    }

    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final indoorMapPaths = assetManifest
          .listAssets()
          .where((path) =>
              path.startsWith(BuildingData.dataPath) && path.endsWith('.yaml'))
          .toList();

      _buildingDataPaths = indoorMapPaths;
      return indoorMapPaths;
    } on FileSystemException catch (e, stackTrace) {
      dev.log('File system error for ${BuildingData.dataPath}: $e',
          error: e, stackTrace: stackTrace);
      return null;
    } on Exception catch (e, stackTrace) {
      dev.log('Error loading building data form ${BuildingData.dataPath}: $e',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  static Future<dynamic> _loadBuildingData(String abbreviation) async {
    try {
      final loader = BuildingDataLoader(abbreviation);
      final buildingData = await loader.load();
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
  static Future<Map<String, BuildingData>> _loadAllBuildingData() async {
    // Start with existing cache data if available, or create empty map
    final Map<String, BuildingData> result = _buildingDataCache != null
        ? Map<String, BuildingData>.from(_buildingDataCache!)
        : {};

    try {
      final indoorMapPaths = await _getBuildingDataPaths();

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
        
        final buildingData = await _loadBuildingData(abbreviation);
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
    await _getBuildingDataPaths();
  }

  static Future<void> toJson() async {
    await getAllBuildingData();

    try {
      // Create a map to hold serialized building data
      final Map<String, dynamic> serializedData = {};

      // Convert each building data object to a serializable format
      _buildingDataCache!.forEach((abbr, data) {
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
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stackTrace) {
      dev.log('Error exporting building data to JSON',
          error: e, stackTrace: stackTrace);
    }
  }
}
