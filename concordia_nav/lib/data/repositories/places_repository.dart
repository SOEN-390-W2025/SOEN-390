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
    required PlaceType? type,
    NearbySearchOptions options = const NearbySearchOptions(),
  }) async {
    try {
      return await _service.nearbySearch(
        location: location,
        includedType: type,
        options: options,
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
      final TextSearchOptions options = TextSearchOptions(
        radius: params.radius,
        openNow: params.openNow,
        pageSize: params.pageSize,
        languageCode: params.languageCode,
        regionCode: params.regionCode,
      );
      return await _service.textSearch(
          textQuery: params.query,
          location: params.location,
          includedType: params.type,
          options: options);
    } catch (e) {
      throw Exception('Failed to fetch text search places: $e');
    }
  }
}
