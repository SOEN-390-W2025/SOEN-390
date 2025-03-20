// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/poi.dart';
import '../../data/services/indoor_routing_service.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../data/repositories/building_data_manager.dart';
import '../../utils/poi/poi_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/floor_button.dart';
import '../indoor_location/floor_plan_widget.dart';
import '../indoor_location/indoor_directions_view.dart';
import 'package:geolocator/geolocator.dart';

class POIMapView extends StatefulWidget {
  final String? initialBuilding;
  final String? initialFloor;
  final String poiName;
  final POIViewModel poiChoiceViewModel;
  const POIMapView({
    super.key,
    required this.poiName,
    required this.poiChoiceViewModel,
    this.initialBuilding,
    this.initialFloor
  });

  @override
  State<POIMapView> createState() => _POIMapViewState();
}

class _POIMapViewState extends State<POIMapView> with SingleTickerProviderStateMixin {
  late IndoorMapViewModel _indoorMapViewModel;
  late BuildingViewModel _buildingViewModel;
  late IndoorDirectionsViewModel _indoorDirectionsViewModel;
  String _poiName = '';
  List<POI> _matchingPOIs = [];
  List<POI> _poisOnCurrentFloor = [];
  ConcordiaBuilding? _nearestBuilding;
  String _selectedFloor = '1';
  bool _isLoading = true;
  String _errorMessage = '';
  bool _floorPlanExists = true;
  late String _floorPlanPath;
  double _width = 1024.0;
  double _height = 1024.0;
  bool _noPoisOnCurrentFloor = false;

  @override
  void initState() {
    super.initState();
    _indoorMapViewModel = IndoorMapViewModel(vsync: this);
    _buildingViewModel = BuildingViewModel();
    _indoorDirectionsViewModel = IndoorDirectionsViewModel();
    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );
    
    _poiName = widget.poiName;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPOIData();
    });
  }

  @override
  void dispose() {
    _indoorMapViewModel.dispose();
    super.dispose();
  }

  Future<void> _loadPOIData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all POIs with this name
      final allPOIs = await BuildingDataManager.getAllPOIs();
      _matchingPOIs = allPOIs.where((poi) => poi.name == _poiName).toList();

      if (_matchingPOIs.isEmpty) {
        setState(() {
          _errorMessage = 'No POIs found with name: $_poiName';
          _isLoading = false;
        });
        return;
      }

      // If initialBuilding is provided, use it instead of finding nearest building
      if (widget.initialBuilding != null) {
        _useInitialBuildingAndFloor();
        return;
      }

      // Otherwise use geolocation to find nearest building
      final location = await IndoorRoutingService.getRoundedGeolocation();
      
      if (location == null) {
        setState(() {
          _errorMessage = 'Could not determine your location. Please check location permissions.';
          _isLoading = false;
        });
        return;
      }

      // If location is already a building (user is inside or very close)
      if (location is ConcordiaBuilding) {
        _nearestBuilding = location;
        _processNearestBuilding();
        return;
      }

      // Otherwise find the nearest building that contains the POI
      _findNearestBuildingWithPOI(location.lat, location.lng);
    } catch (e, stackTrace) {
      dev.log('Error loading POI data', error: e, stackTrace: stackTrace);
      setState(() {
        _errorMessage = 'Failed to load POI data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _useInitialBuildingAndFloor() {
    // Get building by abbreviation
    _nearestBuilding = _buildingViewModel.getBuildingByName(widget.initialBuilding!);
    
    if (_nearestBuilding == null) {
      setState(() {
        _errorMessage = 'Building ${widget.initialBuilding} not found.';
        _isLoading = false;
      });
      return;
    }
    
    // Set the floor (use provided floor or default to '1')
    _selectedFloor = widget.initialFloor ?? '1';
    
    // Set floor plan path
    _floorPlanPath = 'assets/maps/indoor/floorplans/${_nearestBuilding!.abbreviation}$_selectedFloor.svg';
    
    // Check if there are POIs of the requested type in this building
    final poisInBuilding = _matchingPOIs
        .where((poi) => poi.buildingId == _nearestBuilding!.abbreviation)
        .toList();
    
    if (poisInBuilding.isEmpty) {
      setState(() {
        _errorMessage = 'No $_poiName found in ${_nearestBuilding!.name}.';
        _isLoading = false;
      });
      return;
    }
    
    // Update POIs on the current floor and check if floor plan exists
    _updatePOIsOnCurrentFloor();
    _checkIfFloorPlanExists();
  }

  void _findNearestBuildingWithPOI(double userLat, double userLng) {
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
      _nearestBuilding = _buildingViewModel.getBuildingByAbbreviation(nearestBuildingId);
      _processNearestBuilding();
    } else {
      setState(() {
        _errorMessage = 'Could not find any building with $_poiName nearby.';
        _isLoading = false;
      });
    }
  }

  void _processNearestBuilding() {
    if (_nearestBuilding == null) {
      setState(() {
        _errorMessage = 'Could not determine nearest building.';
        _isLoading = false;
      });
      return;
    }

    // Find POIs in this building
    final poisInBuilding = _matchingPOIs
        .where((poi) => poi.buildingId == _nearestBuilding!.abbreviation)
        .toList();
    
    if (poisInBuilding.isEmpty) {
      setState(() {
        _errorMessage = 'No $_poiName found in ${_nearestBuilding!.name}.';
        _isLoading = false;
      });
      return;
    }

    // If initialFloor is specified, use it - otherwise select the first floor that has this POI
    if (widget.initialFloor != null) {
      _selectedFloor = widget.initialFloor!;
    } else {
      _selectedFloor = poisInBuilding.first.floor;
    }
    
    // Set floor plan path and check if it exists
    _floorPlanPath = 'assets/maps/indoor/floorplans/${_nearestBuilding!.abbreviation}$_selectedFloor.svg';
    _updatePOIsOnCurrentFloor();
    _checkIfFloorPlanExists();
  }

  void _updatePOIsOnCurrentFloor() {
    if (_nearestBuilding == null) return;
    
    // Get POIs for current building and floor
    _poisOnCurrentFloor = _matchingPOIs.where((poi) => 
      poi.buildingId == _nearestBuilding!.abbreviation && 
      poi.floor == _selectedFloor
    ).toList();
    
    // Check if there are any POIs on the current floor
    setState(() {
      _noPoisOnCurrentFloor = _poisOnCurrentFloor.isEmpty;
    });
    
    // Debug log
    dev.log('Floor $_selectedFloor has ${_poisOnCurrentFloor.length} POIs of type $_poiName');
  }

  Future<void> _checkIfFloorPlanExists() async {
    final bool exists = await _indoorMapViewModel.doesAssetExist(_floorPlanPath);
    dev.log('Floor plan exists: $exists');
    if (!exists) {
      setState(() {
        _floorPlanExists = false;
        _isLoading = false;
      });
      return;
    }

    // Get SVG dimensions
    final size = await _indoorDirectionsViewModel.getSvgDimensions(_floorPlanPath);
    
    setState(() {
      _width = size.width;
      _height = size.height;
      _floorPlanExists = true;
      _isLoading = false;
    });
  }

  void _changeFloor(String floor) {
    if (_selectedFloor == floor) return; // Skip if same floor selected
    
    setState(() {
      _selectedFloor = floor;
      _isLoading = true;
      _noPoisOnCurrentFloor = false; // Reset this flag when changing floors
    });
    
    // Update floor plan path
    _floorPlanPath = 'assets/maps/indoor/floorplans/${_nearestBuilding!.abbreviation}$_selectedFloor.svg';
    
    // This will update the POIs for the new floor
    _updatePOIsOnCurrentFloor();
    
    // Check if the floor plan exists and get its dimensions
    _checkIfFloorPlanExists();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPOIData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (!_floorPlanExists) {
      bodyContent = const Center(
        child: Text(
          'No floor plans exist at this time.',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      // Floor plan exists, show it with POI markers or message
      bodyContent = Stack(
        children: [
          // Floor plan
          FloorPlanWidget(
            indoorMapViewModel: _indoorMapViewModel,
            floorPlanPath: _floorPlanPath,
            semanticsLabel: 'Floor plan of ${_nearestBuilding!.abbreviation}-$_selectedFloor',
            width: _width,
            height: _height,
            pois: _poisOnCurrentFloor, // This passes the POIs specific to the current floor
            onPoiTap: (poi) {
              _showPOIDetails(poi);
            },
          ),

          // Floor selector button
          Positioned(
            top: 80,
            right: 16,
            child: FloorButton(
              floor: _selectedFloor,
              building: _nearestBuilding!,
              poiName: _poiName,
              poiChoiceViewModel: widget.poiChoiceViewModel,
              onFloorChanged: _changeFloor, // This triggers loading POIs for the new floor
            ),
          ),
          
          // No POIs message overlay - only show if we're not loading and there are no POIs
          if (_noPoisOnCurrentFloor && !_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'No $_poiName on floor $_selectedFloor',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: customAppBar(
        context,
        '${_nearestBuilding?.name ?? "Building"} - $_poiName',
      ),
      body: bodyContent,
    );
  }

  void _showPOIDetails(POI poi) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    poi.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Building: ${poi.buildingId}, Floor: ${poi.floor}"),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndoorDirectionsView(
                      sourceRoom: 'Your Location',
                      building: _nearestBuilding!.name,
                      endRoom: poi.floor.toString() + poi.name,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
              ),
              child: const Text(
                'Directions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}