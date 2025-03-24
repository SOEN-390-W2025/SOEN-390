import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';
import '../domain-model/place.dart';

class TextSearchParams {
  final String query;
  final LatLng location;
  final double radius;
  final PlaceType? type;
  final bool openNow;
  final int pageSize;
  final String? languageCode;
  final String? regionCode;

  TextSearchParams({
    required this.query,
    required this.location,
    this.radius = 1500,
    this.type,
    this.openNow = false,
    this.pageSize = 10,
    this.languageCode,
    this.regionCode,
  });
}

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
    required TextSearchParams params,
  }) async {
    try {
      return await _service.textSearch(
        textQuery: params.query,
        location: params.location,
        includedType: params.type,
        radius: params.radius,
        openNow: params.openNow,
        pageSize: params.pageSize,
        languageCode: params.languageCode,
        regionCode: params.regionCode,
      );
    } catch (e) {
      throw Exception('Failed to fetch text search places: $e');
    }
  }
}
