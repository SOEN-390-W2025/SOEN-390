import 'package:google_maps_flutter/google_maps_flutter.dart';

// List of all Place type attributes: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Place
class Place {
  final String id;
  final String name;
  final String? address;
  final LatLng location;
  final double? rating;
  final List<String> types;
  final bool? isOpen;

  Place({
    required this.id,
    required this.name,
    this.address,
    required this.location,
    this.rating,
    required this.types,
    this.isOpen,
  });
}
