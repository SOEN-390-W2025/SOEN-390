// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/compact_location_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;
  final ConcordiaBuilding? building;
  final MapViewModel? mapViewModel;

  const OutdoorLocationMapView(
      {super.key, required this.campus, this.building, this.mapViewModel});

  @override
  State<OutdoorLocationMapView> createState() => OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView>
    with WidgetsBindingObserver {
  late MapViewModel _mapViewModel;
  late ConcordiaCampus _currentCampus;
  late Future<CameraPosition> _initialCameraPosition;
  bool _locationPermissionGranted = false;
  late TextEditingController _sourceController = TextEditingController();
  late TextEditingController _destinationController = TextEditingController();
  bool isKeyboardVisible = false;
  double? bottomInset = 0;

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _sourceController = TextEditingController();
    _destinationController =
        TextEditingController(text: widget.building?.streetAddress ?? '');
    _currentCampus = widget.campus;
    _initialCameraPosition =
        _mapViewModel.getInitialCameraPosition(_currentCampus);

    _mapViewModel.mapService
        .checkAndRequestLocationPermission()
        .then((hasPermission) {
      setState(() {
        _locationPermissionGranted = hasPermission;
      });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    bottomInset = View.of(context).viewInsets.bottom;
    final newKeyboardVisible = bottomInset! > 1;
    if (newKeyboardVisible != isKeyboardVisible) {
      setState(() {
        isKeyboardVisible = newKeyboardVisible;
      });
    }
  }

  void updateBuilding(ConcordiaBuilding newBuilding) {
    setState(() {
      _destinationController.text = newBuilding.streetAddress!;
    });
  }

  Future<void> _launchGoogleMapsNavigation(LatLng destination) async {
    final url =
        'google.navigation:q=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _getDirections() async {
    try {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      final origin =
          _sourceController.text.isEmpty ? null : _sourceController.text;
      await _mapViewModel.fetchRoutesForAllModes(
          origin, _destinationController.text);

      // Optionally, pick a default mode.
      _mapViewModel.setActiveMode(CustomTravelMode.driving);
      setState(() {});
    } on Error catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load directions: $e")),
      );
    }
  }

  Widget _buildModeChip(CustomTravelMode mode) {
    IconData icon;
    switch (mode) {
      case CustomTravelMode.driving:
        icon = Icons.directions_car;
        break;
      case CustomTravelMode.walking:
        icon = Icons.directions_walk;
        break;
      case CustomTravelMode.bicycling:
        icon = Icons.directions_bike;
        break;
      case CustomTravelMode.transit:
        icon = Icons.directions_transit_filled_outlined;
        break;
      case CustomTravelMode.shuttle:
        icon = Icons.directions_bus;
        break;
    }

    final String time = _mapViewModel.travelTimes[mode] ?? "--";
    final bool isSelected = (_mapViewModel.selectedTravelMode == mode);

    return GestureDetector(
      onTap: () {
        setState(() {
          _mapViewModel.setActiveModeForRoute(mode);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.red : Colors.black),
            const SizedBox(width: 6),
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    final bool showModeChips = _mapViewModel.travelTimes.isNotEmpty;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CompactSearchCardWidget(
              originController: _sourceController,
              destinationController: _destinationController,
              mapViewModel: _mapViewModel,
            ),
            if (showModeChips)
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CustomTravelMode.values
                        .where((mode) {
                          final String time =
                              _mapViewModel.travelTimes[mode] ?? "--";
                          if (time == "--") return false;
                          if (mode == CustomTravelMode.shuttle) {
                            return _mapViewModel.shuttleAvailable;
                          }
                          return true;
                        })
                        .map((mode) => _buildModeChip(mode))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Center? _getCamSnapshot(AsyncSnapshot<CameraPosition> camSnapshot) {
    if (camSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (camSnapshot.hasError) {
      return const Center(child: Text('Error loading campus map'));
    }
    return null;
  }

  Widget _visibleKeyboardWidget() {
    return Positioned(
      bottom: 30,
      left: 15,
      right: 15,
      child: Row(
        children: [
          // "Get Directions" button
          Expanded(
            child: ElevatedButton(
              onPressed: _getDirections,
              child: const Text(
                'Get Directions',
                style: TextStyle(
                  color: Color.fromRGBO(146, 35, 56, 1),
                ),
              ),
            ),
          ),
          if (_mapViewModel.destinationMarker != null)
            const SizedBox(width: 16),
          if (_mapViewModel.destinationMarker != null)
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(146, 35, 56, 1),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.navigation_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  final destination = _mapViewModel.destinationMarker!.position;
                  _launchGoogleMapsNavigation(destination);
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        widget.building == null ? 'Outdoor Location' : widget.campus.name,
      ),
      body: Stack(
        children: [
          FutureBuilder<CameraPosition>(
            future: _initialCameraPosition,
            builder: (context, camSnapshot) {
              _getCamSnapshot(camSnapshot);
              /*if (camSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (camSnapshot.hasError) {
                return const Center(child: Text('Error loading campus map'));
              }*/
              return FutureBuilder<Map<String, dynamic>>(
                future: _mapViewModel.getAllCampusPolygonsAndLabels(),
                builder: (context, polySnapshot) {
                  if (polySnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final Set<Polygon> polygons =
                      polySnapshot.data?["polygons"] ?? {};
                  final Set<Marker> labelMarkers =
                      polySnapshot.data?["labels"] ?? {};

                  return ValueListenableBuilder<Set<Marker>>(
                    valueListenable: _mapViewModel.shuttleMarkersNotifier,
                    builder: (context, shuttleMarkers, _) {
                      final allMarkers = {
                        ...labelMarkers,
                        ..._mapViewModel.staticBusStopMarkers,
                        ...shuttleMarkers,
                      };
                      if (_mapViewModel.destinationMarker != null) {
                        allMarkers.add(_mapViewModel.destinationMarker!);
                      }
                      if (!_locationPermissionGranted) {
                        return const Center(
                            child: Text('Location permission not granted'));
                      }
                      return MapLayout(
                        mapWidget: Semantics(
                          label: 'Google Map',
                          child: GoogleMap(
                            onMapCreated: _mapViewModel.onMapCreated,
                            initialCameraPosition: camSnapshot.data!,
                            zoomControlsEnabled: false,
                            polylines: _mapViewModel.activePolylines,
                            markers: allMarkers,
                            polygons: polygons,
                            myLocationButtonEnabled: false,
                            buildingsEnabled: false,
                            myLocationEnabled: _locationPermissionGranted,
                          ),
                        ),
                        mapViewModel: _mapViewModel,
                        style: 2,
                      );
                    },
                  );
                },
              );
            },
          ),
          _buildTopPanel(),
          if (isKeyboardVisible) _visibleKeyboardWidget(),
        ],
      ),
    );
  }
}
