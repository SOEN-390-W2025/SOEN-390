import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';

class BuildingInfoDrawer extends StatelessWidget {
  final ConcordiaBuilding building;
  final Function onClose; // Add a callback to handle the close action

  const BuildingInfoDrawer({super.key, required this.building, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.1,
      maxChildSize: 0.2,
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
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // Execute the close action when the button is pressed
                    onClose();
                  },
                ),
              ),
              // Building info
              Text(building.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("${building.city}, ${building.province} ${building.postalCode}"),
            ],
          ),
        );
      },
    );
  }
}
