import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../utils/building_drawer_viewmodel.dart';
import '../ui/outdoor_location/outdoor_location_map_view.dart';

class BuildingInfoDrawer extends StatefulWidget {
  final ConcordiaBuilding building;
  final VoidCallback onClose;
  final BuildingInfoDrawerViewModel? viewModel; // Allow injection
  final OutdoorLocationMapView? outdoorLocationMapView;

  const BuildingInfoDrawer(
      {super.key,
      required this.building,
      required this.onClose,
      this.viewModel, // Optional parameter
      this.outdoorLocationMapView});

  @override
  State<BuildingInfoDrawer> createState() => _BuildingInfoDrawerState();
}

class _BuildingInfoDrawerState extends State<BuildingInfoDrawer>
    with SingleTickerProviderStateMixin {
  late BuildingInfoDrawerViewModel drawerViewModel;
  late OutdoorLocationMapView outdoorLocationMapView;

  /// Initializes the animation controller and slide animation.
  @override
  void initState() {
    super.initState();
    drawerViewModel = BuildingInfoDrawerViewModel();
    outdoorLocationMapView = widget.outdoorLocationMapView ??
        OutdoorLocationMapView(
          campus: widget.building.campus,
          building: widget.building,
        );
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
    final double screenHeight = MediaQuery.of(context).size.height;
    return SlideTransition(
      position: drawerViewModel.slideAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.15,
        maxChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenHeight * 0.02, vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenHeight * 0.02)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 5)
              ],
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
                        style: TextStyle(
                            fontSize: screenHeight * 0.028,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    /// The close button is displayed on the right side of the header.
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        (widget.viewModel ?? drawerViewModel).closeDrawer(
                            widget.onClose); // Close with animation
                      },
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),

                /// The building address is displayed below the name.
                Text(
                  "${widget.building.streetAddress}, ${widget.building.city}, ${widget.building.province} ${widget.building.postalCode}",
                  style: TextStyle(fontSize: screenHeight * 0.018),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// The "Select" button is displayed on the left side of the footer.
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => outdoorLocationMapView,
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      label: Text("Select",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.018)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenHeight * 0.03,
                            vertical: screenHeight * 0.015),
                      ),
                    ),

                    /// The "Indoor Map" button is displayed on the right side of the footer.
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/IndoorLocationView',
                          arguments: widget.building,
                        );
                      },
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: Text("Indoor Map",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.018)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenHeight * 0.03,
                            vertical: screenHeight * 0.015),
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
