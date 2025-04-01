// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/build_info_drawer.dart';
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
  State<CampusMapPage> createState() => CampusMapPageState();
}

class CampusMapPageState extends State<CampusMapPage> {
  late MapViewModel _mapViewModel;
  late MapViewModel _buildMapViewModel;
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
    final data = await _mapViewModel.getCampusPolygonsAndLabels(_currentCampus);
    setState(() {
      _polygons = data["polygons"];
      _labelMarkers = data["labels"];
    });
  }

  void getSearchList() {
    final buildings = _buildingViewModel.getBuildingsByCampus(_currentCampus);
    for (var building in buildings) {
      if (!searchList.contains(building)) {
        searchList.add(building);
      }
    }
  }

  final _yourLocationString = "Your Location";

  void checkLocationPermission() {
    _mapViewModel.checkLocationAccess().then((hasPermission) {
      setState(() {
        _locationPermissionGranted = hasPermission;
        if (_locationPermissionGranted &&
            !searchList.contains(_yourLocationString)) {
          searchList.insert(0, _yourLocationString);
        }
      });
    });
  }

  // Method to handle rebuilding when selected building changes
  void _onSelectedBuildingChanged() {
    // Force rebuild by calling setState
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _buildMapViewModel = widget.buildMapViewModel ?? MapViewModel();

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
                  _buildMapFutureBuilder(context),
                  _buildSearchBar(context),
                  BuildInfoDrawer(mapViewModel: _mapViewModel),
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

  FutureBuilder<CameraPosition> _buildMapFutureBuilder(BuildContext context) {
    return FutureBuilder<CameraPosition>(
      // Use the selectedBuilding position if available, otherwise use the campus default
      future: _mapViewModel.selectedBuildingNotifier.value != null
          ? Future.value(CameraPosition(
              target: LatLng(
                _mapViewModel.selectedBuildingNotifier.value!.lat,
                _mapViewModel.selectedBuildingNotifier.value!.lng,
              ),
              zoom: 18.0, // Higher zoom level for building view
            ))
          : _mapViewModel.getInitialCameraPosition(_currentCampus),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading campus map'));
        }
        return _buildCampusPolygonsFutureBuilder(snapshot);
      },
    );
  }

  FutureBuilder<Map<String, dynamic>> _buildCampusPolygonsFutureBuilder(
      AsyncSnapshot<CameraPosition> snapshot) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _mapViewModel.getCampusPolygonsAndLabels(_currentCampus),
      builder: (context, polySnapshot) {
        if (polySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return MapLayout(
          searchController: _searchController,
          mapWidget: _buildGoogleMap(snapshot.data!),
          mapViewModel: _mapViewModel,
        );
      },
    );
  }

  Semantics _buildGoogleMap(CameraPosition initialCameraPosition) {
    return Semantics(
      label: 'Google Map',
      child: GoogleMap(
        buildingsEnabled: false,
        onMapCreated: _mapViewModel.onMapCreated,
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
        hintText: _yourLocationString,
        icon: Icons.location_on,
        iconColor: Theme.of(context).primaryColor,
        searchList: searchList,
        mapViewModel: _mapViewModel,
        drawer: true,
      ),
    );
  }

  void _onCampusSwitch() {
    setState(() {
      _currentCampus = _currentCampus == ConcordiaCampus.sgw
          ? ConcordiaCampus.loy
          : ConcordiaCampus.sgw;
    });
    _loadMapData();
    _mapViewModel.unselectBuilding();
    _searchController.text = 'Search...';
    searchList.clear();
    checkLocationPermission();
    getSearchList();
  }
}