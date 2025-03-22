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

  // Disposal state tracking
  bool _disposed = false;

  // Search parameters
  String? _globalSearchQuery;
  String get globalSearchQuery => _globalSearchQuery ?? '';
  
  // Current location - marked nullable since it might not be available
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;
  
  // Location status
  bool _hasLocationPermission = false;
  bool get hasLocationPermission => _hasLocationPermission;
  String _locationErrorMessage = '';
  String get locationErrorMessage => _locationErrorMessage;

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
  double _searchRadius = 1000; // Default 1km
  TravelMode _travelMode = TravelMode.DRIVE;
  TravelMode get travelMode => _travelMode;
  
  // Outdoor POI getters
  List<Place> get outdoorPOIs => _outdoorPOIs;
  List<Place> get filteredOutdoorPOIs => _filteredOutdoorPOIs;
  bool get isLoadingOutdoor => _isLoadingOutdoor;
  String get errorOutdoor => _errorOutdoor;
  PlaceType? get selectedOutdoorCategory => _selectedOutdoorCategory;
  double get searchRadius => _searchRadius;
  
  // Modified notifyListeners to check disposal state
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
  
  // Override dispose to mark as disposed
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  // ====== INITIALIZATION ======
  
  Future<void> init() async {
    await _initCurrentLocation();
    // Only load POIs if we have location permission
    if (_hasLocationPermission && !_disposed) {
      await loadIndoorPOIs();
      await loadOutdoorPOIs(_selectedOutdoorCategory);
    }
  }
  
  Future<void> _initCurrentLocation() async {
    if (_disposed) return;
    
    try {
      final locationServiceEnabled = await _mapService.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        _hasLocationPermission = false;
        _locationErrorMessage = 'Location services are disabled';
        _currentLocation = null;
        notifyListeners();
        return;
      }
      
      final hasPermission = await _mapService.checkAndRequestLocationPermission();
      if (!hasPermission) {
        _hasLocationPermission = false;
        _locationErrorMessage = 'Location permission denied';
        _currentLocation = null;
        notifyListeners();
        return;
      }
      
      final location = await _mapService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        _hasLocationPermission = true;
        _locationErrorMessage = '';
      } else {
        _currentLocation = null;
        _hasLocationPermission = false;
        _locationErrorMessage = 'Unable to get current location';
      }
    } catch (e, stackTrace) {
      dev.log('Error getting current location', error: e, stackTrace: stackTrace);
      _currentLocation = null;
      _hasLocationPermission = false;
      _locationErrorMessage = e.toString();
    }
    notifyListeners();
  }
  
  // ====== INDOOR POI METHODS ======
  
  Future<void> loadIndoorPOIs() async {
    if (_disposed) return;
    
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
    if (_disposed) return;
    
    _globalSearchQuery = query;
    notifyListeners();
    
    // Handle outdoor search
    if (_hasLocationPermission) {
      if (query.length > 2) {
        searchOutdoorPOIs(query);
      } else if (query.isEmpty) {
        loadOutdoorPOIs(_selectedOutdoorCategory);
      } else {
        _applyOutdoorFilters();
      }
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
  
  // Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    return _mapService.calculateDistance(point1, point2);
  }
  
  // Update a place with calculated distance
  void updatePlaceWithDistance(int index, Place updatedPlace) {
    if (_disposed) return;
    
    if (index >= 0 && index < _outdoorPOIs.length) {
      _outdoorPOIs[index] = updatedPlace;
      _applyOutdoorFilters();
    }
  }
  
  // ====== OUTDOOR POI METHODS ======

  Future<void> setTravelMode(TravelMode mode) async {
    if (_disposed) return;
    
    if (_travelMode != mode) {
      _travelMode = mode;
      _isLoadingOutdoor = true;
      notifyListeners();
      
      // Reload outdoor POIs with new travel mode if we have permission
      if (_hasLocationPermission && _currentLocation != null) {
        await loadOutdoorPOIs(_selectedOutdoorCategory);
      }
    }
  }
  
  Future<void> setSearchRadius(double radius) async {
    if (_disposed) return;
    
    if (_searchRadius != radius) {
      _searchRadius = radius;
      notifyListeners();

      if (_hasLocationPermission && _selectedOutdoorCategory != null) {
        await loadOutdoorPOIs(_selectedOutdoorCategory);
      }
    }
  }

  Future<void> loadOutdoorPOIs(PlaceType? category) async {
    if (_disposed) return;
    
    if (!_hasLocationPermission || _currentLocation == null) {
      _errorOutdoor = _locationErrorMessage.isEmpty ? 'Location permission required' : _locationErrorMessage;
      _outdoorPOIs = [];
      _filteredOutdoorPOIs = [];
      notifyListeners();
      return;
    }
    
    _isLoadingOutdoor = true;
    _errorOutdoor = '';
    _selectedOutdoorCategory = category;
    notifyListeners();

    try {
      // Create routing options with the current travel mode
      final routingOptions = PlacesRoutingOptions(
        travelMode: _travelMode,
      );

      final places = await _placesService.nearbySearch(
        location: _currentLocation!,
        includedType: category,
        radius: _searchRadius,
        maxResultCount: 20,
        routingOptions: routingOptions,
      );

      _outdoorPOIs = places;
      _applyOutdoorFilters();
    } catch (e) {
      _errorOutdoor = e.toString();
      _outdoorPOIs = [];
      _filteredOutdoorPOIs = [];
    } finally {
      _isLoadingOutdoor = false;
      notifyListeners();
    }
  }
  
  Future<void> searchOutdoorPOIs(String query) async {
    if (_disposed) return;
    
    if (query.trim().isEmpty || !_hasLocationPermission || _currentLocation == null) return;
    
    _isLoadingOutdoor = true;
    _errorOutdoor = '';
    notifyListeners();
    
    try {
      // Create routing options with the current travel mode
      final routingOptions = PlacesRoutingOptions(
        travelMode: _travelMode,
      );
      
      final places = await _placesService.textSearch(
        textQuery: query,
        location: _currentLocation!,
        includedType: _selectedOutdoorCategory,
        radius: _searchRadius,
        pageSize: 20,
        openNow: false,
        routingOptions: routingOptions,
      );
      
      _outdoorPOIs = places;
      _applyOutdoorFilters();
    } catch (e) {
      _errorOutdoor = e.toString();
      _outdoorPOIs = [];
      _filteredOutdoorPOIs = [];
    } finally {
      _isLoadingOutdoor = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    if (_disposed) return;
    
    try {
      final locationServiceEnabled = await _mapService.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        _hasLocationPermission = false;
        _locationErrorMessage = 'Location services are disabled';
        _currentLocation = null;
        notifyListeners();
        return;
      }
      
      final hasPermission = await _mapService.checkAndRequestLocationPermission();
      if (!hasPermission) {
        _hasLocationPermission = false;
        _locationErrorMessage = 'Location permission denied';
        _currentLocation = null;
        notifyListeners();
        return;
      }
      
      final location = await _mapService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        _hasLocationPermission = true;
        _locationErrorMessage = '';
        await loadOutdoorPOIs(_selectedOutdoorCategory);
      } else {
        _currentLocation = null;
        _hasLocationPermission = false;
        _locationErrorMessage = 'Unable to get current location';
      }
    } catch (e, stackTrace) {
      dev.log('Error refreshing location', error: e, stackTrace: stackTrace);
      _hasLocationPermission = false;
      _locationErrorMessage = 'Failed to get current location';
      _errorOutdoor = _locationErrorMessage;
    }
    notifyListeners();
  }
  
  void setOutdoorCategory(PlaceType? category, bool selected) {
    if (_disposed) return;
    
    _selectedOutdoorCategory = selected ? category : null;
    if (_hasLocationPermission) {
      loadOutdoorPOIs(_selectedOutdoorCategory);
    }
  }
  
  void _applyOutdoorFilters() {
    if (_disposed) return;
    
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