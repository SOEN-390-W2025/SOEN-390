import 'package:flutter/material.dart';
import '../../../utils/map_viewmodel.dart';

class MapControllerButtons extends StatelessWidget {
  final MapViewModel mapViewModel;

  const MapControllerButtons({super.key, required this.mapViewModel});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              ),
              child: const Icon(Icons.remove, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
