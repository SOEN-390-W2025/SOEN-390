import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../utils/map_viewmodel.dart';
import '../../../../data/domain-model/campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class CampusMapPage extends StatefulWidget {
  final Campus campus;

  const CampusMapPage({super.key, required this.campus});

  @override
  State<CampusMapPage> createState() => CampusMapPageState();
}

class CampusMapPageState extends State<CampusMapPage> {
  final MapViewModel _mapViewModel = MapViewModel();
  final TextEditingController _searchController = TextEditingController();
  late Campus _currentCampus;

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        _currentCampus.name,
        actionIcon: const Icon(Icons.swap_horiz, color: Colors.white),
        onActionPressed: () {
          // TODO: toggle between SGW and LOY campuses
        },
      ),
      body: FutureBuilder<CameraPosition>(
        future: _mapViewModel.getInitialCameraPosition(_currentCampus),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading campus map'));
          }

          return MapLayout(
            searchController: _searchController,
            mapWidget: GoogleMap(
              onMapCreated: _mapViewModel.onMapCreated,
              initialCameraPosition: snapshot.data!,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _mapViewModel.getCampusMarkers([
                /* TODO: add campus building markers */
              ]),
              /* TODO: add campus building overlay (polygon shape) */
            ),
            mapViewModel: _mapViewModel,
          );
        },
      ),
    );
  }
}
