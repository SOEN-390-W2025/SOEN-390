import 'package:flutter/material.dart';
import '../../../utils/map_viewmodel.dart';

class MapControllerButtons extends StatelessWidget {
  final MapViewModel mapViewModel;
  final int style;

  const MapControllerButtons({
    super.key,
    required this.mapViewModel,
    this.style = 1,
  });

  double _getStyle() {
    if (style == 1) {
      return 100;
    } else {
      if (style == 2) {return 150;}
      else {return 16;}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _getStyle(),
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current location button
          InkWell(
            onTap: () {
              mapViewModel.checkBuildingAtCurrentLocation(context);
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
              child: Icon(Icons.my_location,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
