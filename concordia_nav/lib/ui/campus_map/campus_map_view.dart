// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class CampusMapPage extends StatefulWidget {
  final ConcordiaCampus campus;
  final MapViewModel? mapViewModel;

  const CampusMapPage({super.key, required this.campus, this.mapViewModel});

  @override
  // ignore: no_logic_in_create_state
  State<CampusMapPage> createState() =>
      // ignore: no_logic_in_create_state
      CampusMapPageState(mapViewModel: mapViewModel);
}

class CampusMapPageState extends State<CampusMapPage> {
  // Modify constructor to allow dependency injection
  CampusMapPageState({MapViewModel? mapViewModel})
      : _mapViewModel = mapViewModel ?? MapViewModel();

  final MapViewModel _mapViewModel;
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  late ConcordiaCampus _currentCampus;
  bool _locationPermissionGranted = false;
  final TextEditingController _searchController = TextEditingController(text: 'Search...');
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};
  CameraPosition? _initialCameraPosition;
  List<String> searchList = [];

  //MapViewModel get mapViewModel => _mapViewModel;

  Future<void> _loadMapData() async {
    final mapData = await _mapViewModel.fetchMapData(_currentCampus, true);

    if (mounted) {
      setState(() {
        _initialCameraPosition = mapData['cameraPosition'];
        _polygons = mapData['polygons'];
        _labelMarkers = mapData['labels'];
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
        if (_locationPermissionGranted && !searchList.contains("Your Location")) {
          searchList.insert(0, "Your Location");
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;

    _loadMapData();

    checkLocationPermission();

    // Populate search list with buildings
    getSearchList();
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
      /// Creates a new [MapViewModel] when the widget is created.
      create: (_) => MapViewModel(),
      child: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return Scaffold(
            appBar: customAppBar(
              context,
              _currentCampus.name,
              actionIcon: const Icon(Icons.swap_horiz, color: Colors.white),
              onActionPressed: () {
                setState(() {
                  _currentCampus = _currentCampus == ConcordiaCampus.sgw
                      ? ConcordiaCampus.loy
                      : ConcordiaCampus.sgw;
                });
                _loadMapData();
                _mapViewModel.switchCampus(_currentCampus);
                _mapViewModel.unselectBuilding();
                _searchController.text = 'Search...';
                searchList.clear();
                checkLocationPermission();
                getSearchList();
              },
            ),
            body: Stack(
              children: [
                if (_initialCameraPosition == null) // Show loading indicator while data is loading
                  const Center(child: CircularProgressIndicator())
                else MapLayout(
                  searchController: _searchController,
                  mapWidget: GoogleMap(
                    buildingsEnabled: false,
                    onMapCreated: _mapViewModel.onMapCreated,
                    initialCameraPosition: _initialCameraPosition!,
                    markers: _labelMarkers,
                    polygons: _polygons,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: _locationPermissionGranted,
                  ),
                  mapViewModel: _mapViewModel,
                ),
                Positioned(
                  top: 10,
                  left: 15,
                  right: 15,
                  child: SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Your Location',
                    icon: Icons.location_on,
                    iconColor: Theme.of(context).primaryColor,
                    searchList: searchList,
                    mapViewModel: _mapViewModel,
                    drawer: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
