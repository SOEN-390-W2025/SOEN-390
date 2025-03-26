import 'package:flutter/material.dart';
import '../data/domain-model/poi.dart';
import '../ui/indoor_location/indoor_directions_view.dart';

class POIBottomSheet extends StatelessWidget {
  final String buildingName;
  final POI poi;

  const POIBottomSheet({
    super.key,
    required this.buildingName,
    required this.poi,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  poi.name,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Building: $buildingName, Floor: ${poi.floor}",
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndoorDirectionsView(
                    sourceRoom: 'Your Location',
                    building: buildingName,
                    endRoom: '${poi.buildingId} ${poi.floor}${poi.name}',
                    selectedPOI: poi,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: onPrimaryColor,
            ),
            child: Text(
              'Directions',
              style: TextStyle(color: onPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }
}