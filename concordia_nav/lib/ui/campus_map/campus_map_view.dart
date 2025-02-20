import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class CampusMapPage extends StatefulWidget {
  final ConcordiaCampus campus;
  final MapViewModel? mapViewModel;

  const   CampusMapPage({super.key, required this.campus, this.mapViewModel});

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
  late ConcordiaCampus _currentCampus;
  bool _locationPermissionGranted = false;
  final TextEditingController _searchController = TextEditingController();
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};

  MapViewModel get mapViewModel => _mapViewModel;

  Future<void> _loadMapData() async {
    final data = await _mapViewModel.getCampusPolygonsAndLabels(_currentCampus);
    setState(() {
      _polygons = data["polygons"];
      _labelMarkers = data["labels"];
    });
  }

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;

    _loadMapData();

    _mapViewModel.checkLocationAccess().then((hasPermission) {
      setState(() {
        _locationPermissionGranted = hasPermission;
      });
    });
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
                  _currentCampus =
                      _currentCampus == ConcordiaCampus.sgw ? ConcordiaCampus.loy : ConcordiaCampus.sgw;
                  _loadMapData();
                  _mapViewModel.unselectBuilding();
                });
              },
            ),
            body:  FutureBuilder<CameraPosition>(
              /// Fetches the initial camera position for the given campus.
              future: _mapViewModel.getInitialCameraPosition(_currentCampus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading campus map'));
                }
                return FutureBuilder<Map<String, dynamic>>(
                  future: _mapViewModel.getCampusPolygonsAndLabels(_currentCampus),
                  builder: (context, polySnapshot) {
                    if (polySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                  return MapLayout(
                    searchController: _searchController,
                    mapWidget: GoogleMap(
                      buildingsEnabled: false,
                      onMapCreated: _mapViewModel.onMapCreated,
                      initialCameraPosition: snapshot.data!,
                      markers: _labelMarkers,
                      polygons: _polygons,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: _locationPermissionGranted,
                    ),
                    mapViewModel: _mapViewModel,
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }
}
