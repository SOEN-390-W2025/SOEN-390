import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';
import '../domain-model/place.dart';

class PlacesRepository {
  final PlacesService _service;

  PlacesRepository(this._service);

  /// Fetches nearby places using the Places API.
  Future<List<Place>> getNearbyPlaces({
    required LatLng location,
    required double radius,
    required PlaceType? type,
    int maxResultCount = 10,
    String? languageCode,
    String? regionCode,
    List<String>? fields,
  }) async {
    try {
      return await _service.nearbySearch(
        location: location,
        radius: radius,
        includedType: type,
        maxResultCount: maxResultCount,
        languageCode: languageCode,
        regionCode: regionCode,
      );
    } catch (e) {
      throw Exception('Failed to fetch nearby places: $e');
    }
  }

  /// Wraps PlacesService.textSearch to retrieve a List of [Place] objects via
  /// the Places API.
  Future<List<Place>> textSearchPlaces({
    required String query,
    required LatLng location,
    double radius = 1500,
    PlaceType? type,
    bool openNow = false,
    int pageSize = 10,
    String? languageCode,
    String? regionCode,
  }) async {
    try {
      return await _service.textSearch(
        textQuery: query,
        location: location,
        includedType: type,
        radius: radius,
        openNow: openNow,
        pageSize: pageSize,
        languageCode: languageCode,
        regionCode: regionCode,
      );
    } catch (e) {
      throw Exception('Failed to fetch text search places: $e');
    }
  }
}
