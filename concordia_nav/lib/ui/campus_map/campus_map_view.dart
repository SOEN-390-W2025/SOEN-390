// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/building_info_drawer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class CampusMapPage extends StatefulWidget {
  final ConcordiaCampus campus;
  final MapViewModel? mapViewModel;
  final MapViewModel? buildMapViewModel;

  const CampusMapPage(
      {super.key,
      required this.campus,
      this.mapViewModel,
      this.buildMapViewModel});

  @override
  // ignore: no_logic_in_create_state
  State<CampusMapPage> createState() =>
      // ignore: no_logic_in_create_state
      CampusMapPageState(
          mapViewModel: mapViewModel, buildMapViewModel: buildMapViewModel);
}

class CampusMapPageState extends State<CampusMapPage> {
  // Modify constructor to allow dependency injection
  CampusMapPageState(
      {MapViewModel? mapViewModel, MapViewModel? buildMapViewModel})
      : _mapViewModel = mapViewModel ?? MapViewModel(),
        _buildMapViewModel = buildMapViewModel ?? MapViewModel();

  final MapViewModel _mapViewModel;
  final MapViewModel _buildMapViewModel;
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  late ConcordiaCampus _currentCampus;
  bool _locationPermissionGranted = false;
  final TextEditingController _searchController =
      TextEditingController(text: 'Search...');
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};
  List<String> searchList = [];

  MapViewModel get mapViewModel => _mapViewModel;

  Future<void> _loadMapData() async {
    if (!_isMapDataLoaded) {
      final data = await _mapViewModel.getCampusPolygonsAndLabels(_currentCampus);
      setState(() {
        _polygons = data["polygons"];
        _labelMarkers = data["labels"];
        _isMapDataLoaded = true;
      });
    }
  }

  void getSearchList() {
    final buildings = _buildingViewModel.getBuildingsByCampus(_currentCampus);
    for (var building in buildings) {
      if (!searchList.contains(building)) {
        searchList.add(building);
      }
    }
  }

  void checkLocationPermission() {
    _mapViewModel.checkLocationAccess().then((hasPermission) {
      setState(() {
        _locationPermissionGranted = hasPermission;
      });
    });
  }

  // Method to handle animation when selected building changes
  void _onSelectedBuildingChanged() {
    if (mounted && _mapViewModel.selectedBuildingNotifier.value != null) {
      final selectedBuilding = _mapViewModel.selectedBuildingNotifier.value!;

      // This will trigger a smooth animation to the selected building
      _mapViewModel.moveToLocation(LatLng(selectedBuilding.lat, selectedBuilding.lng));

      setState(() {}); // Force rebuild for drawer and other UI elements
    }
  }

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;

    // Initialize the camera position future once
    _initialCameraPositionFuture = _mapViewModel.getInitialCameraPosition(_currentCampus);

    // Fetch initial data once
    _loadMapData();

    // Check for location permission
    checkLocationPermission();

    // Populate search list with buildings
    getSearchList();
    
    // Listener to rebuild when a building is selected
    _mapViewModel.selectedBuildingNotifier.addListener(_onSelectedBuildingChanged);
  }

  @override
  void dispose() {
    _mapViewModel.selectedBuildingNotifier.removeListener(_onSelectedBuildingChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  /// Builds the campus map page.
  ///
  /// This page displays a map of a campus (e.g. SGW or LOY) and
  /// allows the user to search for a building.
  ///
  /// When the user selects a building, a drawer appears with
  /// information about the building.
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _buildMapViewModel,
      child: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: Semantics(
              label: 'Search for buildings or explore the campus map.',
              child: Stack(
                children: [
                  // Use a direct Widget instead of rebuilding the FutureBuilder on every build
                  FutureBuilder<Map<String, dynamic>>(
                    future: _mapViewModel.getCampusPolygonsAndLabels(_currentCampus),
                    builder: (context, snapshot) {
                      return FutureBuilder<CameraPosition>(
                        future: _initialCameraPositionFuture,
                        builder: (context, cameraSnapshot) {
                          if (!cameraSnapshot.hasData || !snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasData) {
                            _polygons = snapshot.data!["polygons"] as Set<Polygon>;
                            _labelMarkers = snapshot.data!["labels"] as Set<Marker>;
                          }

                          return MapLayout(
                            searchController: _searchController,
                            mapWidget: _buildGoogleMap(cameraSnapshot.data!),
                            mapViewModel: _mapViewModel,
                          );
                        },
                      );
                    },
                  ),
                  _buildSearchBar(context),
                  _buildBuildingInfoDrawer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return customAppBar(
      context,
      _currentCampus.name,
      actionIcon: const Icon(Icons.swap_horiz, color: Colors.white),
      onActionPressed: () {
        _onCampusSwitch();
      },
    );
  }

  // Store the initial camera position to avoid recreating the Future on rebuilds
  late Future<CameraPosition> _initialCameraPositionFuture;
  // Flag to track if initial map data is loaded
  bool _isMapDataLoaded = false;

  // Removed the separate FutureBuilder methods as they're now consolidated in the build method

  Semantics _buildGoogleMap(CameraPosition initialCameraPosition) {
    return Semantics(
      label: 'Google Map',
      child: GoogleMap(
        buildingsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapViewModel.onMapCreated(controller);
        },
        initialCameraPosition: initialCameraPosition,
        markers: _labelMarkers,
        polygons: _polygons,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: _locationPermissionGranted,
      ),
    );
  }

  Positioned _buildSearchBar(BuildContext context) {
    return Positioned(
      top: 10,
      left: 15,
      right: 15,
      child: SearchBarWidget(
        controller: _searchController,
        hintText: 'Search...',
        icon: Icons.location_on,
        iconColor: Theme.of(context).primaryColor,
        searchList: searchList,
        mapViewModel: _mapViewModel,
        drawer: true,
      ),
    );
  }

  Widget _buildBuildingInfoDrawer() {
    return ValueListenableBuilder<ConcordiaBuilding?>(
      valueListenable: _mapViewModel.selectedBuildingNotifier,
      builder: (context, selectedBuilding, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                      .animate(animation),
              child: child,
            );
          },
          child: selectedBuilding != null
              ? BuildingInfoDrawer(
                  building: selectedBuilding,
                  onClose: _mapViewModel.unselectBuilding,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Future<void> _onCampusSwitch() async {
    final ConcordiaCampus newCampus = _currentCampus == ConcordiaCampus.sgw
        ? ConcordiaCampus.loy
        : ConcordiaCampus.sgw;

    // Get the new camera position
    final CameraPosition newPosition = await _mapViewModel.getInitialCameraPosition(newCampus);

    _mapViewModel.moveToLocation(newPosition.target);

    // Get the map data for the new campus
    final data = await _mapViewModel.getCampusPolygonsAndLabels(newCampus);

    // Update all state at once after data is loaded
    setState(() {
      _currentCampus = newCampus;
      _initialCameraPositionFuture = Future.value(newPosition);
      _polygons = data["polygons"];
      _labelMarkers = data["labels"];
      _isMapDataLoaded = true;
    });

    _mapViewModel.unselectBuilding();
    _searchController.text = 'Search...';
    searchList.clear();
    checkLocationPermission();
    getSearchList();
  }
}