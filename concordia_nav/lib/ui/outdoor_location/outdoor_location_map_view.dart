import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/source_destination_box.dart';

class OutdoorLocationMapView extends StatefulWidget {
  final ConcordiaCampus campus;
  final ConcordiaBuilding? building; 

  const OutdoorLocationMapView({super.key, required this.campus, this.building});

  @override
  State<OutdoorLocationMapView> createState() => OutdoorLocationMapViewState();
}

class OutdoorLocationMapViewState extends State<OutdoorLocationMapView> {
  final MapViewModel _mapViewModel = MapViewModel();
  late ConcordiaCampus _currentCampus;
  late Future<CameraPosition> _initialCameraPosition;
  bool _locationPermissionGranted = false;
  late TextEditingController _sourceController;
  late TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
    _sourceController = TextEditingController();
    _destinationController = TextEditingController(text: widget.building?.name ?? '');
    _initialCameraPosition = _mapViewModel.getInitialCameraPosition(_currentCampus);
    _mapViewModel.checkLocationAccess().then((hasPermission) {
      setState(() {
        _locationPermissionGranted = hasPermission;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, widget.building == null ? 'Outdoor Location' : widget.campus.name,),
      body: Stack(
        children: [
          FutureBuilder<CameraPosition>(
            future: _initialCameraPosition,
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
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: _locationPermissionGranted,
                  markers: _mapViewModel.getCampusMarkers(_currentCampus),
                  /* TODO: add campus building overlay (polygon shape) */
                ),
                mapViewModel: _mapViewModel,
                style: 2,
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SourceDestinationBox(
              sourceController: _sourceController,
              destinationController: _destinationController,
            ),
          ),
        ],
      ),
    );
  }
}
