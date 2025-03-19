// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/place.dart';

class PlacesService {
  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  final String baseUrl = 'https://places.googleapis.com/v1/places';

  // List of all possible fields: https://developers.google.com/maps/documentation/places/web-service/nearby-search#fieldmask
  static const List<String> DEFAULT_NEARBY_SEARCH_FIELDS = [
    'id',
    'types',
    'internationalPhoneNumber',
    'formattedAddress',
    'location',
    'rating',
    'googleMapsUri',
    'websiteUri',
    'regularOpeningHours',
    'displayName',
    'primaryType',
    'accessibilityOptions',
    'userRatingCount',
    'accessibilityOptions',
    'generativeSummary',
  ];

  /// Fetches nearby places using the Nearby Search endpoint.
  ///
  /// The [radius] parameter must be between 0 and 50,000 meters.
  Future<List<Place>> nearbySearch({
    required LatLng location,
    required PlaceType? includedType,
    double radius = 1000,
    int maxResultCount = 10,
    RankPreference rankBy = RankPreference.DISTANCE,
    String? languageCode,
    String? regionCode,
  }) async {
    if (_apiKey == null) {
      throw PlacesApiException('Google Maps API key is not configured');
    }

    final fieldMask = DEFAULT_NEARBY_SEARCH_FIELDS
        .map((field) => 'places.$field')
        .toList()
        .join(',');

    final url = '$baseUrl:searchNearby';
    final body = {
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
          'radius': radius,
        },
      },
      'maxResultCount': maxResultCount,
      'rankPreference': rankBy.name,
      if (includedType != null)
        'includedTypes': includedType.toGooglePlaceTypes(),
      if (languageCode != null) 'languageCode': languageCode,
      if (regionCode != null) 'regionCode': regionCode,
    };

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': fieldMask,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final places = data['places'] as List<dynamic>? ?? [];

        if (places.isEmpty) {
          throw NoPlacesFoundException(
              'No places found matching the search criteria');
        }

        return places.map((place) => Place.fromJson(place)).toList();
      } else {
        throw PlacesApiException(
            'Failed to load nearby places: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is NoPlacesFoundException || e is PlacesApiException) {
        rethrow;
      }
      throw PlacesApiException(
          'Error searching for nearby places: ${e.toString()}');
    }
  }
}

enum RankPreference { POPULARITY, DISTANCE }

enum PlaceType {
  healthCenter('Health Center'),
  foodDrink('Food & Drink'),
  studyPlace('Study Place'),
  coffeeShop('Coffee Shop'),
  gym('Gym'),
  grocery('Grocery');

  final String displayName;

  const PlaceType(this.displayName);

  List<String> toGooglePlaceTypes() {
    switch (this) {
      case PlaceType.healthCenter:
        return [
          'hospital',
          'doctor',
          'pharmacy',
          'dental_clinic',
          'dentist',
          'drugstore',
          'physiotherapist',
          'wellness_center',
        ];
      case PlaceType.foodDrink:
        return [
          'restaurant',
          'bakery',
          'bar',
          'deli',
          'diner',
          'pub',
          'food_court',
          'bar_and_grill',
          'candy_store',
          'confectionery',
          'dessert_shop',
          'donut_shop',
          'ice_cream_shop',
          'juice_shop',
          'meal_delivery',
          'meal_takeaway',
          'sandwich_shop',
          'steak_house',
        ];
      case PlaceType.studyPlace:
        return ['library', 'university', 'book_store'];
      case PlaceType.coffeeShop:
        return [
          'coffee_shop',
          'cafe',
          'bakery',
          'tea_house',
        ];
      case PlaceType.gym:
        return ['gym', 'fitness_center'];
      case PlaceType.grocery:
        return [
          'grocery_store',
          'supermarket',
          'food_store',
          'butcher_shop',
          'convenience_store',
          'market',
          'warehouse_store',
          'wholesaler'
        ];
    }
  }
}

/// Exception thrown when the Places API call succeeds but no places are found
class NoPlacesFoundException implements Exception {
  final String message;
  NoPlacesFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when a specific place is not found
class PlaceNotFoundException implements Exception {
  final String message;
  PlaceNotFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown for general Places API errors
class PlacesApiException implements Exception {
  final String message;
  PlacesApiException(this.message);

  @override
  String toString() => message;
}
