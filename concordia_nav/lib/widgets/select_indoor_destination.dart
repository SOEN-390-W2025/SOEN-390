import 'package:flutter/material.dart';
import '../ui/indoor_map/building_selection.dart';
import '../ui/indoor_map/floor_selection.dart';

class SelectIndoorDestination extends StatelessWidget {
  final String building;
  final String? floor;
  final String? endRoom;
  final bool isSource;

  const SelectIndoorDestination({super.key, required this.building, this.floor, this.endRoom, this.isSource = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Select Building
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BuildingSelection(
                    isSource: isSource,
                    endRoom: endRoom,
                  ),
                  settings: const RouteSettings(name: '/BuildingSelection'),
                ),
                // Remove all previous routes
                (route) {
                  return route.settings.name == '/HomePage' || route.settings.name == '/IndoorLocationView';
                },
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Set the border radius for rounded corners
              ),
            ),
            child: const Text('Select Building'),
          ),
          // Select Floor
          if (floor != null) ...[
            ElevatedButton(
              onPressed: () async {
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FloorSelection(
                      building: building,
                      endRoom: endRoom,
                      isSource: isSource,
                    ),
                    settings: const RouteSettings(name: '/FloorSelection'),
                  ),
                  (route) {
                    // Remove all previous routes except BuildingSelection
                    return route.settings.name == '/HomePage' || route.settings.name == '/BuildingSelection' || route.settings.name == '/IndoorLocationView';
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Set the border radius for rounded corners
                ),
              ),
              child: const Text('Select Floor'),
            ),
          ],
        ],
      ),
    );
  }
}
