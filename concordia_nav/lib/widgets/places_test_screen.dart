import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../data/services/places_service.dart';
import '../utils/map_viewmodel.dart';

// TODO: Remove this. Just for testing purposes.
class PlacesTestScreen extends StatefulWidget {
  const PlacesTestScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PlacesTestScreenState createState() => _PlacesTestScreenState();
}

class _PlacesTestScreenState extends State<PlacesTestScreen> {
  final MapViewModel _mapViewModel = MapViewModel();
  String _resultText = "Press a button to search for places";
  bool _isLoading = false;

  Future<void> _searchNearbyPlaces(PlaceType category) async {
    setState(() {
      _isLoading = true;
      _resultText = "Searching for ${category.displayName}...";
    });

    try {
      final places = await _mapViewModel.searchNearbyPlaces(category);

      // Convert places to JSON
      final placesJson = places.map((place) => place.toJson()).toList();

      final prettyJson = const JsonEncoder.withIndent('  ').convert(placesJson);

      setState(() {
        _resultText = prettyJson;
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Text(_resultText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
