import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain-model/poi.dart';

/// Repository responsible for fetching POI facility options from a JSON file.
class POIRepository {
  final Future<String>? Function(String path) loadString;

  // Default constructor that uses rootBundle
  POIRepository({Future<String>? Function(String path)? loadString})
      : loadString = loadString ?? rootBundle.loadString;

  /// Loads POI data from a configurable POI facility options
  Future<List<POIModel>> fetchPOIData() async {
    try {
      final String? response =
          await (loadString)('assets/config/facility_options.json');
      final List<dynamic> data = json.decode(response!);
      return data.map((json) => POIModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Error loading POI data: $e");
    }
  }
}
