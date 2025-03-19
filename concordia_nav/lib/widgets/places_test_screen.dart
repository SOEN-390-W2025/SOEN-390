import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/services/places_service.dart';
import '../data/domain-model/place.dart';

// TODO: Remove this. Just for testing purposes.
class PlacesTestScreen extends StatefulWidget {
  const PlacesTestScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PlacesTestScreenState createState() => _PlacesTestScreenState();
}

class _PlacesTestScreenState extends State<PlacesTestScreen> {
  final PlacesService _placesService = PlacesService();
  String _resultText = "Press a button to search for places";
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  PlaceType? _selectedType = PlaceType.foodDrink;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPlacesList(List<Place> places) {
    final buffer = StringBuffer();

    buffer.writeln("Found ${places.length} places:");
    buffer.writeln();

    for (int i = 0; i < places.length; i++) {
      final place = places[i];
      buffer.writeln("${i + 1}. ${place.name}");
      if (place.address != null && place.address!.isNotEmpty) {
        buffer.writeln("   ${place.address}");
      }
      if (place.rating != null) {
        buffer.writeln("   Rating: ${place.rating} ⭐");
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<void> _searchNearbyPlaces(PlaceType category) async {
    setState(() {
      _isLoading = true;
      _resultText = "Searching for ${category.displayName}...";
    });

    try {
      final places = await _placesService.nearbySearch(
        location: const LatLng(45.447294, -73.6011365),
        includedType: category,
      );
      // Format place names list
      final placesList = _formatPlacesList(places);

      // Convert places to JSON
      final placesJson = places.map((place) => place.toJson()).toList();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(placesJson);

      setState(() {
        _resultText =
            "Nearby Search Results:\n\n$placesList\n------- JSON Data -------\n\n$prettyJson";
      });

      // Also log to console for debugging
      dev.log('Found ${places.length} places of type ${category.displayName}');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      setState(() {
        _resultText = "Error: ${e.toString()}";
      });
      dev.log('Error searching places', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _textSearchNearbyPlaces(
      String query, PlaceType? category) async {
    if (query.trim().isEmpty) {
      setState(() {
        _resultText = "Please enter a search query";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultText =
          "Text searching for '$query'${category != null ? " in ${category.displayName}..." : " in all categories..."}";
    });

    try {
      final places = await _placesService.textSearch(
          textQuery: query,
          location: const LatLng(45.447294, -73.6011365),
          includedType: category,
          openNow: false);

      // Format place names list
      final placesList = _formatPlacesList(places);

      // Convert places to JSON
      final placesJson = places.map((place) => place.toJson()).toList();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(placesJson);

      final categoryName =
          category != null ? category.displayName : "All Categories";

      setState(() {
        _resultText =
            "Text Search Results for '$query' in $categoryName:\n\n$placesList\n------- JSON Data -------\n\n$prettyJson";
      });

      // Also log to console for debugging
      dev.log(
          'Found ${places.length} places for query: "$query"${category != null ? " of type ${category.displayName}" : " with no type filter"}');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      setState(() {
        _resultText = "Error: ${e.toString()}";
      });
      dev.log('Error performing text search', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text Search Section
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text Search',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search Query',
                              hintText: 'e.g., coffee shops near Concordia',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<PlaceType?>(
                          value: _selectedType,
                          items: [
                            const DropdownMenuItem<PlaceType?>(
                              value: null,
                              child: Text('Any Category'),
                            ),
                            ...PlaceType.values.map((PlaceType type) {
                              return DropdownMenuItem<PlaceType>(
                                value: type,
                                child: Text(type.displayName),
                              );
                            }),
                          ],
                          onChanged: (PlaceType? newValue) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _textSearchNearbyPlaces(
                                _searchController.text,
                                _selectedType,
                              ),
                      icon: const Icon(Icons.search),
                      label: const Text('Text Search'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nearby Search Section
            const Text(
              'Nearby Search',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _searchNearbyPlaces(PlaceType.healthCenter),
                  child: const Text('Health Centers'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _searchNearbyPlaces(PlaceType.foodDrink),
                  child: const Text('Food & Drink'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _searchNearbyPlaces(PlaceType.coffeeShop),
                  child: const Text('Coffee Shops'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _searchNearbyPlaces(PlaceType.studyPlace),
                  child: const Text('Study Places'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _searchNearbyPlaces(PlaceType.gym),
                  child: const Text('Gyms'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _searchNearbyPlaces(PlaceType.grocery),
                  child: const Text('Grocery Stores'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Results Section
            Expanded(
              child: Card(
                elevation: 4.0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Text(_resultText),
                      ),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
