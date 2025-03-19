// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/place.dart';

/// Service for interacting with the Google Places API.
class PlacesService {
  /// Google Maps API key loaded from environment variables
  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  /// Base URL for the Google Places API (v1)
  final String baseUrl = 'https://places.googleapis.com/v1/places';

  /// Default fields to retrieve from the Places API.
  ///
  /// These fields determine what data is returned for each place.
  /// For a complete list of available fields, see:
  /// https://developers.google.com/maps/documentation/places/web-service/nearby-search#fieldmask
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

  /// Default fields to retrieve from the Places API.
  ///
  /// These fields determine what data is returned for each place.
  /// For a complete list of available fields, see:
  /// https://developers.google.com/maps/documentation/places/web-service/text-search#fieldmask
  static const List<String> DEFAULT_TEXT_SEARCH_FIELDS =
      DEFAULT_NEARBY_SEARCH_FIELDS;

  /// Fetches nearby places using the Nearby Search endpoint.
  ///
  /// Parameters:
  /// - [location]: The geographic location to search around
  /// - [includedType]: Category of places to search for
  /// - [radius]: Search radius in meters (must be between 0 and 50,000)
  /// - [maxResultCount]: Maximum number of results to return
  /// - [rankBy]: How to rank results (by popularity or distance). Use the [RankPreferenceNearbySearch] enum.
  /// - [languageCode]: Language for results (e.g., 'en', 'fr')
  /// - [regionCode]: Region bias for results (e.g., 'us', 'ca')
  ///
  /// Returns:
  /// A List of [Place] objects matching the search criteria
  ///
  /// Throws:
  /// - [NoPlacesFoundException]: If no places match the search criteria
  /// - [PlacesApiException]: If API key is missing or request fails
  Future<List<Place>> nearbySearch({
    required LatLng location,
    required PlaceType? includedType,
    double radius = 3000,
    int maxResultCount = 10,
    RankPreferenceNearbySearch rankBy = RankPreferenceNearbySearch.POPULARITY,
    String? languageCode = 'en',
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

  /// Fetches places using the Text Search endpoint based on a text query.
  ///
  /// This method searches for places using natural language queries (e.g., "coffee near me").
  /// It's ideal for free-text searches when the user types what they're looking for.
  /// The search is biased toward the provided location but can return results from further away
  /// if they're highly relevant to the query.
  ///
  /// Parameters:
  /// - [textQuery]: The text string to search for (e.g., "pizza in New York")
  /// - [location]: The geographic location to bias search results toward
  /// - [radius]: Search bias radius in meters (0-50,000)s
  /// - [includedType]: Optional category to filter results. Note: Only uses the FIRST type
  ///   from the PlaceType enum's mapping to Google types
  /// - [openNow]: Whether to only return places currently open
  /// - [pageSize]: Number of results per page (1-20, defaults to 10)
  /// - [rankBy]: How to rank results - by popularity or distance
  /// - [includePureServiceAreaBusinesses]: Whether to include businesses without physical locations
  /// - [minRating]: Minimum rating threshold (0.0-5.0) for returned places
  /// - [languageCode]: Language for results (e.g., 'en', 'fr', defaults to 'en')
  /// - [regionCode]: Region bias for results (e.g., 'us', 'ca')
  ///
  /// Returns:
  /// A List of [Place] objects matching the search query and filters
  ///
  /// Throws:
  /// - [NoPlacesFoundException]: If no places match the text query
  /// - [PlacesApiException]: If API key is missing, request fails, or other API errors occur
  Future<List<Place>> textSearch({
    required String textQuery,
    required LatLng location,
    required PlaceType? includedType,
    double radius = 3000,
    bool? openNow = true,
    int pageSize = 10,
    RankPreferenceTextSearch rankBy = RankPreferenceTextSearch.RELEVANCE,
    bool includePureServiceAreaBusinesses = false,
    double? minRating,
    String? languageCode = 'en',
    String? regionCode,
  }) async {
    if (_apiKey == null) {
      throw PlacesApiException('Google Maps API key is not configured');
    }

    final fieldMask = DEFAULT_TEXT_SEARCH_FIELDS
        .map((field) => 'places.$field')
        .toList()
        .join(',');

    final url = '$baseUrl:searchText';
    final body = {
      'textQuery': textQuery,
      'pageSize': pageSize.clamp(1, 20),
      'locationBias': {
        'circle': {
          'center': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
          'radius': radius,
        },
      },
      'rankPreference': rankBy.name,
      if (includedType != null)
        'includedType': includedType.toGooglePlaceTypes().first,
      'openNow': openNow,
      'includePureServiceAreaBusinesses': includePureServiceAreaBusinesses,
      if (minRating != null) 'minRating': minRating.clamp(0.0, 5.0),
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
              'No places found for query: "$textQuery"');
        }

        return places.map((place) => Place.fromJson(place)).toList();
      } else {
        throw PlacesApiException(
            'Failed to load text search results: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is NoPlacesFoundException || e is PlacesApiException) {
        rethrow;
      }
      throw PlacesApiException('Error performing text search: ${e.toString()}');
    }
  }
}

/// Enum defining how search results should be ranked for the nearbySearch() function.
///
/// - [POPULARITY]: Sort by popularity (most popular places first)
/// - [DISTANCE]: Sort by distance (closest places first)
enum RankPreferenceNearbySearch { POPULARITY, DISTANCE }

/// Enum defining how search results should be ranked for the textSearch() function.
///
/// - [RELEVANCE]: Sort by relevance (most relevant places first)
/// - [DISTANCE]: Sort by distance (closest places first)
enum RankPreferenceTextSearch { RELEVANCE, DISTANCE }

/// Enum defining categories of places that can be searched for.
///
/// Each category maps to multiple Google Places API types to provide
/// more comprehensive results.
///
/// If you need to add more place types, consult the Google Place Type API documentation: https://developers.google.com/maps/documentation/places/web-service/place-types
enum PlaceType {
  healthCenter('Health Center'),
  foodDrink('Food & Drink'),
  studyPlace('Study Place'),
  coffeeShop('Coffee Shop'),
  gym('Gym'),
  grocery('Grocery');

  /// User-friendly name for the place type
  final String displayName;

  /// Constructor requiring a display name
  const PlaceType(this.displayName);

  /// Converts the app's place type to Google Places API type identifiers.
  ///
  /// Returns a list of string identifiers that the Google Places API uses
  /// to categorize places. Each enum value maps to multiple related Google types
  /// to provide more comprehensive search results.
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
          'convenience_store'
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
          'market',
          'wholesaler'
        ];
    }
  }
}

/// Exception thrown when the Places API call succeeds but no places are found.
///
/// This exception is used to distinguish between API errors and
/// valid responses with zero results.
class NoPlacesFoundException implements Exception {
  /// Error message explaining why no places were found
  final String message;

  /// Constructor requiring an error message
  NoPlacesFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when a specific place is not found.
///
/// This is typically used when searching for a place by ID.
class PlaceNotFoundException implements Exception {
  /// Error message explaining why the place was not found
  final String message;

  /// Constructor requiring an error message
  PlaceNotFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown for general Places API errors.
///
/// This could include invalid API keys, exceeding quota limits,
/// network issues, or malformed requests.
class PlacesApiException implements Exception {
  /// Error message describing the API error
  final String message;

  /// Constructor requiring an error message
  PlacesApiException(this.message);

  @override
  String toString() => message;
}
