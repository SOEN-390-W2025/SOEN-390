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
  final MapControllerButtons? mapControllerButtons;

  const MapLayout({
    super.key,
    this.searchController,
    required this.mapWidget,
    this.mapViewModel,
    this.mapControllerButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mapWidget,
        if (searchController != null) // Only add SearchBarWidget if controller is not null
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              controller: searchController!,
              hintText: 'Search location ...',
              icon: Icons.search,
              iconColor: Colors.black,
            ),
          ),
        
        if (mapViewModel != null) ...[ // Only add MapControllerButtons if controller is not null
          MapControllerButtons(mapViewModel: mapViewModel!),
          ValueListenableBuilder<ConcordiaBuilding?>(
            valueListenable: mapViewModel!.selectedBuildingNotifier,
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