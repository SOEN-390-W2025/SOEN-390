import 'dart:developer' as dev;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';

/// Accessibility features that may be available at a place
enum AccessibilityFeature {
  wheelchairAccessibleParking,
  wheelchairAccessibleEntrance,
  wheelchairAccessibleRestroom,
  wheelchairAccessibleSeating,
}

/// Represents a place with its details from the Places API
/// See: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Place
class Place {
  final String id;
  final String name;
  final String? address;
  final LatLng location;
  final double? rating;
  final List<String> types;
  final bool? isOpen;
  final String? nationalPhoneNumber;
  final String? internationalPhoneNumber;
  final String? websiteUri;
  final String? primaryType;
  final int? userRatingCount;
  final String? priceLevel;
  final Map<AccessibilityFeature, bool>? accessibilityOptions;

  // Routing-related properties
  final int? distanceMeters;
  final int? durationSeconds;
  final TravelMode? travelMode;

  /// Creates a new place instance
  ///
  /// Throws [ArgumentError] if [id] is empty
  Place({
    required this.id,
    required this.name,
    this.address,
    required this.location,
    this.rating,
    required this.types,
    this.isOpen,
    this.nationalPhoneNumber,
    this.internationalPhoneNumber,
    this.websiteUri,
    this.primaryType,
    this.userRatingCount,
    this.priceLevel,
    this.accessibilityOptions,
    this.distanceMeters,
    this.durationSeconds,
    this.travelMode,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('Place requires a non-empty ID');
    }
  }

  /// Creates a Place from JSON data
  ///
  /// [json] - The place JSON data
  /// [routingSummary] - Optional routing information JSON
  ///
  /// Throws [FormatException] if the JSON is missing required fields
  factory Place.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic>? routingSummary}) {
    final id = json['id'];
    if (id == null || (id is String && id.isEmpty)) {
      throw const FormatException('Invalid or missing place ID in JSON data');
    }

    // Parse location data
    final locationData = json['location'];
    if (locationData == null) {
      throw const FormatException('Missing location data in JSON');
    }

    final location = LatLng(
      locationData['latitude']?.toDouble() ?? 0.0,
      locationData['longitude']?.toDouble() ?? 0.0,
    );

    // Parse routing information if available
    final routingInfo = _parseRoutingInfo(routingSummary);

    // Parse accessibility options
    final accessibilityOptions = _parseAccessibilityOptions(json);

    return Place(
      id: id,
      name: json['displayName']?['text'] ?? json['name'] ?? 'Unknown',
      address: json['formattedAddress'],
      location: location,
      rating: json['rating']?.toDouble(),
      types: json['types'] != null ? List<String>.from(json['types']) : [],
      isOpen: json['currentOpeningHours']?['openNow'],
      nationalPhoneNumber: json['nationalPhoneNumber'],
      internationalPhoneNumber: json['internationalPhoneNumber'],
      websiteUri: json['websiteUri'],
      primaryType: json['primaryType'],
      userRatingCount: json['userRatingCount'] as int?,
      priceLevel: json['priceLevel'],
      accessibilityOptions: accessibilityOptions,
      distanceMeters: routingInfo.$1,
      durationSeconds: routingInfo.$2,
      travelMode: routingInfo.$3,
    );
  }

  /// Safely tries to create a Place from JSON, returns null if parsing fails
  static Place? tryFromJson(Map<String, dynamic> json) {
    try {
      return Place.fromJson(json);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      dev.log('Failed to create Place from JSON', error: e);
      return null;
    }
  }

  /// Converts the place to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'rating': rating,
      'types': types,
      'isOpen': isOpen,
      'phoneNumber': nationalPhoneNumber,
      'internationalPhoneNumber': internationalPhoneNumber,
      'websiteUri': websiteUri,
      'primaryType': primaryType,
      'userRatingCount': userRatingCount,
      'priceLevel': priceLevel,
      'accessibilityOptions': accessibilityOptions
          ?.map((key, value) => MapEntry(key.toString(), value)),
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'travelMode': travelMode?.name,
    };
  }

  /// Returns a human-readable formatted distance string
  String? get formattedDistance =>
      distanceMeters != null ? _formatDistance(distanceMeters!) : null;

  /// Returns a human-readable formatted duration string
  String? get formattedDuration =>
      durationSeconds != null ? _formatDuration(durationSeconds!) : null;

  // Private helper methods

  /// Parses routing information from the routing summary JSON
  /// Returns a tuple of (distanceMeters, durationSeconds, travelMode)
  static (int?, int?, TravelMode?) _parseRoutingInfo(
      Map<String, dynamic>? routingSummary) {
    if (routingSummary == null) {
      return (null, null, null);
    }

    int? distanceMeters;
    int? durationSeconds;
    final TravelMode? travelMode = routingSummary['travelMode'];

    if (routingSummary.containsKey('legs') &&
        routingSummary['legs'] is List &&
        routingSummary['legs'].isNotEmpty) {
      final leg = routingSummary['legs'][0];

      // Extract distance
      distanceMeters = leg['distanceMeters'];

      // Extract duration - comes as a string like "597s"
      final durationStr = leg['duration'];
      if (durationStr is String && durationStr.endsWith('s')) {
        durationSeconds =
            int.tryParse(durationStr.substring(0, durationStr.length - 1));
      }
    }

    return (distanceMeters, durationSeconds, travelMode);
  }

  /// Parses accessibility options from the JSON
  static Map<AccessibilityFeature, bool>? _parseAccessibilityOptions(
      Map<String, dynamic> json) {
    if (json['accessibilityOptions'] == null) {
      return null;
    }

    final accessibility = json['accessibilityOptions'] as Map<String, dynamic>;
    return {
      AccessibilityFeature.wheelchairAccessibleParking:
          accessibility['wheelchairAccessibleParking'] ?? false,
      AccessibilityFeature.wheelchairAccessibleEntrance:
          accessibility['wheelchairAccessibleEntrance'] ?? false,
      AccessibilityFeature.wheelchairAccessibleRestroom:
          accessibility['wheelchairAccessibleRestroom'] ?? false,
      AccessibilityFeature.wheelchairAccessibleSeating:
          accessibility['wheelchairAccessibleSeating'] ?? false,
    };
  }

  /// Formats seconds into a human-readable duration string
  static String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }

    if (seconds < 3600) {
      return '${(seconds / 60).round()} min';
    }

    final hours = (seconds / 3600).floor();
    final mins = ((seconds % 3600) / 60).round();

    if (mins > 0) {
      return '$hours h $mins min';
    }

    return '$hours h';
  }

  /// Formats meters into a human-readable distance string
  static String _formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    }

    final km = (meters / 1000).toStringAsFixed(1);
    return '$km km';
  }
}

/// Enum defining categories of places that can be searched for.
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
