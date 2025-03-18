// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../data/repositories/building_data_manager.dart';
import '../../data/domain-model/poi.dart';

class POIChoiceViewModel extends ChangeNotifier {
  
  List<POI> _allPOIs = [];
  List<POI> _filteredPOIs = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  String? _selectedBuilding;
  String? _selectedFloor;
  POICategory? _selectedCategory;
  
  // Getters
  List<POI> get filteredPOIs => _filteredPOIs;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedBuilding => _selectedBuilding;
  String? get selectedFloor => _selectedFloor;
  POICategory? get selectedCategory => _selectedCategory;
  
  // Get unique buildings from POIs
  List<String> get buildings {
    return _allPOIs.map((poi) => poi.buildingId).toSet().toList()..sort();
  }
  
  // Get unique floors from selected building
  List<String> get floors {
    if (_selectedBuilding == null) return [];
    return _allPOIs
        .where((poi) => poi.buildingId == _selectedBuilding)
        .map((poi) => poi.floor)
        .toSet()
        .toList()
        ..sort();
  }
  
  // Get unique POI categories
  List<POICategory> get poiCategories {
    if (_selectedBuilding == null) return [];
    var pois = _allPOIs.where((poi) => poi.buildingId == _selectedBuilding);
    if (_selectedFloor != null) {
      pois = pois.where((poi) => poi.floor == _selectedFloor);
    }
    return pois.map((poi) => poi.category).toSet().toList();
  }
  
  // Initialize and load all POIs
  Future<void> loadPOIs() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _allPOIs = await BuildingDataManager.getAllPOIs();
      _applyFilters();
    } catch (e, stackTrace) {
      _error = 'Failed to load POIs';
      dev.log('Error loading POIs', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  // Set selected building
  void setSelectedBuilding(String? buildingId) {
    _selectedBuilding = buildingId;
    _selectedFloor = null; // Reset floor when building changes
    _selectedCategory = null; // Reset category when building changes
    _applyFilters();
  }
  
  // Set selected floor
  void setSelectedFloor(String? floor) {
    _selectedFloor = floor;
    _applyFilters();
  }
  
  // Set selected POI category
  void setSelectedCategory(POICategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }
  
  // Apply all filters
  void _applyFilters() {
    _filteredPOIs = _allPOIs;
    
    // Filter by building
    if (_selectedBuilding != null) {
      _filteredPOIs = _filteredPOIs
          .where((poi) => poi.buildingId == _selectedBuilding)
          .toList();
    }
    
    // Filter by floor
    if (_selectedFloor != null) {
      _filteredPOIs = _filteredPOIs
          .where((poi) => poi.floor == _selectedFloor)
          .toList();
    }
    
    // Filter by category
    if (_selectedCategory != null) {
      _filteredPOIs = _filteredPOIs
          .where((poi) => poi.category == _selectedCategory)
          .toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredPOIs = _filteredPOIs
          .where((poi) => poi.name.toLowerCase().contains(query))
          .toList();
    }
    
    // Sort by name
    _filteredPOIs.sort((a, b) => a.name.compareTo(b.name));
    
    notifyListeners();
  }
  
  // Reset all filters
  void resetFilters() {
    _searchQuery = '';
    _selectedBuilding = null;
    _selectedFloor = null;
    _selectedCategory = null;
    _applyFilters();
  }
  
  // Get display name for POI category
  String getDisplayNameForCategory(POICategory category) {
    switch (category) {
      case POICategory.washroom:
        return 'Washroom';
      case POICategory.waterFountain:
        return 'Water Fountain';
      case POICategory.restaurant:
        return 'Restaurant';
      case POICategory.elevator:
        return 'Elevator';
      case POICategory.escalator:
        return 'Escalator';
      case POICategory.stairs:
        return 'Stairs';
      case POICategory.exit:
        return 'Exit';
      default:
        return 'Other';
    }
  }

  // Get unique POI names
  List<String> get uniquePOINames {
    if (_selectedBuilding == null) return [];

    // Start with POIs from the selected building
    var pois = _allPOIs.where((poi) => poi.buildingId == _selectedBuilding);

    // Apply floor filter if selected
    if (_selectedFloor != null) {
      pois = pois.where((poi) => poi.floor == _selectedFloor);
    }

    // Apply category filter if selected
    if (_selectedCategory != null) {
      pois = pois.where((poi) => poi.category == _selectedCategory);
    }

    // Get unique names and sort them
    return pois.map((poi) => poi.name).toSet().toList()..sort();
  }

  // Select POIs by name
  List<POI> getPOIsByName(String name) {
    return _filteredPOIs.where((poi) => poi.name == name).toList();
  }

  // Get unique POI names from filtered POIs
  List<String> get uniqueFilteredPOINames {
    return _filteredPOIs.map((poi) => poi.name).toSet().toList()..sort();
  }

  // New method to get count of POIs with the same name
  int getCountForPOIName(String name) {
    return _filteredPOIs.where((poi) => poi.name == name).length;
  }
}