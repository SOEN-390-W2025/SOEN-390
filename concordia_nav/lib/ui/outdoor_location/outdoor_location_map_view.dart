import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;
  final MapViewModel? mapViewModel;

  const OutdoorLocationMapView(
      {super.key, required this.campus, this.mapViewModel});

  @override
  State<OutdoorLocationMapView> createState() => OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView>
    with WidgetsBindingObserver {
  late MapViewModel _mapViewModel;
  final BuildingViewModel _buildingViewModel = BuildingViewModel();
  late ConcordiaCampus _currentCampus;
  CameraPosition? _initialCameraPosition;
  bool _locationPermissionGranted = false;
  Set<Polygon> _polygons = {};
  Set<Marker> _labelMarkers = {};
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<String> searchList = [];
  bool isKeyboardVisible = false;

  Future<void> _loadMapData() async {
    final mapData = await _mapViewModel.fetchMapData(_currentCampus, false);

    if (mounted) {
      setState(() {
        _initialCameraPosition = mapData['cameraPosition'];
        _polygons = mapData['polygons'];
        _labelMarkers = mapData['labels'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _currentCampus = widget.campus;

    // Fetch initial data once
    _loadMapData();

    // Check for location permission
    _mapViewModel.checkLocationAccess().then((hasPermission) {
      if (mounted) {
        setState(() {
          _locationPermissionGranted = hasPermission;
          if (_locationPermissionGranted && !searchList.contains("Your Location")) {
            searchList.insert(0, "Your Location");
          }
        });
      }
    });

    // Add buildings to search list
    final buildings = _buildingViewModel.getBuildings();
    for (var building in buildings) {
      if (!searchList.contains(building)) {
        searchList.add(building);
      }
    }

    WidgetsBinding.instance
        .addObserver(this); // Start observing keyboard changes
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    WidgetsBinding.instance
        .removeObserver(this); // Remove observer to prevent memory leaks
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    setState(() {
      isKeyboardVisible = bottomInset > 1;
    });
  }

  Future<void> _getDirections() async {
    try {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await _mapViewModel.fetchRoute(
        _sourceController.text.isEmpty ? null : _sourceController.text,
        _destinationController.text,
      );
      setState(() {});
    } on Error catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load directions: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Outdoor Directions'),
      body: Stack(
        children: [
          if (_initialCameraPosition == null) // Show loading indicator until map is ready
            const Center(child: CircularProgressIndicator())
          else MapLayout(
            mapWidget: GoogleMap(
              onMapCreated: _mapViewModel.onMapCreated,
              initialCameraPosition: _initialCameraPosition!,
              zoomControlsEnabled: false,
              polylines: _mapViewModel.polylines,
              markers: _labelMarkers,
              polygons: _polygons,
              myLocationButtonEnabled: false,
              buildingsEnabled: false,
              myLocationEnabled: _locationPermissionGranted,
            ),
            mapViewModel: _mapViewModel,
            style: 2,
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              controller: _sourceController,
              hintText: 'Your Location',
              icon: Icons.location_on,
              iconColor: Theme.of(context).primaryColor,
              searchList: searchList,
              mapViewModel: _mapViewModel,
            ),
          ),
          Positioned(
            top: 80,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              controller: _destinationController,
              hintText: 'Enter Destination',
              icon: Icons.location_on,
              iconColor: const Color(0xFFDA3A16),
              searchList: searchList,
              mapViewModel: _mapViewModel,
            ),
          ),
        ],
      ),
    );
  }
}
