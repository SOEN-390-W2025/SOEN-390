import 'dart:developer' as dev;

import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final Map<String, bool>? accessibilityOptions;

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
  }) {
    if (id.isEmpty) {
      throw ArgumentError('Place requires a non-empty ID');
    }
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null || (id is String && id.isEmpty)) {
      throw const FormatException('Invalid or missing place ID in JSON data');
    }

    // Parse accessibility options if available
    Map<String, bool>? accessibilityOptions;
    if (json['accessibilityOptions'] != null) {
      final accessibility =
          json['accessibilityOptions'] as Map<String, dynamic>;
      accessibilityOptions = {
        'wheelchairAccessibleParking':
            accessibility['wheelchairAccessibleParking'] ?? false,
        'wheelchairAccessibleEntrance':
            accessibility['wheelchairAccessibleEntrance'] ?? false,
        'wheelchairAccessibleRestroom':
            accessibility['wheelchairAccessibleRestroom'] ?? false,
        'wheelchairAccessibleSeating':
            accessibility['wheelchairAccessibleSeating'] ?? false,
      };
    }

    // Validate location data is available
    final locationData = json['location'];
    if (locationData == null) {
      throw const FormatException('Missing location data in JSON');
    }

    return Place(
      id: id,
      name: json['displayName']?['text'] ?? json['name'] ?? 'Unknown',
      address: json['formattedAddress'],
      location: LatLng(
        locationData['latitude']?.toDouble() ?? 0.0,
        locationData['longitude']?.toDouble() ?? 0.0,
      ),
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
    );
  }

  // Static method to safely try creating a Place from JSON
  static Place? tryFromJson(Map<String, dynamic> json) {
    try {
      return Place.fromJson(json);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      dev.log('Failed to create Place from JSON: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'rating': rating,
      'types': types,
      'isOpen': isOpen,
      'nationalPhoneNumber': nationalPhoneNumber,
      'internationalPhoneNumber': internationalPhoneNumber,
      'websiteUri': websiteUri,
      'primaryType': primaryType,
      'userRatingCount': userRatingCount,
      'priceLevel': priceLevel,
      'accessibilityOptions': accessibilityOptions,
    };
  }
}
