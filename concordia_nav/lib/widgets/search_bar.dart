// ignore_for_file: prefer_final_locals

import 'package:flutter/material.dart';
import '../utils/map_viewmodel.dart';
import '../utils/building_viewmodel.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController? controller2;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final List<String> searchList;
  final MapViewModel? mapViewModel;
  final bool isSource;
  final bool drawer;
  final VoidCallback? onDirectionFetched;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.controller2,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    required this.searchList,
    this.mapViewModel,
    this.isSource = true,
    this.drawer = false,
    this.onDirectionFetched,
  });

  Future<void> getDirections() async {
    if (controller.text.isEmpty || (controller2?.text ?? '').isEmpty) {
      // Handle empty input case
      return;
    }

    // Get the start and end locations
    String startLocation = isSource ? controller.text : controller2!.text;

    String endLocation = isSource ? controller2!.text : controller.text;

    await mapViewModel?.fetchRoutesForAllModes(startLocation, endLocation);

    onDirectionFetched?.call();
  }

  Future<void> handleSelection(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/SearchView',
      arguments: searchList,
    );

    if (result == null) return;

    final selectedBuilding = (result as List)[0];

    controller.text = selectedBuilding;

    if (drawer) {
      if (selectedBuilding != 'Your Location') {
        final building =
            BuildingViewModel().getBuildingByName(selectedBuilding);
        if (building != null) {
          // Unselect any previous building if selecting a named building
          mapViewModel?.unselectBuilding();
          mapViewModel?.selectBuilding(building);
          // Camera position will be updated by the listener in CampusMapPage
        }
      } else {
        // For "Your Location", unselect any building to trigger camera update
        mapViewModel?.unselectBuilding();
        
        // If the selected building is "Your Location", check for building at current location
        if (context.mounted) {
          await mapViewModel?.checkBuildingAtCurrentLocation(context);
        }
      }
    } else {
      await getDirections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleSelection(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: iconColor),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}