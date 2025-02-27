import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'building_data.dart';
import 'dart:developer' as dev;

class BuildingDataManager {
  static Map<String, BuildingData>? _buildingDataCache;

  /// Returns a map of building data by abbreviation
  static Future<Map<String, BuildingData>> getAllBuildingData() async {
    if (_buildingDataCache != null) {
      return _buildingDataCache!;
    }

    _buildingDataCache = await _loadAllBuildingData();
    return _buildingDataCache!;
  }

  /// Gets building data for a specific abbreviation
  static Future<BuildingData?> getBuildingData(String abbreviation) async {
    final allData = await getAllBuildingData();
    return allData[abbreviation.toUpperCase()];
  }

  /// Loads all building data from YAML files in assets/maps/indoor
  static Future<Map<String, BuildingData>> _loadAllBuildingData() async {
    final Map<String, BuildingData> result = {};

    try {
      // Get the list of available building files using the AssetManifest API
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final indoorMapPaths = assetManifest
          .listAssets()
          .where((path) =>
              path.startsWith(BuildingData.dataPath) && path.endsWith('.yaml'))
          .toList();

      dev.log('Found indoor YAML files: $indoorMapPaths');

      for (final path in indoorMapPaths) {
        final fileName = path.split('/').last;
        final abbreviation = fileName.split('.').first.toUpperCase();

        try {
          final loader = BuildingDataLoader(abbreviation);
          final buildingData = await loader.load();
          result[abbreviation] = buildingData;
        } on FormatException catch (e, stackTrace) {
          dev.log('Format error in YAML for $abbreviation: $e',
              error: e, stackTrace: stackTrace);
        } on FileSystemException catch (e, stackTrace) {
          dev.log('File system error for $abbreviation: $e',
              error: e, stackTrace: stackTrace);
        } on ArgumentError catch (e, stackTrace) {
          dev.log('Invalid argument in building data for $abbreviation: $e',
              error: e, stackTrace: stackTrace);
        } on Exception catch (e, stackTrace) {
          dev.log('Error loading building data for $abbreviation: $e',
              error: e, stackTrace: stackTrace);
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
    await getAllBuildingData();
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
