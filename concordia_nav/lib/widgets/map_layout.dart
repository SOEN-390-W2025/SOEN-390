import 'package:flutter/material.dart';
import '../utils/map_viewmodel.dart';
import './search_bar.dart';
import './map_control_buttons.dart';

class MapLayout extends StatelessWidget {
  final TextEditingController? searchController;
  final Widget mapWidget;
  final MapViewModel? mapViewModel;
  final int style;

  const MapLayout({
    super.key,
    this.searchController,
    required this.mapWidget,
    this.mapViewModel,
    this.style = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mapWidget,
        if (searchController !=
            null) // Only add SearchBarWidget if controller is not null
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              controller: searchController!,
              hintText: 'Search location ...',
              icon: Icons.search,
              iconColor: Colors.black,
            ),
          ),
        // Map control buttons and building info drawer if mapViewModel is not null
        if (mapViewModel != null) ...[
          // Buttons for controlling the map (zoom in/out)
          MapControllerButtons(
            mapViewModel: mapViewModel!,
            style: style,
          ),
        ]
      ],
    );
  }
}
