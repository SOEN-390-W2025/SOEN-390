import 'package:flutter/material.dart';
import '../../../utils/map_viewmodel.dart';
import 'zoom_buttons.dart'; // Import the new file

class MapControllerButtons extends StatelessWidget {
  final MapViewModel mapViewModel;
  final int style;

  const MapControllerButtons({
    super.key,
    required this.mapViewModel,
    this.style = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: style == 1 ? 100 : 150,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current location button
          InkWell(
            onTap: () {
              mapViewModel.moveToCurrentLocation(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(100)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1), // Shadow position
                  ),
                ],
              ),
              child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          // Zoom In button
          ZoomButton(
            onTap: mapViewModel.zoomIn,
            icon: Icons.add,
            isZoomInButton: true,
          ),
          // Zoom Out button
          ZoomButton(
            onTap: mapViewModel.zoomOut,
            icon: Icons.remove,
            isZoomInButton: false,
          ),
        ],
      ),
    );
  }
}
