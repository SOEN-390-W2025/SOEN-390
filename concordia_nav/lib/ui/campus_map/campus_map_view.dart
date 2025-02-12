import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class CampusMapPage extends StatefulWidget {
  final ConcordiaCampus campus;

  const CampusMapPage({super.key, required this.campus});

  @override
  State<CampusMapPage> createState() => CampusMapPageState();
}

class CampusMapPageState extends State<CampusMapPage> {
  final TextEditingController _searchController = TextEditingController();
  late ConcordiaCampus _currentCampus;

  @override
  void initState() {
    super.initState();
    _currentCampus = widget.campus;
  }

  @override
  /// Builds the campus map page.
  ///
  /// This page displays a map of a campus (e.g. SGW or LOY) and
  /// allows the user to search for a building.
  ///
  /// When the user selects a building, a drawer appears with
  /// information about the building.
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      /// Creates a new [MapViewModel] when the widget is created.
      create: (_) => MapViewModel(),
      child: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return Scaffold(
            appBar: customAppBar(
              context,
              'Campus Map',
              actionIcon: const Icon(Icons.swap_horiz, color: Colors.white),
              onActionPressed: () {
                // TODO: toggle between SGW and LOY campuses
              },
            ),
            body: Stack(
              children: [
                FutureBuilder<CameraPosition>(
                  /// Fetches the initial camera position for the given campus.
                  future: mapViewModel.getInitialCameraPosition(_currentCampus),
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
                        onMapCreated: mapViewModel.onMapCreated,
                        initialCameraPosition: snapshot.data!,
                        markers: mapViewModel.getCampusMarkers(),
                        zoomControlsEnabled: false,
                        /* TODO: add campus building overlay (polygon shape) */
                      ),
                      mapViewModel: mapViewModel,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
