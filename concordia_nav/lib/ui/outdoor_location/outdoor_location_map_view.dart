import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;
  final OutdoorLocationMapViewState? customState;

  const OutdoorLocationMapView(
      {super.key, required this.campus, this.customState});

  @override
  State<OutdoorLocationMapView> createState() =>
      // ignore: no_logic_in_create_state
      customState ?? OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView> {
  final MapViewModel _mapViewModel;
  late ConcordiaCampus _currentCampus;
  final String destination = '';

// Modify constructor to allow dependency injection
  OutdoorLocationMapViewState({MapViewModel? mapViewModel})
      : _mapViewModel = mapViewModel ?? MapViewModel();

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Outdoor Directions'),
      body: Stack(
        children: [
          // FutureBuilder to load the map
          FutureBuilder<CameraPosition>(
            future: _mapViewModel.getInitialCameraPosition(_currentCampus),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
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

                  return MapLayout(
                    mapWidget: GoogleMap(
                      onMapCreated: _mapViewModel.onMapCreated,
                      initialCameraPosition: snapshot.data!,
                      markers: labelMarkers,
                      polygons: polygons,
                    ),
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
              controller: TextEditingController(),
              hintText: 'Enter Destination',
              icon: Icons.location_on,
              iconColor: const Color(0xFFDA3A16),
            ),
          ),
        ],
      ),
    );
  }
}
