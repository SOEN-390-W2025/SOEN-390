import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapControls({
    super.key,
    required this.onMyLocation,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // My Location Button (Separate Box)
        Container(
          margin: EdgeInsets.only(bottom: 10), // Space between boxes
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
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
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              _mapButton(Icons.add, onZoomIn, isTop: true),
              Divider(height: 1, color: Colors.grey),
              _mapButton(Icons.remove, onZoomOut, isTop: false),
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
          BorderRadius.vertical(top: Radius.circular(10)) :
          BorderRadius.vertical(bottom: Radius.circular(10)),
        child: Container(
          padding: EdgeInsets.all(10),
          width: 40,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
