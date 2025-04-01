import 'package:flutter/material.dart';
import '../data/domain-model/concordia_building.dart';
import '../utils/map_viewmodel.dart';
import 'building_info_drawer.dart';

class BuildInfoDrawer extends StatelessWidget {
  final MapViewModel mapViewModel;
  
  const BuildInfoDrawer({
    super.key,
    required this.mapViewModel
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConcordiaBuilding?>(
      valueListenable: mapViewModel.selectedBuildingNotifier,
      builder: (context, selectedBuilding, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
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
    );
  }
}