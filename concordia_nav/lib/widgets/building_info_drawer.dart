import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../utils/building_drawer_viewmodel.dart';

class BuildingInfoDrawer extends StatefulWidget {
  final ConcordiaBuilding building;
  final VoidCallback onClose;

  const BuildingInfoDrawer({super.key, required this.building, required this.onClose});

  @override
  State<BuildingInfoDrawer> createState() => _BuildingInfoDrawerState();
}

class _BuildingInfoDrawerState extends State<BuildingInfoDrawer> with SingleTickerProviderStateMixin {
  late BuildingInfoDrawerViewModel drawerViewModel;

  @override
  void initState() {
    super.initState();
    drawerViewModel = BuildingInfoDrawerViewModel();
    drawerViewModel.initializeAnimation(this); // Initialize animation with this State as vsync
  }

  @override
  void dispose() {
    drawerViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: drawerViewModel.slideAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.18,
        minChildSize: 0.1,
        maxChildSize: 0.18,
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
                    Text(
                      widget.building.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        drawerViewModel.closeDrawer(widget.onClose); // Close with animation
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("${widget.building.city}, ${widget.building.province} ${widget.building.postalCode}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
