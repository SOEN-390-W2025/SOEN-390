import 'package:concordia_nav/data/domain-model/place.dart';
import 'package:concordia_nav/data/services/places_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../map/map_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  group('PlaceType', () {
    test('healthCenter returns correct place types', () {
      final placeTypes = PlaceType.healthCenter.toGooglePlaceTypes();
      expect(
          placeTypes,
          containsAll([
            'hospital',
            'doctor',
            'pharmacy',
            'dental_clinic',
            'dentist',
            'drugstore',
            'physiotherapist',
            'wellness_center',
          ]));
    });

    test('foodDrink returns correct place types', () {
      final placeTypes = PlaceType.foodDrink.toGooglePlaceTypes();
      expect(
          placeTypes,
          containsAll([
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
          ]));
    });

    test('studyPlace returns correct place types', () {
      final placeTypes = PlaceType.studyPlace.toGooglePlaceTypes();
      expect(placeTypes, containsAll(['library', 'university', 'book_store']));
    });

    test('coffeeShop returns correct place types', () {
      final placeTypes = PlaceType.coffeeShop.toGooglePlaceTypes();
      expect(placeTypes,
          containsAll(['coffee_shop', 'cafe', 'bakery', 'tea_house']));
    });

    test('gym returns correct place types', () {
      final placeTypes = PlaceType.gym.toGooglePlaceTypes();
      expect(placeTypes, containsAll(['gym', 'fitness_center']));
    });

    test('grocery returns correct place types', () {
      final placeTypes = PlaceType.grocery.toGooglePlaceTypes();
      expect(
          placeTypes,
          containsAll([
            'grocery_store',
            'supermarket',
            'food_store',
            'butcher_shop',
            'market',
            'wholesaler'
          ]));
    });
  });

  group('Place', () {
    test('parses routing info correctly when legs are present', () {
      final routingSummary = {
        'legs': [
          {
            'distanceMeters': 1000,
            'duration': '597s',
          }
        ],
      };

      final json = {
        'id': '123',
        'location': {'latitude': 10.0, 'longitude': 20.0},
        'displayName': {'text': 'Test Place'},
        'formattedAddress': '123 Test St.',
        'rating': 4.5,
        'types': ['restaurant'],
        'currentOpeningHours': {'openNow': true},
        'nationalPhoneNumber': '1234567890',
        'internationalPhoneNumber': '+11234567890',
        'websiteUri': 'http://testplace.com',
        'primaryType': 'restaurant',
        'userRatingCount': 150,
        'priceLevel': '2',
      };

      final place = Place.fromJson(json, routingSummary: routingSummary);

      expect(place.distanceMeters,
          1000); // Check that distanceMeters is correctly parsed
      expect(place.formattedDistance, '1.0 km');
      expect(place.durationSeconds,
          597); // Check that durationSeconds is correctly parsed
      expect(place.formattedDuration, '10 min');
    });

    test('returns null values when legs are missing', () {
      final routingSummary = {
        'travelMode': null,
      };

      final json = {
        'id': '123',
        'location': {'latitude': 10.0, 'longitude': 20.0},
        'displayName': {'text': 'Test Place'},
        'formattedAddress': '123 Test St.',
        'rating': 4.5,
        'types': ['restaurant'],
        'currentOpeningHours': {'openNow': true},
        'nationalPhoneNumber': '1234567890',
        'internationalPhoneNumber': '+11234567890',
        'websiteUri': 'http://testplace.com',
        'primaryType': 'restaurant',
        'userRatingCount': 150,
        'priceLevel': '2',
      };

      final place = Place.fromJson(json, routingSummary: routingSummary);

      expect(place.distanceMeters,
          isNull); // Check that distanceMeters is null when legs is missing
      expect(place.durationSeconds,
          isNull); // Check that durationSeconds is null when legs is missing
    });

    test('handles missing duration correctly', () {
      final routingSummary = {
        'legs': [
          {
            'distanceMeters': 1000,
            'duration': 'invalid_duration', // Invalid duration format
          }
        ],
        'travelMode': null,
      };

      final json = {
        'id': '123',
        'location': {'latitude': 10.0, 'longitude': 20.0},
        'displayName': {'text': 'Test Place'},
        'formattedAddress': '123 Test St.',
        'rating': 4.5,
        'types': ['restaurant'],
        'currentOpeningHours': {'openNow': true},
        'nationalPhoneNumber': '1234567890',
        'internationalPhoneNumber': '+11234567890',
        'websiteUri': 'http://testplace.com',
        'primaryType': 'restaurant',
        'userRatingCount': 150,
        'priceLevel': '2',
      };

      final place = Place.fromJson(json, routingSummary: routingSummary);

      expect(place.distanceMeters, 1000); // Distance should be correctly parsed
      expect(place.durationSeconds,
          isNull); // Invalid duration should result in null
    });

    test('tryFromJson with valid data should return a Place object', () {
      final json = {
        'id': 'place123',
        'displayName': {'text': 'Test Place'},
        'location': {'latitude': 10.0, 'longitude': 20.0},
        'types': ['restaurant'],
      };

      final place = Place.tryFromJson(json);
      expect(place, isNotNull);
      expect(place?.id, 'place123');
      expect(place?.name, 'Test Place');
      expect(place?.location.latitude, 10.0);
      expect(place?.location.longitude, 20.0);
    });

    test('tryFromJson with invalid data should return null and log error', () {
      final json = {
        'id': '',
        'location': null,
        'types': ['restaurant']
      };
      final place = Place.tryFromJson(json);
      expect(place, isNull); // Should return null due to invalid data
    });

    test('toJson should return the correct JSON structure', () {
      final place = Place(
        id: 'place123',
        name: 'Test Place',
        location: const LatLng(10.0, 20.0),
        types: ['restaurant'],
        isOpen: true,
      );

      final json = place.toJson();

      expect(json['id'], 'place123');
      expect(json['name'], 'Test Place');
      expect(json['location']['lat'], 10.0);
      expect(json['location']['lng'], 20.0);
      expect(json['types'], ['restaurant']);
      expect(json['isOpen'], true);
    });
  });

  group('PlacesRoutingOptions', () {
    test('getSafeOptions with DRIVE mode and valid modifiers', () {
      const routeModifiers = RouteModifiers(
          avoidTolls: true, avoidHighways: true, avoidIndoor: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.DRIVE,
        routeModifiers: routeModifiers,
      );

      // Get safe options
      final safeOptions = options.getSafeOptions();

      expect(safeOptions.routeModifiers?.avoidTolls, true);
      expect(safeOptions.routeModifiers?.avoidHighways, true);
      expect(safeOptions.routeModifiers?.avoidIndoor, null);
      expect(safeOptions.routeModifiers?.avoidFerries, null);
    });

    test('getSafeOptions with WALK mode and valid modifiers', () {
      const routeModifiers =
          RouteModifiers(avoidIndoor: true, avoidTolls: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.WALK,
        routeModifiers: routeModifiers,
      );

      // Get safe options
      final safeOptions = options.getSafeOptions();

      expect(safeOptions.routeModifiers?.avoidIndoor, true);
      expect(safeOptions.routeModifiers?.avoidTolls, null);
      expect(safeOptions.routeModifiers?.avoidHighways, null);
      expect(safeOptions.routeModifiers?.avoidFerries, null);
    });

    test('getSafeOptions with BICYCLE mode and modifiers (all unsupported)',
        () {
      const routeModifiers = RouteModifiers(
          avoidTolls: true,
          avoidHighways: true,
          avoidFerries: true,
          avoidIndoor: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.BICYCLE,
        routeModifiers: routeModifiers,
      );

      // Get safe options
      final safeOptions = options.getSafeOptions();

      expect(safeOptions.routeModifiers?.avoidTolls, null);
      expect(safeOptions.routeModifiers?.avoidHighways, null);
      expect(safeOptions.routeModifiers?.avoidIndoor, null);
      expect(safeOptions.routeModifiers?.avoidFerries, null);
    });

    test('getSafeOptions with no routeModifiers', () {
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.DRIVE,
        routeModifiers: null,
      );

      // Get safe options
      final safeOptions = options.getSafeOptions();

      expect(safeOptions.routeModifiers, isNull);
    });

    test('getSafeOptions with no travelMode', () {
      const options = PlacesRoutingOptions(
        travelMode: null,
        routeModifiers: null,
      );

      // Get safe options
      final safeOptions = options.getSafeOptions();

      expect(safeOptions.travelMode, isNull);
      expect(safeOptions.routeModifiers, isNull);
    });

    test('toJson for DRIVE mode', () {
      const routeModifiers =
          RouteModifiers(avoidTolls: true, avoidHighways: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.DRIVE,
        routeModifiers: routeModifiers,
      );

      final json = options.toJson(const LatLng(37.7749, -122.4194));

      expect(json['origin']['latitude'], 37.7749);
      expect(json['origin']['longitude'], -122.4194);
      expect(json['travelMode'], 'DRIVE');
      expect(json['routeModifiers']['avoidTolls'], true);
      expect(json['routeModifiers']['avoidHighways'], true);
    });

    test('toJson for WALK mode', () {
      const routeModifiers = RouteModifiers(avoidIndoor: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.WALK,
        routeModifiers: routeModifiers,
      );

      final json = options.toJson(const LatLng(37.7749, -122.4194));

      expect(json['origin']['latitude'], 37.7749);
      expect(json['origin']['longitude'], -122.4194);
      expect(json['travelMode'], 'WALK');
      expect(json['routeModifiers']['avoidIndoor'], true);
    });

    test('getSafeOptions should log incompatible modifiers for DRIVE mode', () {
      const routeModifiers = RouteModifiers(avoidIndoor: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.DRIVE,
        routeModifiers: routeModifiers,
      );

      options.getSafeOptions();
    });

    test('getSafeOptions should log incompatible modifiers for BICYCLE mode',
        () {
      const routeModifiers = RouteModifiers(
          avoidTolls: true, avoidFerries: true, avoidIndoor: true);
      const options = PlacesRoutingOptions(
        travelMode: TravelMode.BICYCLE,
        routeModifiers: routeModifiers,
      );

      options.getSafeOptions();
    });
  });

  group('PlacesService', () {
    late PlacesService placesService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      placesService = PlacesService(mockClient);
    });

    test('nearbySearch returns a list of places on success', () async {
      final mockResponse = jsonEncode({
        'places': [
          {
            'id': 'place_1',
            'displayName': {'text': 'Place 1'},
            'name': 'Place 1',
            'formattedAddress': '123 Example Street',
            'location': {
              'latitude': 45.4215,
              'longitude': -75.6972,
            },
            'rating': 4.5,
            'types': ['restaurant', 'food'],
            'currentOpeningHours': {'openNow': true},
            'nationalPhoneNumber': '+1234567890',
            'internationalPhoneNumber': '+1234567890',
            'websiteUri': 'https://example.com',
            'primaryType': 'restaurant',
            'userRatingCount': 150,
            'priceLevel': '2',
            'accessibilityOptions': {
              'wheelchairAccessibleParking': true,
              'wheelchairAccessibleEntrance': true,
              'wheelchairAccessibleRestroom': false,
              'wheelchairAccessibleSeating': true,
            },
          },
        ],
        'routingSummaries': [
          {
            'distance': 1500,
            'duration': 300,
          },
        ],
      });

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponse, 200));
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockResponse, 200));

      const location = LatLng(45.4215, -75.6992); // Example coordinates
      const NearbySearchOptions options = NearbySearchOptions(
        radius: 1500,
        rankBy: RankPreferenceNearbySearch.POPULARITY,
        languageCode: 'en',
        maxResultCount: 10,
      );
      final places = await placesService.nearbySearch(
          location: location, includedType: null, options: options);

      expect(places.length, 1);
      expect(places[0].name, 'Place 1');
    });

    test('nearbySearch throws an exception on API error', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 400));

      const location = LatLng(45.4215, -75.6992); // Example coordinates
      const NearbySearchOptions options = NearbySearchOptions(
        radius: 1500,
        rankBy: RankPreferenceNearbySearch.POPULARITY,
        languageCode: 'en',
        maxResultCount: 10,
      );
      expect(
        () => placesService.nearbySearch(
            location: location, includedType: null, options: options),
        throwsException,
      );
    });

    test('textSearch returns a list of places on success', () async {
      final mockResponse = jsonEncode({
        'places': [
          {
            'id': 'place_1',
            'displayName': {'text': 'Place 1'},
            'name': 'Place 1',
            'formattedAddress': '123 Example Street',
            'location': {
              'latitude': 45.4215,
              'longitude': -75.6972,
            },
            'rating': 4.5,
            'types': ['restaurant', 'food'],
            'currentOpeningHours': {'openNow': true},
            'nationalPhoneNumber': '+1234567890',
            'internationalPhoneNumber': '+1234567890',
            'websiteUri': 'https://example.com',
            'primaryType': 'restaurant',
            'userRatingCount': 150,
            'priceLevel': '2',
            'accessibilityOptions': {
              'wheelchairAccessibleParking': true,
              'wheelchairAccessibleEntrance': true,
              'wheelchairAccessibleRestroom': false,
              'wheelchairAccessibleSeating': true,
            },
          },
        ],
        'routingSummaries': [
          {
            'distance': 1500,
            'duration': 300,
          },
        ],
      });

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponse, 200));
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockResponse, 200));

      const location = LatLng(45.4215, -75.6992); // Example coordinates
      const TextSearchOptions options = TextSearchOptions(
        radius: 1500,
        openNow: true,
        pageSize: 10,
        rankBy: RankPreferenceTextSearch.RELEVANCE,
        languageCode: 'en',
      );
      final places = await placesService.textSearch(
          textQuery: 'test query',
          location: location,
          includedType: null,
          options: options);
      expect(places.length, 1);
      expect(places[0].name, 'Place 1');
    });

    test('textSearch throws an exception on API error', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 400));

      const location = LatLng(45.4215, -75.6992); // Example coordinates
      const TextSearchOptions options = TextSearchOptions(
        radius: 1500,
        openNow: true,
        pageSize: 10,
        rankBy: RankPreferenceTextSearch.RELEVANCE,
        languageCode: 'en',
      );
      expect(
        () => placesService.textSearch(
            textQuery: 'test query',
            location: location,
            includedType: null,
            options: options),
        throwsException,
      );
    });
  });
}
