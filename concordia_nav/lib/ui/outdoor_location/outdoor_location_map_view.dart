import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/search_bar.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;

  const OutdoorLocationMapView({super.key, required this.campus});

  @override
  State<OutdoorLocationMapView> createState() => OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView> {
  final MapViewModel _mapViewModel = MapViewModel();
  late ConcordiaCampus _currentCampus;
  final String destination = '';

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
