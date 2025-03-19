import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/services/places_service.dart';
import '../data/domain-model/place.dart';
import '../utils/logger_util.dart';

class PlacesTestScreen extends StatefulWidget {
  const PlacesTestScreen({super.key});

  @override
  PlacesTestScreenState createState() => PlacesTestScreenState();
}

class PlacesTestScreenState extends State<PlacesTestScreen> {
  final PlacesService _placesService = PlacesService();
  String _resultText = "Press a button to search for places";
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  PlaceType? _selectedType;

  // Track if search panel is expanded
  bool _isSearchPanelExpanded = true;

  // Routing options
  TravelMode? _selectedTravelMode;
  final Map<String, bool> _routeModifiers = {
    'avoidTolls': false,
    'avoidHighways': false,
    'avoidFerries': false,
    'avoidIndoor': false,
  };

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

      // Add routing information when available
      if (place.distanceMeters != null || place.durationSeconds != null) {
        buffer.writeln("   ----- Routing Info -----");

        if (place.distanceMeters != null) {
          buffer.writeln("   Distance: ${place.formattedDistance}");
        }

        if (place.durationSeconds != null) {
          buffer.writeln("   Duration: ${place.formattedDuration}");
        }

        if (place.travelMode != null) {
          buffer.writeln(
              "   Travel Mode: ${place.travelMode.toString().split('.').last}");
        }
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<void> _searchNearbyPlaces(PlaceType? category) async {
    setState(() {
      _isLoading = true;
      _resultText =
          "Searching for ${category?.displayName ?? "All Categories"}...";
    });

    try {
      // Create routing options if travel mode is selected
      PlacesRoutingOptions? routingOptions;
      if (_selectedTravelMode != null) {
        routingOptions = PlacesRoutingOptions(
          travelMode: _selectedTravelMode,
          routeModifiers: RouteModifiers(
            avoidTolls: _routeModifiers['avoidTolls'],
            avoidHighways: _routeModifiers['avoidHighways'],
            avoidFerries: _routeModifiers['avoidFerries'],
            avoidIndoor: _routeModifiers['avoidIndoor'],
          ),
        );
      }

      final places = await _placesService.nearbySearch(
        location: const LatLng(45.447294, -73.6011365),
        includedType: category,
        routingOptions: routingOptions,
      );

      // Format place names list
      final placesList = _formatPlacesList(places);

      // Convert places to JSON
      final placesJson = places.map((place) => place.toJson()).toList();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(placesJson);

      setState(() {
        _resultText =
            "Nearby Search Results:\n\n$placesList\n------- JSON Data -------\n\n$prettyJson";
        // Auto-collapse search panel when results are shown
        // _isSearchPanelExpanded = false;
      });

      // Also log to console for debugging
      LoggerUtil.info(
          'Found ${places.length} places of type ${category?.displayName ?? "All Categories"}');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      setState(() {
        _resultText = "Error: ${e.toString()}";
      });
      LoggerUtil.error('Error searching places', e);
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
      // Create routing options if travel mode is selected
      PlacesRoutingOptions? routingOptions;
      if (_selectedTravelMode != null) {
        routingOptions = PlacesRoutingOptions(
          travelMode: _selectedTravelMode,
          routeModifiers: RouteModifiers(
            avoidTolls: _routeModifiers['avoidTolls'],
            avoidHighways: _routeModifiers['avoidHighways'],
            avoidFerries: _routeModifiers['avoidFerries'],
            avoidIndoor: _routeModifiers['avoidIndoor'],
          ),
        );
      }

      final places = await _placesService.textSearch(
          textQuery: query,
          location: const LatLng(45.447294, -73.6011365),
          includedType: category,
          openNow: false,
          routingOptions: routingOptions);

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
        // Auto-collapse search panel when results are shown
        // _isSearchPanelExpanded = false;
      });

      // Also log to console for debugging
      LoggerUtil.info(
          'Found ${places.length} places for query: "$query"${category != null ? " of type ${category.displayName}" : " with no type filter"}');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      setState(() {
        _resultText = "Error: ${e.toString()}";
      });
      LoggerUtil.error('Error performing text search', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRoutingOptionsPanel() {
    return ExpansionTile(
      title: const Text('Routing Options',
          style: TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: _selectedTravelMode != null,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Travel Mode dropdown
              DropdownButtonFormField<TravelMode>(
                decoration: const InputDecoration(
                  labelText: 'Travel Mode',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTravelMode,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None (No routing)'),
                  ),
                  ...TravelMode.values.map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode.toString().split('.').last),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTravelMode = value;
                  });
                },
              ),

              if (_selectedTravelMode != null) ...[
                const SizedBox(height: 16),

                // Route modifiers - more compact layout
                const Text(
                  'Route Modifiers',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Avoid Tolls'),
                      selected: _routeModifiers['avoidTolls'] ?? false,
                      onSelected: (value) {
                        setState(() {
                          _routeModifiers['avoidTolls'] = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Avoid Highways'),
                      selected: _routeModifiers['avoidHighways'] ?? false,
                      onSelected: (value) {
                        setState(() {
                          _routeModifiers['avoidHighways'] = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Avoid Ferries'),
                      selected: _routeModifiers['avoidFerries'] ?? false,
                      onSelected: (value) {
                        setState(() {
                          _routeModifiers['avoidFerries'] = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Avoid Indoor'),
                      selected: _routeModifiers['avoidIndoor'] ?? false,
                      onSelected: (value) {
                        setState(() {
                          _routeModifiers['avoidIndoor'] = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places API Test'),
        actions: [
          IconButton(
            icon: Icon(
                _isSearchPanelExpanded ? Icons.unfold_less : Icons.unfold_more),
            tooltip:
                _isSearchPanelExpanded ? 'Collapse Options' : 'Expand Options',
            onPressed: () {
              setState(() {
                _isSearchPanelExpanded = !_isSearchPanelExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible search panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchPanelExpanded ? null : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Query',
                        hintText: 'Enter search text...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Categories dropdown
                    DropdownButtonFormField<PlaceType?>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...PlaceType.values.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),

                    // Routing options panel
                    _buildRoutingOptionsPanel(),
                  ],
                ),
              ),
            ),
          ),

          // Search controls
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _searchNearbyPlaces(_selectedType),
                    child: const Text('Nearby Search'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _textSearchNearbyPlaces(
                            _searchController.text, _selectedType),
                    child: const Text('Text Search'),
                  ),
                ),
              ],
            ),
          ),

          // Results area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Text(_resultText),
                    ),
                  ),
          ),
        ],
      ),
      // Add floating action button to toggle panel
      floatingActionButton: !_isSearchPanelExpanded
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSearchPanelExpanded = true;
                });
              },
              tooltip: 'Show Search Options',
              child: const Icon(Icons.search),
            )
          : null,
    );
  }
}
