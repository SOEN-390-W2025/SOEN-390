import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../utils/map_viewmodel.dart';

class OutdoorJourneyDirectionsView extends StatefulWidget {
  final ConcordiaCampus campus;
  final ConcordiaBuilding building;
  final MapViewModel? mapViewModel;

  const OutdoorJourneyDirectionsView({
    super.key,
    required this.campus,
    required this.building,
    this.mapViewModel,
  });

  @override
  State<OutdoorJourneyDirectionsView> createState() =>
      _OutdoorJourneyDirectionsViewState();
}

class _OutdoorJourneyDirectionsViewState
    extends State<OutdoorJourneyDirectionsView> {
  late MapViewModel _mapViewModel;
  late Future<CameraPosition> _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _mapViewModel = widget.mapViewModel ?? MapViewModel();
    _initialCameraPosition =
        _mapViewModel.getInitialCameraPosition(widget.campus);
    _mapViewModel.fetchRoutesForAllModes("Your Location", widget.building.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CameraPosition>(
        future: _initialCameraPosition,
        builder: (context, camSnapshot) {
          if (camSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (camSnapshot.hasError) {
            return const Center(child: Text('Error loading map'));
          }
          return ValueListenableBuilder<Set<Marker>>(
            valueListenable: _mapViewModel.shuttleMarkersNotifier,
            builder: (context, shuttleMarkers, _) {
              final markers = {
                if (_mapViewModel.originMarker != null)
                  _mapViewModel.originMarker!,
                if (_mapViewModel.destinationMarker != null)
                  _mapViewModel.destinationMarker!,
              };
              return GoogleMap(
                onMapCreated: _mapViewModel.onMapCreated,
                initialCameraPosition: camSnapshot.data!,
                zoomControlsEnabled: false,
                polylines: _mapViewModel.activePolylines,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            },
          );
        },
      ),
    );
  }
}
