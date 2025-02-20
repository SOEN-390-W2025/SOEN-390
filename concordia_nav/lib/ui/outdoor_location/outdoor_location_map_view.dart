import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;
  final MapViewModel? mapViewModel;

  const OutdoorLocationMapView(
      {super.key, required this.campus, this.mapViewModel});

  @override
  State<OutdoorLocationMapView> createState() => _OutdoorLocationMapViewState();
}

class _OutdoorLocationMapViewState extends State<OutdoorLocationMapView> {
  late MapViewModel _mapViewModel;
  late ConcordiaCampus _currentCampus;
  late Future<CameraPosition> _initialCameraPosition;
  bool _locationPermissionGranted = false;
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
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
  }

  /// Triggers the route fetching and updates the map with the new polyline and destination marker.
  Future<void> _getDirections() async {
    try {
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
          FutureBuilder<CameraPosition>(
            future: _initialCameraPosition,
            builder: (context, camSnapshot) {
              if (camSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (camSnapshot.hasError) {
                return const Center(child: Text('Error loading campus map'));
              }
              return FutureBuilder<Map<String, dynamic>>(
                future:
                    _mapViewModel.getCampusPolygonsAndLabels(_currentCampus),
                builder: (context, polySnapshot) {
                  if (polySnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final Set<Polygon> polygons =
                      polySnapshot.data?["polygons"] ?? {};
                  final Set<Marker> labelMarkers =
                      polySnapshot.data?["labels"] ?? {};

                  if (_mapViewModel.destinationMarker != null) {
                    labelMarkers.add(_mapViewModel.destinationMarker!);
                  }

                  if (!_locationPermissionGranted) {
                    return const Center(
                        child: Text('Location permission not granted'));
                  }

                  return MapLayout(
                    mapWidget: GoogleMap(
                      onMapCreated: _mapViewModel.onMapCreated,
                      initialCameraPosition: camSnapshot.data!,
                      markers: labelMarkers,
                      polygons: polygons,
                      polylines: _mapViewModel.polylines,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      buildingsEnabled: false,
                      myLocationEnabled: _locationPermissionGranted,
                    ),
                    mapViewModel: _mapViewModel,
                    style: 2,
                  );
                },
              );
            },
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
            ),
          ),
          Positioned(
            bottom: 30,
            left: 15,
            right: 15,
            child: ElevatedButton(
              onPressed: _getDirections,
              child: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}
