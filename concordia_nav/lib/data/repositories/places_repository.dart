import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart';

class PlacesRepository {
  static final _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final GoogleMapsPlaces _placesClient = GoogleMapsPlaces(apiKey: _apiKey!);

  Future<List<PlacesSearchResult>> searchNearbyPlaces({
    required Location location,
    required String type,
    required int radius,
  }) async {
    final response = await _placesClient.searchNearbyWithRadius(
      Location(lat: location.lat, lng: location.lng),
      radius,
      type: type,
      language: 'en',
    );

    if (response.status == "OK") {
      return response.results;
    }
    throw Exception('Failed to fetch places: ${response.status}');
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final response = await _placesClient.getDetailsByPlaceId(placeId,
        language: 'en',
        fields: [
          'name',
          'formatted_address',
          'geometry',
          'rating',
          'opening_hours',
          'types'
        ]);

    if (response.status == "OK") {
      return response.result;
    }
    throw Exception('Failed to fetch place details: ${response.status}');
  }
}
