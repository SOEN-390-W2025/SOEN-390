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
  final MapViewModel? buildMapViewModel;

  const CampusMapPage({super.key, required this.campus, this.mapViewModel, this.buildMapViewModel});

  @override
  // ignore: no_logic_in_create_state
  State<CampusMapPage> createState() =>
      // ignore: no_logic_in_create_state
      CampusMapPageState(mapViewModel: mapViewModel, buildMapViewModel: buildMapViewModel);
}

class CampusMapPageState extends State<CampusMapPage> {
  // Modify constructor to allow dependency injection
  CampusMapPageState({MapViewModel? mapViewModel, MapViewModel? buildMapViewModel})
      : _mapViewModel = mapViewModel ?? MapViewModel(),
      _buildMapViewModel = buildMapViewModel ?? MapViewModel();

  final MapViewModel _mapViewModel;
  final MapViewModel _buildMapViewModel;
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  late ConcordiaCampus _currentCampus;
  bool _locationPermissionGranted = false;
  final TextEditingController _searchController = TextEditingController(text: 'Search...');
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};
  List<String> searchList = [];

  MapViewModel get mapViewModel => _mapViewModel;

  //MapViewModel get mapViewModel => _mapViewModel;

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
        if (_locationPermissionGranted && !searchList.contains(_yourLocationString)) {
          searchList.insert(0, _yourLocationString);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;

    // Fetch initial data once
    _loadMapData();

    // Check for location permission
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
      create: (_) => _buildMapViewModel,//MapViewModel(),
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
                _mapViewModel.unselectBuilding();
                _searchController.text = 'Search...';
                searchList.clear();
                checkLocationPermission();
                getSearchList();
              },
            ),
            body: Stack(
              children: [FutureBuilder<CameraPosition>(
                future: _mapViewModel.getInitialCameraPosition(_currentCampus),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading campus map'));
                  }

                  return FutureBuilder<Map<String, dynamic>>(
                      future: _mapViewModel
                          .getCampusPolygonsAndLabels(_currentCampus),
                      builder: (context, polySnapshot) {
                        if (polySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return MapLayout(
                          searchController: _searchController,
                          mapWidget: Semantics(
                              label: 'Google Map',
                              child: GoogleMap(
                                buildingsEnabled: false,
                                onMapCreated: _mapViewModel.onMapCreated,
                                initialCameraPosition: snapshot.data!,
                                markers: _labelMarkers,
                                polygons: _polygons,
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                myLocationEnabled: _locationPermissionGranted,
                              )),
                          mapViewModel: _mapViewModel,
                        );
                      });
                }),
                Positioned(
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
                ),
              ]),
          );
        },
      ),
    );
  }
}
