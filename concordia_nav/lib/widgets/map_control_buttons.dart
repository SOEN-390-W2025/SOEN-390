import 'package:flutter/material.dart';
import '../../../utils/map_viewmodel.dart';

class MapControllerButtons extends StatelessWidget {
  final MapViewModel mapViewModel;
  final int style;

  const MapControllerButtons({
    super.key, 
    required this.mapViewModel,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: style == 0 ? 100 : 150,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current location button
          InkWell(
            onTap: () {
              // Todo: Add the method to move to current location
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all( Radius.circular(100)),
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
          InkWell(
            onTap: mapViewModel.zoomIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 192, 192, 192),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1), // Shadow position
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
          InkWell(
            onTap: mapViewModel.zoomOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 1), // Shadow position
                  ),
                ],
              ),
              child: const Icon(Icons.remove, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
