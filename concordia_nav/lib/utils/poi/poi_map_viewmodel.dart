// poi_map_viewmodel.dart
// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/poi.dart';
import '../../data/services/indoor_routing_service.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../data/repositories/building_data_manager.dart';
import 'package:geolocator/geolocator.dart';

class POIMapViewModel extends ChangeNotifier {
  // Dependencies
  final BuildingViewModel _buildingViewModel;
  final IndoorDirectionsViewModel _indoorDirectionsViewModel;
  final IndoorMapViewModel _indoorMapViewModel;

  // State
  List<POI> _allPOIs = []; // All POIs from the data manager
  List<POI> _matchingPOIs = []; // POIs matching specific criteria (e.g., name)
  List<POI> _poisOnCurrentFloor = []; // POIs for current building and floor
  ConcordiaBuilding? _nearestBuilding;
  String _selectedFloor = '1';
  bool _isLoading = true;
  String _errorMessage = '';
  bool _floorPlanExists = true;
  String _floorPlanPath = '';
  double _width = 1024.0;
  double _height = 1024.0;
  bool _noPoisOnCurrentFloor = false;
  double _searchRadius = 50.0;
  Offset? _userPosition;
  // ignore: prefer_final_fields
  String _poiName = '';
  bool _disposed = false;
  bool _isLoadingAllPOIs = false;

  // Getters
  List<POI> get allPOIs => _allPOIs;
  List<POI> get matchingPOIs => _matchingPOIs;
  List<POI> get poisOnCurrentFloor => _poisOnCurrentFloor;
  ConcordiaBuilding? get nearestBuilding => _nearestBuilding;
  String get selectedFloor => _selectedFloor;
  bool get isLoading => _isLoading;
  bool get isLoadingAllPOIs => _isLoadingAllPOIs;
  String get errorMessage => _errorMessage;
  bool get floorPlanExists => _floorPlanExists;
  String get floorPlanPath => _floorPlanPath;
  double get width => _width;
  double get height => _height;
  bool get noPoisOnCurrentFloor => _noPoisOnCurrentFloor;
  double get searchRadius => _searchRadius;
  Offset? get userPosition => _userPosition;

  // Constructor
  POIMapViewModel({
    required String poiName,
    required BuildingViewModel buildingViewModel,
    required IndoorDirectionsViewModel indoorDirectionsViewModel,
    required IndoorMapViewModel indoorMapViewModel,
  })  : _poiName = poiName,
        _buildingViewModel = buildingViewModel,
        _indoorDirectionsViewModel = indoorDirectionsViewModel,
        _indoorMapViewModel = indoorMapViewModel {
    // Load all POIs during initialization
    _loadAllPOIs();
  }

  // Constructor for using as a general POI service without a specific POI name
  POIMapViewModel.asService({
    required BuildingViewModel buildingViewModel,
    required IndoorDirectionsViewModel indoorDirectionsViewModel,
    required IndoorMapViewModel indoorMapViewModel,
  })  : _poiName = '',
        _buildingViewModel = buildingViewModel,
        _indoorDirectionsViewModel = indoorDirectionsViewModel,
        _indoorMapViewModel = indoorMapViewModel {
    // Load all POIs during initialization
    _loadAllPOIs();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Modified notifyListeners to check disposal state
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // Load all POIs from the data manager
  Future<void> _loadAllPOIs() async {
    if (_disposed) return;

    _isLoadingAllPOIs = true;
    notifyListeners();

    try {
      _allPOIs = await BuildingDataManager.getAllPOIs();
      dev.log('Loaded ${_allPOIs.length} POIs in POIMapViewModel');
    } catch (e) {
      dev.log('Error loading POIs in POIMapViewModel: $e');
      _allPOIs = [];
    } finally {
      _isLoadingAllPOIs = false;
      notifyListeners();
    }
  }

  // Get all POIs for a specific building and floor - can be used by other views
  Future<List<POI>> getPOIsForBuildingAndFloor(
      String buildingId, String floor) async {
    // If POIs haven't been loaded yet, wait for them to load
    if (_allPOIs.isEmpty && !_isLoadingAllPOIs) {
      await _loadAllPOIs();
    }

    // Wait for loading to complete if it's currently in progress
    while (_isLoadingAllPOIs) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Filter POIs for the specified building and floor
    final poisForBuildingAndFloor = _allPOIs
        .where((poi) => poi.buildingId == buildingId && poi.floor == floor)
        .toList();

    dev.log(
        'Found ${poisForBuildingAndFloor.length} POIs for $buildingId floor $floor');

    return poisForBuildingAndFloor;
  }

  // Load POI data for a specific POI name, optionally with initial building and floor
  Future<void> loadPOIData(
      {String? initialBuilding, String? initialFloor}) async {
    _setLoading(true);
    _clearError();

    try {
      // Wait for all POIs to load if they're still loading
      while (_isLoadingAllPOIs) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Filter all POIs with this name
      _matchingPOIs = _allPOIs.where((poi) => poi.name == _poiName).toList();

      if (_matchingPOIs.isEmpty) {
        _setError('No POIs found with name: $_poiName');
        return;
      }

      // If initialBuilding is provided, use it instead of finding nearest building
      if (initialBuilding != null) {
        await _useInitialBuildingAndFloor(initialBuilding, initialFloor);
        return;
      }

      // Otherwise use geolocation to find nearest building
      final location = await IndoorRoutingService.getRoundedGeolocation();

      if (location == null) {
        _setError(
            'Could not determine your location. Please check location permissions.');
        return;
      }

      // If location is already a building (user is inside or very close)
      if (location is ConcordiaBuilding) {
        _nearestBuilding = location;
        await _processNearestBuilding(initialFloor);
        return;
      }

      // Otherwise find the nearest building that contains the POI
      await findNearestBuildingWithPOI(
          location.lat, location.lng, initialFloor);
    } catch (e, stackTrace) {
      dev.log('Error loading POI data', error: e, stackTrace: stackTrace);
      _setError('Failed to load POI data: ${e.toString()}');
    }
  }

  Future<void> _useInitialBuildingAndFloor(
      String initialBuilding, String? initialFloor) async {
    // Get building by abbreviation
    _nearestBuilding = _buildingViewModel.getBuildingByName(initialBuilding);

    if (_nearestBuilding == null) {
      _setError('Building $initialBuilding not found.');
      return;
    }

    // Set the floor (use provided floor or default to '1')
    _selectedFloor = initialFloor ?? '1';

    // Set floor plan path
    _updateFloorPlanPath();

    // Check if there are POIs of the requested type in this building
    final poisInBuilding = _matchingPOIs
        .where((poi) => poi.buildingId == _nearestBuilding!.abbreviation)
        .toList();

    if (poisInBuilding.isEmpty) {
      _setError('No $_poiName found in ${_nearestBuilding!.name}.');
      return;
    }

    // Update POIs on the current floor and check if floor plan exists
    await _updatePOIsOnCurrentFloor();
    await _checkIfFloorPlanExists();
  }

  Future<void> findNearestBuildingWithPOI(
      double userLat, double userLng, String? initialFloor) async {
    // Group POIs by building
    final Map<String, List<POI>> poisByBuilding = {};
    for (final poi in _matchingPOIs) {
      if (!poisByBuilding.containsKey(poi.buildingId)) {
        poisByBuilding[poi.buildingId] = [];
      }
      poisByBuilding[poi.buildingId]!.add(poi);
    }

    double nearestDistance = double.infinity;
    String? nearestBuildingId;

    // Find nearest building that has the POI
    for (final buildingId in poisByBuilding.keys) {
      final building = _buildingViewModel.getBuildingByAbbreviation(buildingId);
      if (building != null) {
        final distance = Geolocator.distanceBetween(
            userLat, userLng, building.lat, building.lng);

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestBuildingId = buildingId;
        }
      }
    }

    if (nearestBuildingId != null) {
      _nearestBuilding =
          _buildingViewModel.getBuildingByAbbreviation(nearestBuildingId);
      await _processNearestBuilding(initialFloor);
    } else {
      _setError('Could not find any building with $_poiName nearby.');
    }
  }

  Future<void> _processNearestBuilding(String? initialFloor) async {
    if (_nearestBuilding == null) {
      _setError('Could not determine nearest building.');
      return;
    }

    // Find POIs in this building
    final poisInBuilding = _matchingPOIs
        .where((poi) => poi.buildingId == _nearestBuilding!.abbreviation)
        .toList();

    if (poisInBuilding.isEmpty) {
      _setError('No $_poiName found in ${_nearestBuilding!.name}.');
      return;
    }

    // If initialFloor is specified, use it - otherwise select the first floor that has this POI
    if (initialFloor != null) {
      _selectedFloor = initialFloor;
    } else {
      _selectedFloor = poisInBuilding.first.floor;
    }

    // Set floor plan path and check if it exists
    _updateFloorPlanPath();
    await _updatePOIsOnCurrentFloor();
    await _checkIfFloorPlanExists();
  }

  void _updateFloorPlanPath() {
    if (_nearestBuilding != null) {
      _floorPlanPath =
          'assets/maps/indoor/floorplans/${_nearestBuilding!.abbreviation}$_selectedFloor.svg';
    }
  }

  Future<void> _updatePOIsOnCurrentFloor() async {
    if (_nearestBuilding == null) return;

    // Get POIs for current building and floor
    _poisOnCurrentFloor = _matchingPOIs
        .where((poi) =>
            poi.buildingId == _nearestBuilding!.abbreviation &&
            poi.floor == _selectedFloor)
        .toList();

    // Apply radius filter if we have POIs
    if (_poisOnCurrentFloor.isNotEmpty) {
      await _filterPOIsByRadius();
    }

    // Check if there are any POIs on the current floor
    _noPoisOnCurrentFloor = _poisOnCurrentFloor.isEmpty;

    // Debug log
    dev.log(
        'Floor $_selectedFloor has ${_poisOnCurrentFloor.length} POIs of type $_poiName within radius $_searchRadius');

    notifyListeners();
  }

  Future<void> _filterPOIsByRadius() async {
    if (_poisOnCurrentFloor.isEmpty || _nearestBuilding == null) return;

    // Get the building data
    final buildingData = await BuildingDataManager.getBuildingData(
        _nearestBuilding!.abbreviation);
    if (buildingData == null) return;

    // Get user's current position using the provided method
    final userPoint = _indoorDirectionsViewModel.getRegularStartPoint(
        buildingData, _selectedFloor);

    if (userPoint == null) {
      dev.log('Could not determine user position on current floor');
      return;
    }

    // Store the user position for displaying the marker
    _userPosition =
        Offset(userPoint.positionX.toDouble(), userPoint.positionY.toDouble());

    // Filter POIs based on distance
    _poisOnCurrentFloor = _poisOnCurrentFloor.where((poi) {
      // Calculate Euclidean distance on the floor plan
      final distance = _calculateDistance(userPoint.positionX.toDouble(),
          userPoint.positionY.toDouble(), poi.x.toDouble(), poi.y.toDouble());

      return distance <= _searchRadius;
    }).toList();

    _noPoisOnCurrentFloor = _poisOnCurrentFloor.isEmpty;

    dev.log(
        'Filtered POIs within radius $_searchRadius: ${_poisOnCurrentFloor.length}');

    notifyListeners();
  }

  double _calculateDistance(double x1, double y1, double x2, double y2) {
    // Scale factors for converting floor plan coordinates to real-world meters
    const double xScale = 67.0; // x-axis represents 67 meters
    const double yScale = 72.0; // y-axis represents 72 meters

    // Convert floor plan coordinates to real-world meters
    final double realX1 = x1 * (xScale / _width);
    final double realY1 = y1 * (yScale / _height);
    final double realX2 = x2 * (xScale / _width);
    final double realY2 = y2 * (yScale / _height);

    // Calculate Euclidean distance in real-world meters
    return sqrt(pow(realX2 - realX1, 2) + pow(realY2 - realY1, 2));
  }

  Future<void> _checkIfFloorPlanExists() async {
    // Check if the asset exists
    final bool exists =
        await _indoorMapViewModel.doesAssetExist(_floorPlanPath);
    dev.log('Floor plan exists: $exists');

    _floorPlanExists = exists;

    if (!exists) {
      _setLoading(false);
      return;
    }

    // Get SVG dimensions
    final size =
        await _indoorDirectionsViewModel.getSvgDimensions(_floorPlanPath);

    _width = size.width;
    _height = size.height;
    _setLoading(false);

    // Explicitly filter POIs by radius (which will also set the user position)
    await _filterPOIsByRadius();

    notifyListeners();
  }

  Future<void> changeFloor(String floor) async {
    if (_selectedFloor == floor) return; // Skip if same floor selected

    _selectedFloor = floor;
    _setLoading(true);
    _noPoisOnCurrentFloor = false; // Reset this flag when changing floors

    // Update floor plan path
    _updateFloorPlanPath();

    // This will update the POIs for the new floor
    await _updatePOIsOnCurrentFloor();

    // Check if the floor plan exists and get its dimensions
    await _checkIfFloorPlanExists();
  }

  Future<void> setSearchRadius(double radius) async {
    if (_searchRadius == radius) return;

    _searchRadius = radius;
    await _updatePOIsOnCurrentFloor();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Public method to retry loading data
  Future<void> retry({String? initialBuilding, String? initialFloor}) async {
    await loadPOIData(
        initialBuilding: initialBuilding, initialFloor: initialFloor);
  }

  // Method to pan to a POI using the IndoorMapViewModel
  void panToPOI(POI poi, Size viewportSize) {
    if (_disposed) return;

    final poiPosition = Offset(poi.x.toDouble(), poi.y.toDouble());
    _indoorMapViewModel.centerOnPoint(poiPosition, viewportSize,
        padding: 100.0);
  }

  // Method to pan to the first POI on the current floor
  void panToFirstPOI(Size viewportSize) {
    if (_disposed || _poisOnCurrentFloor.isEmpty) return;

    panToPOI(_poisOnCurrentFloor.first, viewportSize);
  }
}
