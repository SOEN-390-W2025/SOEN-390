// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/logger_util.dart';
import '../domain-model/place.dart';

/// Service for interacting with the Google Places API.
class PlacesService {
  // Singleton implementation
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService([http.Client? client]) {
    _instance._client =
        client ?? http.Client(); // Default to new http.Client() if not provided
    return _instance;
  }
  PlacesService._internal();
  late http.Client _client;

  /// Google Maps API key loaded from environment variables
  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  /// Base URL for the Google Places API (v1)
  final String _baseUrl = 'https://places.googleapis.com/v1/places';

  /// Fields to retrieve from the Places API.
  /// For available fields, see: https://developers.google.com/maps/documentation/places/web-service/nearby-search#fieldmask
  static const List<String> _DEFAULT_PLACE_FIELDS = [
    'places.id',
    'places.types',
    'places.internationalPhoneNumber',
    'places.formattedAddress',
    'places.location',
    'places.rating',
    'places.googleMapsUri',
    'places.websiteUri',
    'places.regularOpeningHours',
    'places.displayName',
    'places.primaryType',
    'places.accessibilityOptions',
    'places.userRatingCount',
    'places.generativeSummary',
  ];

  /// Additional fields requested when routing information is needed
  static const List<String> _ROUTING_FIELDS = [
    'routingSummaries',
  ];

  /// Fetches nearby places using the Nearby Search endpoint.
  ///
  /// This method searches for places within a specified radius of the provided location.
  /// Various filters can be applied to narrow down results based on place type,
  /// ranking preference, and other criteria.
  ///
  /// Parameters:
  /// - [location]: The geographical point to search around
  /// - [includedType]: Filter results to include only places of this type (required but can be null)
  /// - [radius]: Search radius in meters (Between 0-50,000)
  /// - [maxResultCount]: Maximum number of results to return (Between 1-20)
  /// - [rankBy]: How results should be ordered
  /// - [routingOptions]: Options for calculating routes to the places . Needs to be providede in order to get routing information (distance, travel time)
  /// - [languageCode]: Language for result text
  /// - [regionCode]: Region bias for results
  ///
  /// Returns a List of [Place] objects matching the search criteria.
  ///
  /// Throws:
  /// - [NoPlacesFoundException]: If no places match the search criteria
  /// - [PlacesApiException]: If API key is missing or request fails
  Future<List<Place>> nearbySearch({
    required LatLng location,
    required PlaceType? includedType,
    double radius = 1500,
    int maxResultCount = 10,
    RankPreferenceNearbySearch rankBy = RankPreferenceNearbySearch.POPULARITY,
    PlacesRoutingOptions? routingOptions,
    String? languageCode = 'en',
    String? regionCode,
  }) async {
    _validateApiKey();

    final request = NearbySearchRequest(
      location: location,
      includedType: includedType,
      radius: radius,
      maxResultCount: maxResultCount,
      rankBy: rankBy,
      routingOptions: routingOptions,
      languageCode: languageCode,
      regionCode: regionCode,
    );

    return _executeRequest(
      endpoint: ':searchNearby',
      requestBody: request.toJson(),
      fieldMask: _buildFieldMask(includeRouting: routingOptions != null),
      queryDescription: 'nearby places',
    );
  }

  /// Fetches places using the Text Search endpoint based on a text query.
  ///
  /// Parameters:
  /// - [textQuery]: The text search query
  /// - [location]: The geographical point to bias results towards
  /// - [includedType]: Filter results to include only places of this type (required but can be null)
  /// - [radius]: Search radius in meters for location bias (Between 0-50,000)
  /// - [openNow]: Whether to return only places that are currently open
  /// - [pageSize]: Number of results per page (Between 0-20)
  /// - [rankBy]: How results should be ordered
  /// - [includePureServiceAreaBusinesses]: Whether to include businesses without physical locations
  /// - [minRating]: Minimum rating threshold for results (Between 0.0-5.0)
  /// - [routingOptions]: Options for calculating routes to the places . Needs to be providede in order to get routing information (distance, travel time)
  /// - [languageCode]: Language for result text (default: 'en')
  /// - [regionCode]: Region bias for results
  ///
  /// Returns a List of [Place] objects matching the search query and filters.
  ///
  /// Throws:
  /// - [NoPlacesFoundException]: If no places match the text query
  /// - [PlacesApiException]: If API key is missing, request fails, or other API errors occur
  Future<List<Place>> textSearch({
    required String textQuery,
    required LatLng location,
    required PlaceType? includedType,
    double radius = 1500,
    bool? openNow = true,
    int pageSize = 10,
    RankPreferenceTextSearch rankBy = RankPreferenceTextSearch.RELEVANCE,
    bool includePureServiceAreaBusinesses = false,
    double? minRating,
    PlacesRoutingOptions? routingOptions,
    String? languageCode = 'en',
    String? regionCode,
  }) async {
    _validateApiKey();

    final request = TextSearchRequest(
      textQuery: textQuery,
      location: location,
      includedType: includedType,
      radius: radius,
      openNow: openNow,
      pageSize: pageSize,
      rankBy: rankBy,
      includePureServiceAreaBusinesses: includePureServiceAreaBusinesses,
      minRating: minRating,
      routingOptions: routingOptions,
      languageCode: languageCode,
      regionCode: regionCode,
    );

    return _executeRequest(
      endpoint: ':searchText',
      requestBody: request.toJson(),
      fieldMask: _buildFieldMask(includeRouting: routingOptions != null),
      queryDescription: 'query: "$textQuery"',
    );
  }

  /// Validates if the API key is available in environment variables.
  ///
  /// Throws [PlacesApiException] if the API key is not configured.
  void _validateApiKey() {
    if (_apiKey == null) {
      throw PlacesApiException('Google Maps API key is not configured');
    }
  }

  /// Builds the field mask string used in API requests.
  ///
  /// The field mask determines which fields are returned in the API response.
  ///
  /// Parameters:
  /// - [includeRouting]: Whether to include routing information fields (default: false)
  ///
  /// Returns a comma-separated string of field names to be used in the X-Goog-FieldMask header.
  String _buildFieldMask({bool includeRouting = false}) {
    final fields = List<String>.from(_DEFAULT_PLACE_FIELDS);
    if (includeRouting) {
      fields.addAll(_ROUTING_FIELDS);
    }
    return fields.join(',');
  }

  /// Executes an API request and processes the response.
  ///
  /// This is an internal method that handles the HTTP communication with the Places API.
  ///
  /// Parameters:
  /// - [endpoint]: The API endpoint to call (required)
  /// - [requestBody]: The JSON body of the request (required)
  /// - [fieldMask]: Fields to include in the response (required)
  /// - [queryDescription]: Human-readable description for error messages (required)
  ///
  /// Returns a List of [Place] objects parsed from the API response.
  ///
  /// Throws:
  /// - [NoPlacesFoundException]: If no places are found
  /// - [PlacesApiException]: For API errors or request failures
  Future<List<Place>> _executeRequest({
    required String endpoint,
    required Map<String, dynamic> requestBody,
    required String fieldMask,
    required String queryDescription,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey!,
      'X-Goog-FieldMask': fieldMask,
    };

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.body, queryDescription, requestBody);
      } else {
        throw PlacesApiException(
            'Failed to load $queryDescription: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is NoPlacesFoundException || e is PlacesApiException) {
        rethrow;
      }
      throw PlacesApiException(
          'Error searching for $queryDescription: ${e.toString()}');
    }
  }

  /// Parses the API response into a list of Place objects.
  ///
  /// Extracts place data and optional routing information from the API response JSON.
  ///
  /// Parameters:
  /// - [responseBody]: The JSON response string from the API
  /// - [queryDescription]: Description of the query for error messages
  /// - [requestBody]: Optional original request body, used to extract travel mode
  ///
  /// Returns a List of [Place] objects constructed from the response data.
  ///
  /// Throws [NoPlacesFoundException] if the places array is empty.
  List<Place> _parseResponse(String responseBody, String queryDescription,
      [Map<String, dynamic>? requestBody]) {
    final data = json.decode(responseBody);
    final places = data['places'] as List<dynamic>? ?? [];
    final routingSummaries = data['routingSummaries'] as List<dynamic>? ?? [];

    if (places.isEmpty) {
      throw NoPlacesFoundException('No places found for $queryDescription');
    }

    TravelMode? requestTravelMode;
    if (requestBody != null &&
        requestBody.containsKey('routingParameters') &&
        requestBody['routingParameters']['travelMode'] != null) {
      // Convert the string travel mode name to enum value
      final travelModeName = requestBody['routingParameters']['travelMode'];
      requestTravelMode = TravelMode.values.firstWhere(
        (mode) => mode.name == travelModeName,
        orElse: () => TravelMode.DRIVE, // Default fallback
      );
    }

    return List.generate(
      places.length,
      (i) {
        // Get the routing summary if available
        Map<String, dynamic>? routingSummary =
            i < routingSummaries.length ? routingSummaries[i] : null;

        // If we have routing data but no travel mode in it, add it from the request
        if (routingSummary != null && requestTravelMode != null) {
          // Create a new copy to avoid modifying the original data
          routingSummary = Map<String, dynamic>.from(routingSummary);

          // Store the enum itself, not just the name string
          routingSummary['travelMode'] = requestTravelMode;
        }

        return Place.fromJson(places[i], routingSummary: routingSummary);
      },
    );
  }
}

/// Request model for nearby search queries.
///
/// Encapsulates parameters for the Places API's nearby search endpoint.
/// This class converts Dart objects into the proper JSON structure expected by the API.
class NearbySearchRequest {
  final LatLng location;
  final PlaceType? includedType;
  final double radius;
  final int maxResultCount;
  final RankPreferenceNearbySearch rankBy;
  final PlacesRoutingOptions? routingOptions;
  final String? languageCode;
  final String? regionCode;

  NearbySearchRequest({
    required this.location,
    required this.includedType,
    required this.radius,
    required this.maxResultCount,
    required this.rankBy,
    this.routingOptions,
    this.languageCode,
    this.regionCode,
  });

  /// Converts this request to a JSON map compatible with the Places API.
  ///
  /// Automatically sanitizes routing options to ensure compatibility.
  Map<String, dynamic> toJson() {
    // Create a safe version of routing options if present
    final safeRoutingOptions = routingOptions?.getSafeOptions();

    return {
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
        'includedTypes': includedType!.toGooglePlaceTypes(),
      if (languageCode != null) 'languageCode': languageCode,
      if (regionCode != null) 'regionCode': regionCode,
      // Use the safe options instead of the original
      if (safeRoutingOptions != null)
        'routingParameters': safeRoutingOptions.toJson(location),
    };
  }
}

/// Request model for text-based search queries.
///
/// Encapsulates parameters for the Places API's text search endpoint.
/// This class converts Dart objects into the proper JSON structure expected by the API.
class TextSearchRequest {
  final String textQuery;
  final LatLng location;
  final PlaceType? includedType;
  final double radius;
  final bool? openNow;
  final int pageSize;
  final RankPreferenceTextSearch rankBy;
  final bool includePureServiceAreaBusinesses;
  final double? minRating;
  final PlacesRoutingOptions? routingOptions;
  final String? languageCode;
  final String? regionCode;

  TextSearchRequest({
    required this.textQuery,
    required this.location,
    required this.includedType,
    required this.radius,
    required this.openNow,
    required this.pageSize,
    required this.rankBy,
    required this.includePureServiceAreaBusinesses,
    this.minRating,
    this.routingOptions,
    this.languageCode,
    this.regionCode,
  });

  /// Converts this request to a JSON map compatible with the Places API.
  ///
  /// Automatically sanitizes routing options to ensure compatibility and
  /// applies constraints to values like pageSize and minRating
  Map<String, dynamic> toJson() {
    // Create a safe version of routing options if present
    final safeRoutingOptions = routingOptions?.getSafeOptions();

    return {
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
        'includedType': includedType!.toGooglePlaceTypes().first,
      'openNow': openNow,
      'includePureServiceAreaBusinesses': includePureServiceAreaBusinesses,
      if (minRating != null) 'minRating': minRating!.clamp(0.0, 5.0),
      if (languageCode != null) 'languageCode': languageCode,
      if (regionCode != null) 'regionCode': regionCode,
      // Use the safe options instead of the original
      if (safeRoutingOptions != null)
        'routingParameters': safeRoutingOptions.toJson(location),
    };
  }
}

/// Ranking options for nearby search results.
///
/// - POPULARITY: Results sorted by their popularity (default)
/// - DISTANCE: Results sorted by distance from the search location
enum RankPreferenceNearbySearch { POPULARITY, DISTANCE }

/// Ranking options for text search results.
///
/// - RELEVANCE: Results sorted by relevance to the search query (default)
/// - DISTANCE: Results sorted by distance from the specified location
enum RankPreferenceTextSearch { RELEVANCE, DISTANCE }

/// Travel modes supported by the Places API for routing calculations.
///
/// Note: The Routes API also supports a mode of TRANSIT, but that mode
/// is not supported by the Places API.
enum TravelMode { DRIVE, BICYCLE, WALK }

/// Route modifiers for transportation options.
///
/// These modifiers change how routes are calculated based on preferences like avoiding tolls or highways.
/// Not all modifiers are compatible with all travel modes.
class RouteModifiers {
  final bool? avoidTolls;
  final bool? avoidHighways;
  final bool? avoidFerries;
  final bool? avoidIndoor;

  const RouteModifiers({
    this.avoidTolls,
    this.avoidHighways,
    this.avoidFerries,
    this.avoidIndoor,
  });

  Map<String, dynamic> toJson() {
    return {
      if (avoidTolls != null) 'avoidTolls': avoidTolls,
      if (avoidHighways != null) 'avoidHighways': avoidHighways,
      if (avoidFerries != null) 'avoidFerries': avoidFerries,
      if (avoidIndoor != null) 'avoidIndoor': avoidIndoor,
    };
  }
}

/// Class encapsulating all routing options for Places API requests.
///
/// Combines travel mode and route modifiers for calculating routes to places.
/// Handles compatibility between travel modes and modifiers automatically.
class PlacesRoutingOptions {
  final TravelMode? travelMode;
  final RouteModifiers? routeModifiers;

  const PlacesRoutingOptions({
    this.travelMode,
    this.routeModifiers,
  });

  /// Validates that route modifiers are compatible with the selected travel mode
  /// Returns a new PlacesRoutingOptions with only valid modifiers for the selected mode
  PlacesRoutingOptions getSafeOptions() {
    if (travelMode == null || routeModifiers == null) {
      return this;
    }

    // Create a new route modifiers object based on travel mode
    RouteModifiers safeModifiers;
    bool hasIncompatibleModifiers = false;

    switch (travelMode) {
      case TravelMode.DRIVE:
        // DRIVE mode supports: avoidTolls, avoidHighways, avoidFerries
        safeModifiers = RouteModifiers(
          avoidTolls: routeModifiers?.avoidTolls,
          avoidHighways: routeModifiers?.avoidHighways,
          avoidFerries: routeModifiers?.avoidFerries,
        );

        final List<String> usedIncompatibleModifiers = [];
        // Check for incompatible modifiers dynamically
        if (routeModifiers?.avoidIndoor == true) {
          usedIncompatibleModifiers.add('avoidIndoor');
        }

        // Log warnings for incompatible modifiers if any were used
        if (usedIncompatibleModifiers.isNotEmpty) {
          LoggerUtil.warning(
              '${usedIncompatibleModifiers.join(', ')} ${usedIncompatibleModifiers.length == 1 ? "modifier is" : "modifiers are"} not compatible with DRIVE mode and will be ignored');
          hasIncompatibleModifiers = true;
        }
        break;

      case TravelMode.WALK:
        // WALK mode only supports: avoidIndoor
        safeModifiers = RouteModifiers(
          avoidIndoor: routeModifiers?.avoidIndoor,
        );

        final List<String> usedIncompatibleModifiers = [];

        // Check for incompatible modifiers dynamically
        if (routeModifiers?.avoidTolls == true) {
          usedIncompatibleModifiers.add('avoidTolls');
        }
        if (routeModifiers?.avoidHighways == true) {
          usedIncompatibleModifiers.add('avoidHighways');
        }
        if (routeModifiers?.avoidFerries == true) {
          usedIncompatibleModifiers.add('avoidFerries');
        }

        // Log warnings for incompatible modifiers if any were used
        if (usedIncompatibleModifiers.isNotEmpty) {
          LoggerUtil.warning(
              '${usedIncompatibleModifiers.join(', ')} ${usedIncompatibleModifiers.length == 1 ? "modifier is" : "modifiers are"} not compatible with DRIVE mode and will be ignored');
          hasIncompatibleModifiers = true;
        }
        break;

      case TravelMode.BICYCLE:
        // BICYCLE doesn't support any route modifiers in the current API
        safeModifiers = const RouteModifiers();

        final List<String> usedIncompatibleModifiers = [];
        // Check for incompatible modifiers dynamically
        if (routeModifiers?.avoidTolls == true) {
          usedIncompatibleModifiers.add('avoidTolls');
        }
        if (routeModifiers?.avoidHighways == true) {
          usedIncompatibleModifiers.add('avoidHighways');
        }
        if (routeModifiers?.avoidFerries == true) {
          usedIncompatibleModifiers.add('avoidFerries');
        }
        if (routeModifiers?.avoidIndoor == true) {
          usedIncompatibleModifiers.add('avoidIndoor');
        }

        // Log warnings for incompatible modifiers if any were used
        if (usedIncompatibleModifiers.isNotEmpty) {
          LoggerUtil.warning(
              '${usedIncompatibleModifiers.join(', ')} ${usedIncompatibleModifiers.length == 1 ? "modifier is" : "modifiers are"} not supported with BICYCLE mode and will be ignored');
          hasIncompatibleModifiers = true;
        }
        break;

      default:
        safeModifiers = const RouteModifiers();
    }

    // Log a general message if incompatible modifiers were found
    if (hasIncompatibleModifiers) {
      LoggerUtil.info(
          'Sanitized incompatible route modifiers for ${travelMode.toString()} mode');
    }

    return PlacesRoutingOptions(
      travelMode: travelMode,
      routeModifiers: safeModifiers,
    );
  }

  Map<String, dynamic> toJson(LatLng origin) {
    return {
      'origin': {
        'latitude': origin.latitude,
        'longitude': origin.longitude,
      },
      if (travelMode != null) 'travelMode': travelMode!.name,
      if (routeModifiers != null) 'routeModifiers': routeModifiers!.toJson(),
    };
  }
}

/// Exception thrown when no places match the search criteria.
///
/// This is a normal condition that client code should handle gracefully,
/// typically by showing an appropriate message to the user.
class NoPlacesFoundException implements Exception {
  final String message;
  NoPlacesFoundException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown when a specific place cannot be found.
///
/// This is different from NoPlacesFoundException as it indicates
/// that a specific place that was expected to exist could not be found.
class PlaceNotFoundException implements Exception {
  final String message;
  PlaceNotFoundException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown for API errors, authentication issues, or network problems.
///
/// This exception indicates problems with the Places API itself rather than
/// with the search criteria. Client code should handle this by showing an
/// appropriate error message and possibly retrying the request.
class PlacesApiException implements Exception {
  final String message;
  PlacesApiException(this.message);
  @override
  String toString() => message;
}
