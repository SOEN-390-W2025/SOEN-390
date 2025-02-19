import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../utils/building_drawer_viewmodel.dart';
import '../ui/outdoor_location/outdoor_location_map_view.dart';

class BuildingInfoDrawer extends StatefulWidget {
  final ConcordiaBuilding building;
  final VoidCallback onClose;

  const BuildingInfoDrawer({super.key, required this.building, required this.onClose});

  @override
  State<BuildingInfoDrawer> createState() => _BuildingInfoDrawerState();
}

class _BuildingInfoDrawerState extends State<BuildingInfoDrawer> with SingleTickerProviderStateMixin {
  late BuildingInfoDrawerViewModel drawerViewModel;

  /// Initializes the animation controller and slide animation.
  @override
  void initState() {
    super.initState();
    drawerViewModel = BuildingInfoDrawerViewModel();
    drawerViewModel.initializeAnimation(this);
  }

  /// Disposes of the animation controller when the widget is disposed.
  @override
  void dispose() {
    drawerViewModel.dispose();
    super.dispose();
  }

  /// Builds the building info drawer.
  ///
  /// The drawer is a DraggableScrollableSheet that contains a ListView with
  /// the building name, address, and close button.
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: drawerViewModel.slideAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.24,
        minChildSize: 0.1,
        maxChildSize: 0.25,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// The building name is displayed in bold font.
                    Expanded(
                      child: Text(
                        widget.building.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    /// The close button is displayed on the right side of the header.
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        drawerViewModel.closeDrawer(widget.onClose); // Close with animation
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                /// The building address is displayed below the name.
                Text("${widget.building.streetAddress}, ${widget.building.city}, ${widget.building.province} ${widget.building.postalCode}"),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// The "Directions" button is displayed on the left side of the footer.
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutdoorLocationMapView(
                              campus: widget.building.campus,
                              building: widget.building,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text("Directions", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    /// The "Indoor Map" button is displayed on the right side of the footer.
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement navigation to indoor maps feature
                      },
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: const Text("Indoor Map", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
