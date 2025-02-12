import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';

class BuildingInfoDrawer extends StatelessWidget {
  final ConcordiaBuilding building;

  const BuildingInfoDrawer({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: ListView(
            controller: scrollController,
            children: [
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
