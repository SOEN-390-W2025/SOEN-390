import 'package:flutter/material.dart';
import 'search_bar.dart';

class MapLayout extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapLayout({
    super.key,
    required this.searchController,
    required this.onMyLocation,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          const Placeholder(),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(controller: TextEditingController(),) ,
          ),
          Positioned(
            top: 100,
            right: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // My Location Button (Separate Box)
                Container(
                  margin: const EdgeInsets.only(bottom: 10), // Space between boxes
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: _mapButton(Icons.my_location, onMyLocation),
                ),

                // Zoom Controls (Separate Box)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _mapButton(Icons.add, onZoomIn, isTop: true),
                      const Divider(height: 1, color: Colors.grey),
                      _mapButton(Icons.remove, onZoomOut, isTop: false),
                    ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onPressed, {bool isTop = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: isTop ?
          const BorderRadius.vertical(top: Radius.circular(10)) :
          const BorderRadius.vertical(bottom: Radius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 40,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
