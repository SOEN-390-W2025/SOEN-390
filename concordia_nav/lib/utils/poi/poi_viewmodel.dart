// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as dev;
import '../../data/repositories/building_data_manager.dart';
import '../../data/domain-model/poi.dart';
import '../../data/services/places_service.dart';
import '../../data/domain-model/place.dart';
import '../../data/services/map_service.dart';

class POIViewModel extends ChangeNotifier {
  // Services
  final MapService _mapService = MapService();
  final PlacesService _placesService = PlacesService();

  // Search parameters
  String? _globalSearchQuery;
  String get globalSearchQuery => _globalSearchQuery ?? '';
  
  // Current location
  LatLng _currentLocation = const LatLng(45.447294, -73.6011365);
  LatLng get currentLocation => _currentLocation;

  // Indoor POI state
  List<POI> _allPOIs = [];
  bool _isLoadingIndoor = true;
  String _errorIndoor = '';
  
  // Indoor POI getters
  List<POI> get allPOIs => _allPOIs;
  bool get isLoadingIndoor => _isLoadingIndoor;
  String get errorIndoor => _errorIndoor;
  
  // Outdoor POI state
  List<Place> _outdoorPOIs = [];
  List<Place> _filteredOutdoorPOIs = [];
  bool _isLoadingOutdoor = false;
  String _errorOutdoor = '';
  PlaceType? _selectedOutdoorCategory = PlaceType.foodDrink;
  double _searchRadius = 1000; // Default 3km
  
  // Outdoor POI getters
  List<Place> get outdoorPOIs => _outdoorPOIs;
  List<Place> get filteredOutdoorPOIs => _filteredOutdoorPOIs;
  bool get isLoadingOutdoor => _isLoadingOutdoor;
  String get errorOutdoor => _errorOutdoor;
  PlaceType? get selectedOutdoorCategory => _selectedOutdoorCategory;
  double get searchRadius => _searchRadius;
  
  // ====== INITIALIZATION ======
  
  Future<void> init() async {
    await _initCurrentLocation();
    await loadIndoorPOIs();
    await loadOutdoorPOIs(_selectedOutdoorCategory);
  }
  
  Future<void> _initCurrentLocation() async {
    try {
      final location = await _mapService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
      }
    } catch (e, stackTrace) {
      dev.log('Error getting current location, using default', error: e, stackTrace: stackTrace);
      // Keep using the default location if there's an error
    }
  }
  
  // ====== INDOOR POI METHODS ======
  
  Future<void> loadIndoorPOIs() async {
    _isLoadingIndoor = true;
    _errorIndoor = '';
    notifyListeners();
    
    try {
      _allPOIs = await BuildingDataManager.getAllPOIs();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorIndoor = 'Failed to load indoor POIs';
      dev.log('Error loading indoor POIs', error: e, stackTrace: stackTrace);
    } finally {
      _isLoadingIndoor = false;
      notifyListeners();
    }
  }
  
  void setGlobalSearchQuery(String query) {
    _globalSearchQuery = query;
    notifyListeners();
    
    // Handle outdoor search
    if (query.length > 2) {
      searchOutdoorPOIs(query);
    } else if (query.isEmpty) {
      loadOutdoorPOIs(_selectedOutdoorCategory);
    } else {
      _applyOutdoorFilters();
    }
  }
  
  // Filter POIs based on global search query
  List<POI> filterPOIsWithGlobalSearch() {
    if (_globalSearchQuery == null || _globalSearchQuery!.isEmpty) {
      return _allPOIs;
    }
    
    final query = _globalSearchQuery!.toLowerCase();
    return _allPOIs
      .where((poi) => poi.name.toLowerCase().contains(query))
      .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
  
  // Get unique POI names from a filtered list of POIs
  List<String> getUniqueFilteredPOINames(List<POI> pois) {
    return pois
      .map((poi) => poi.name)
      .toSet()
      .toList()
      ..sort();
  }
  
  // ====== INDOOR POI HELPERS ======
  
  IconData getIconForPOICategory(POICategory category) {
    switch (category) {
      case POICategory.washroom: return Icons.wc;
      case POICategory.waterFountain: return Icons.water_drop;
      case POICategory.restaurant: return Icons.restaurant;
      case POICategory.police: return Icons.local_police;
      case POICategory.elevator: return Icons.elevator;
      case POICategory.escalator: return Icons.escalator;
      case POICategory.stairs: return Icons.stairs;
      case POICategory.exit: return Icons.exit_to_app;
      default: return Icons.location_on;
    }
  }
  
  // ====== OUTDOOR POI METHODS ======
  
  Future<void> setSearchRadius(double radius) async {
    if (_searchRadius != radius) {
      _searchRadius = radius;
      notifyListeners();

      if (_selectedOutdoorCategory != null) {
        await loadOutdoorPOIs(_selectedOutdoorCategory);
      }
    }
  }

  Future<void> loadOutdoorPOIs(PlaceType? category) async {
    _isLoadingOutdoor = true;
    _errorOutdoor = '';
    _selectedOutdoorCategory = category;
    notifyListeners();

    try {
      final places = await _placesService.nearbySearch(
        location: _currentLocation,
        includedType: category,
        radius: _searchRadius,
        maxResultCount: 20,
      );

      _outdoorPOIs = places;
      print(places);
      _applyOutdoorFilters();
    } catch (e) {
      _errorOutdoor = e.toString();
      print(_errorOutdoor);
    } finally {
      _isLoadingOutdoor = false;
      notifyListeners();
    }
  }
  
  Future<void> searchOutdoorPOIs(String query) async {
    if (query.trim().isEmpty) return;
    
    _isLoadingOutdoor = true;
    _errorOutdoor = '';
    notifyListeners();
    
    try {
      final places = await _placesService.textSearch(
        textQuery: query,
        location: _currentLocation,
        includedType: _selectedOutdoorCategory,
        radius: _searchRadius,
        pageSize: 20,
        openNow: false,
      );
      
      _outdoorPOIs = places;
      _applyOutdoorFilters();
    } catch (e) {
      _errorOutdoor = e.toString();
    } finally {
      _isLoadingOutdoor = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    try {
      final location = await _mapService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        await loadOutdoorPOIs(_selectedOutdoorCategory);
      }
    } catch (e, stackTrace) {
      dev.log('Error refreshing location', error: e, stackTrace: stackTrace);
      _errorOutdoor = 'Failed to get current location';
      notifyListeners();
    }
  }
  
  void setOutdoorCategory(PlaceType? category, bool selected) {
    _selectedOutdoorCategory = selected ? category : null;
    loadOutdoorPOIs(_selectedOutdoorCategory);
  }
  
  void _applyOutdoorFilters() {
    if (_globalSearchQuery == null || _globalSearchQuery!.isEmpty) {
      _filteredOutdoorPOIs = _outdoorPOIs;
    } else {
      final query = _globalSearchQuery!.toLowerCase();
      _filteredOutdoorPOIs = _outdoorPOIs
          .where((place) => place.name.toLowerCase().contains(query))
          .toList();
    }
    
    notifyListeners();
  }
}