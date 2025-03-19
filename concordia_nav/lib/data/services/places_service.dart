import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../domain-model/place.dart';
import '../repositories/places_repository.dart';

class PlacesService {
  final PlacesRepository _repository;

  PlacesService({PlacesRepository? repository})
      : _repository = repository ?? PlacesRepository();

  Future<List<Place>> getNearbyPlaces({
    required LatLng currentLocation,
    required PlaceType category,
    int radius = 1000,
  }) async {
    final places = await _repository.searchNearbyPlaces(
      location: Location(
          lat: currentLocation.latitude, lng: currentLocation.longitude),
      type: _getGooglePlaceType(category),
      radius: radius,
    );

    return places
        .map((p) => Place(
              id: p.placeId,
              name: p.name,
              address: p.vicinity,
              location:
                  LatLng(p.geometry!.location.lat, p.geometry!.location.lng),
              rating: p.rating?.toDouble(),
              types: p.types,
              isOpen: p.openingHours?.openNow,
            ))
        .toList();
  }

  String _getGooglePlaceType(PlaceType category) {
    switch (category) {
      case PlaceType.healthCenter:
        return 'hospital';
      case PlaceType.foodDrink:
        return 'restaurant';
      case PlaceType.studyPlace:
        return 'library';
      case PlaceType.coffeeShop:
        return 'cafe';
      case PlaceType.gym:
        return 'gym';
      case PlaceType.grocery:
        return 'food_store';
    }
  }
}

enum PlaceType {
  healthCenter('Health Center'),
  foodDrink('Food & Drink'),
  studyPlace('Study Place'),
  coffeeShop('Coffee Shop'),
  gym('Gym'),
  grocery('Grocery');

  final String displayName;

  const PlaceType(this.displayName);
}
