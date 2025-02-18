import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final Campus campus;

  const OutdoorLocationMapView({super.key, required this.campus});

  @override
  State<OutdoorLocationMapView> createState() => OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView> {
  final MapViewModel _mapViewModel = MapViewModel();
  late Campus _currentCampus;
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
  }

  // Get directions and draw polyline on map
  Future<void> _getDirections() async {
  try {
    await _mapViewModel.fetchRoute(
      _sourceController.text.isEmpty ? null : _sourceController.text,
      _destinationController.text,
    );

    if (mounted) {
      setState(() {});
    }
  // ignore: avoid_catches_without_on_clauses
  } catch (e) {
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
            future: _mapViewModel.getInitialCameraPosition(_currentCampus),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading campus map'));
              }

              return MapLayout(
                mapWidget: GoogleMap(
                  onMapCreated: _mapViewModel.onMapCreated,
                  initialCameraPosition: snapshot.data!,
                  polylines: _mapViewModel.polylines,
                  onTap: (LatLng latLng) {
                  },
                  markers: _mapViewModel.getCampusMarkers([
                    /* TODO: add campus building markers */
                  ]),
                ),
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