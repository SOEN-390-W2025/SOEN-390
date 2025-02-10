import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain-model/poi.dart';

/// Repository responsible for fetching POI facility options from a JSON file.
class POIRepository {
  /// Loads POI data from the configurable POI facility options
  Future<List<POIModel>> fetchPOIData() async {
    try {
      // Load JSON file for facility options from the assets/config directory
      final String response =
          await rootBundle.loadString('assets/config/facility_options.json');
      final List<dynamic> data = await json.decode(response);

      // Convert response to a list of POIModel objects
      return data.map((json) => POIModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Error loading POI data: $e");
    }
  }
}
