import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class for loading and processing polygon data from JSON files.
///
/// This class loads polygon data for a specified campus from a JSON file stored
/// in the assets directory and processes it to generate a map of polygons
/// and their corresponding label positions.
class PolygonLoader {
  /// Loads polygon data from the specified campus' JSON file.
  ///
  /// The method reads the JSON file located at `assets/maps/polygons/{campusName}/polygons.json`.
  /// It extracts polygon coordinates and calculates the central label position for each polygon.
  ///
  /// Returns a [Future] containing a map with two keys:
  /// - "polygons": A map where keys are polygon names and values are lists of [LatLng] points.
  /// - "labels": A map where keys are polygon names and values are the central [LatLng] positions for labels.
  ///
  /// If an error occurs, an empty map is returned, and the error is logged in debug mode.
  ///
  /// Example usage:
  /// ```dart
  /// Map<String, dynamic> polygonData = await PolygonLoader.loadPolygons("myCampus");
  /// ```
  static Future<Map<String, dynamic>> loadPolygons(String campusName) async {
    final String path = 'assets/maps/polygons/$campusName/polygons.json';

    try {
      // Load and decode the JSON file
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final Map<String, List<LatLng>> polygons = {};
      final Map<String, LatLng> labelPositions = {};

      // Iterate over each polygon in the JSON file
      jsonData.forEach((key, value) {
        final List<LatLng> points =
            (value as List).map((coord) => LatLng(coord[0], coord[1])).toList();

        polygons[key] = points;
        labelPositions[key] = _calculateBoundsCenter(points);
      });

      return {"polygons": polygons, "labels": labelPositions};
    } on Error catch (e) {
      if (kDebugMode) {
        dev.log('Error loading polygons: $e');
      }
      return {"polygons": {}, "labels": {}};
    }
  }

  /// Calculates the central point of a polygon's bounding box.
  ///
  /// Given a list of [LatLng] points, this method determines the southwest
  /// and northeast corners of the bounding box and computes the midpoint.
  /// This midpoint is used as the label position for the polygon.
  ///
  /// Returns a [LatLng] representing the center of the bounding box.
  static LatLng _calculateBoundsCenter(List<LatLng> points) {
    // Initialize bounds with the first point
    LatLngBounds bounds = LatLngBounds(
      southwest: points.first,
      northeast: points.first,
    );

    // Expand bounds to include all points
    for (LatLng point in points) {
      bounds = LatLngBounds(
        southwest: LatLng(
            bounds.southwest.latitude < point.latitude
                ? bounds.southwest.latitude
                : point.latitude,
            bounds.southwest.longitude < point.longitude
                ? bounds.southwest.longitude
                : point.longitude),
        northeast: LatLng(
            bounds.northeast.latitude > point.latitude
                ? bounds.northeast.latitude
                : point.latitude,
            bounds.northeast.longitude > point.longitude
                ? bounds.northeast.longitude
                : point.longitude),
      );
    }

    // Calculate the center of the bounding box
    return LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
  }
}
