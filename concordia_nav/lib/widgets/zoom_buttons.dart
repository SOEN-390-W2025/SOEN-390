import 'package:flutter/material.dart';
import '../../../utils/map_viewmodel.dart';

class CustomZoomButtons extends StatelessWidget {
  final MapViewModel mapViewModel;

  const CustomZoomButtons({super.key, required this.mapViewModel});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: mapViewModel.zoomIn,
            child: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: Colors.white,
            onPressed: mapViewModel.zoomOut,
            child: const Icon(Icons.remove, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
