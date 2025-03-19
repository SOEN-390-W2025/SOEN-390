// TODO: Currently not used. If needed, update the imports and the class to use the PlacesService. If not needed, delete this file.

// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../services/places_service.dart';
// import '../domain-model/place.dart';

// class PlacesRepository {
//   final PlacesService _service;

//   PlacesRepository(this._service);

//   /// Fetches nearby places using the Places API.
//   Future<List<Place>> getNearbyPlaces({
//     required LatLng location,
//     required double radius,
//     required PlaceType? type,
//     int maxResultCount = 10,
//     String? languageCode,
//     String? regionCode,
//     List<String>? fields,
//   }) async {
//     try {
//       return await _service.nearbySearch(
//         location: location,
//         radius: radius,
//         includedType: type,
//         maxResultCount: maxResultCount,
//         languageCode: languageCode,
//         regionCode: regionCode,
//       );
//     } catch (e) {
//       throw Exception('Failed to fetch nearby places: $e');
//     }
//   }
// }
