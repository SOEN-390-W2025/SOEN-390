import 'package:flutter/material.dart';
import '../utils/map_viewmodel.dart';
import './search_bar.dart';
import 'building_info_drawer.dart';
import 'map_control_buttons.dart';
import '../../data/domain-model/concordia_building.dart';

class MapLayout extends StatelessWidget {
  final TextEditingController? searchController;
  final Widget mapWidget;
  final MapViewModel? mapViewModel;
  final int style;

  const MapLayout({
    super.key,
    this.searchController,
    required this.mapWidget,
    this.mapViewModel,
    this.style = 1,
  });

  @override

  /// Builds the map layout with the map widget, search bar, controller buttons,
  /// and an optional building info drawer.
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main map widget
        mapWidget,

        // Search bar positioned at the top if searchController is not null
        if (searchController != null)
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              controller: searchController!,
              hintText: 'Search location ...',
              icon: Icons.search,
              iconColor: Colors.black,
              searchList: [],
            ),
          ),

        // Map control buttons and building info drawer if mapViewModel is not null
        if (mapViewModel != null) ...[
          // Buttons for controlling the map (zoom in/out)
          MapControllerButtons(mapViewModel: mapViewModel!, style: style),

          // Building info drawer appears when a building is selected
          ValueListenableBuilder<ConcordiaBuilding?>(
            valueListenable: mapViewModel!.selectedBuildingNotifier,
            builder: (context, selectedBuilding, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 1), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  );
                },
                child: selectedBuilding != null
                    ? BuildingInfoDrawer(
                        building: selectedBuilding,
                        onClose: mapViewModel!.unselectBuilding,
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        ]
      ],
    );
  }
}
