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
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
  }

  // Add this function to get directions and draw the polyline on the map
  void _getDirections() async {
    if (_destinationController.text.isEmpty) return;

    try {
      // Get the source and destination addresses
      String originAddress = "1455 boul. de Maisonneuve O, Montreal, QC"; // Replace with dynamic input if needed
      String destinationAddress = _destinationController.text;
      print("Fetching route from: $originAddress to: $destinationAddress");

      // Fetch the route using the origin and destination addresses
      List<LatLng> routePoints = await _mapViewModel.mapService.getRoutePath(
        originAddress,
        destinationAddress,
      );
      print("Route Points: $routePoints");

      // Update the map with the polyline
      setState(() {}); // This triggers a rebuild of the widget
    } catch (e) {
      print("Error getting directions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load directions: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Outdoor Directions'),
      body: Stack(
        children: [
          // Add your map widget here (for now it's just a container)
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
                  polylines: _mapViewModel.mapService.getPolylines(),
                  onTap: (LatLng latLng) {
                    print("Map tapped at: $latLng");
                  },
                  markers: _mapViewModel.getCampusMarkers([
                    /* TODO: add campus building markers */
                  ]),
                  /* TODO: add campus building overlay (polygon shape) */
                ),
              );
            },
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              controller: TextEditingController(),
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