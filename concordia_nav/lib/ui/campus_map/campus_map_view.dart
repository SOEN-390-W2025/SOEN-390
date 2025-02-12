import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/map_viewmodel.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';
import '../../widgets/building_info_drawer.dart';
import '../../widgets/zoom_buttons.dart';

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
              _currentCampus.name,
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
                        markers: mapViewModel.getCampusMarkers(
                          _currentCampus.abbreviation
                        ),
                        zoomControlsEnabled: false,
                        /* TODO: add campus building overlay (polygon shape) */
                      ),
                    );
                  },
                ),
                // Custom Zoom Buttons Positioned at the Top
                CustomZoomButtons(mapViewModel: mapViewModel),
                // Building info drawer for selected building
                ValueListenableBuilder<ConcordiaBuilding?>(
                  valueListenable: mapViewModel.selectedBuildingNotifier,
                  builder: (context, selectedBuilding, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                              .animate(animation),
                          child: child,
                        );
                      },
                      child: selectedBuilding != null
                          ? BuildingInfoDrawer(
                              building: selectedBuilding,
                              onClose: mapViewModel.unselectBuilding,
                            )
                          : const SizedBox.shrink(),
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
