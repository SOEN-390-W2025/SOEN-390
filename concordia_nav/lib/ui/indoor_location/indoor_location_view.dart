// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/poi.dart';
import '../../data/repositories/building_data_manager.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/floor_button.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import 'floor_plan_widget.dart';
import 'indoor_directions_view.dart';
import 'dart:developer' as dev;

class IndoorLocationView extends StatefulWidget {
  final ConcordiaBuilding building;
  final String? floor;
  final String? room;

  const IndoorLocationView(
      {super.key, required this.building, this.floor = '1', this.room});

  @override
  State<IndoorLocationView> createState() => _IndoorLocationViewState();
}

class _IndoorLocationViewState extends State<IndoorLocationView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _destinationController;

  late IndoorMapViewModel _indoorMapViewModel;

  late String floorPlanPath;
  double width = 1024.0;
  double height = 1024.0;
  bool _floorPlanExists = true;
  bool _isLoading = true;
  late IndoorDirectionsViewModel _directionsViewModel;
  bool _hasPannedToRoom = false;
  
  // Add POI-related state variables
  List<POI> _poisOnCurrentFloor = [];
  // ignore: unused_field
  bool _loadingPOIs = true;
  
  @override
  void initState() {
    super.initState();
    _directionsViewModel = IndoorDirectionsViewModel();
    _indoorMapViewModel = IndoorMapViewModel(vsync: this);
    floorPlanPath =
        'assets/maps/indoor/floorplans/${widget.building.abbreviation}${widget.floor}.svg';
    _checkIfFloorPlanExists();

    _getSvgSize();

    _destinationController = TextEditingController();
    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );
    
    // Load POIs for current floor
    _loadPOIsForCurrentFloor();
  }

  Future<void> _loadPOIsForCurrentFloor() async {
    setState(() {
      _loadingPOIs = true;
    });
    
    try {
      // Get all POIs from the building data manager
      final allPOIs = await BuildingDataManager.getAllPOIs();
      
      // Filter POIs for current building and floor
      _poisOnCurrentFloor = allPOIs.where((poi) => 
        poi.buildingId == widget.building.abbreviation && 
        poi.floor == widget.floor
      ).toList();
      
      dev.log('Found ${_poisOnCurrentFloor.length} POIs for ${widget.building.abbreviation} floor ${widget.floor}');
    } catch (e) {
      dev.log('Error loading POIs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingPOIs = false;
        });
      }
    }
  }

  Future<void> _getSvgSize() async {
    final size = await _directionsViewModel.getSvgDimensions(floorPlanPath);
    if (mounted) {
      setState(() {
        width = size.width;
        height = size.height;
      });
    }
  }

  Future<void> _checkIfFloorPlanExists() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final bool exists = await _indoorMapViewModel.doesAssetExist(floorPlanPath);
    setState(() {
      _floorPlanExists = exists;
      _isLoading = false;
    });
  }

  // New method to pan to the selected room
  Future<void> _panToSelectedRoom(BuildContext context) async {
    if (widget.room != null && !_hasPannedToRoom && _floorPlanExists && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // Get room position from the directionsViewModel
          final roomPoint = await _directionsViewModel.getPositionPoint(
            widget.building.name,
            widget.floor ?? '1',
            widget.room!,
          );
          
          if (roomPoint != null && context.mounted) {
            // Create an Offset from the room position
            final roomPosition = Offset(roomPoint.positionX, roomPoint.positionY);
            
            // Calculate screen size for centering
            final screenSize = MediaQuery.of(context).size;
            
            // Use centerOnPoint from IndoorMapViewModel to pan to the room
            _indoorMapViewModel.centerOnPoint(roomPosition, screenSize);
            
            // Mark as panned to avoid repeating
            setState(() {
              _hasPannedToRoom = true;
            });
            
            dev.log('Panned to room: ${widget.room} at position $roomPosition');
          } else {
            dev.log('Could not find position for room: ${widget.room}');
          }
        } catch (e) {
          dev.log('Error panning to room: $e');
        }
      });
    }
  }

  void _handlePoiTap(POI poi) {
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      "Building: ${widget.building.name}, Floor: ${poi.floor}"),
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
                      building: widget.building.name,
                      endRoom: '${poi.buildingId} ${poi.floor}${poi.name}',
                      selectedPOI: poi,
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

  @override
  void dispose() {
    _indoorMapViewModel.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log(_floorPlanExists.toString());
    
    // Try to pan to the selected room when the floor plan is loaded
    if (!_isLoading && _floorPlanExists && widget.room != null && !_hasPannedToRoom) {
      _panToSelectedRoom(context);
    }

    // Extracted body content decision into a separate statement
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_floorPlanExists) {
      bodyContent = Semantics(
        label: 'Indoor location floor plans',
        child: Stack(
          children: [
            FloorPlanWidget(
                indoorMapViewModel: _indoorMapViewModel,
                floorPlanPath: floorPlanPath,
                semanticsLabel:
                    'Floor plan of ${widget.building.abbreviation}-${widget.floor}',
                width: width,
                height: height,
            pois: _poisOnCurrentFloor,
            onPoiTap: _handlePoiTap,),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloorPlanSearchWidget(
                      searchController: _destinationController,
                      building: widget.building,
                      floor: 'Floor ${widget.floor}',
                      disabled: true,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 16,
              child: FloorButton(
                floor: widget.floor!,
                building: widget.building,
              ),
            ),
            if (widget.room != null) _buildFooter(),
          ],
        ),
      );
    } else {
      bodyContent = const Center(
        child: Text(
          'No floor plans exist at this time.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Scaffold(
      appBar: customAppBar(
        context,
        widget.building.name,
      ),
      body: bodyContent,
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${widget.building.abbreviation} ${widget.room!}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndoorDirectionsView(
                      sourceRoom: 'Your Location',
                      building: widget.building.name,
                      endRoom: widget.room!,
                    ),
                  ),
                  (route) {
                    return route.settings.name == '/HomePage' ||
                        route.settings.name == '/CampusMapPage';
                  },
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