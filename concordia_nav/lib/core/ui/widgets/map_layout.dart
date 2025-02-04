import 'package:flutter/material.dart';
import './search_bar.dart';

class MapLayout extends StatelessWidget {
  final TextEditingController? searchController;
  final Widget mapWidget;

  const MapLayout({
    super.key,
    this.searchController,
    required this.mapWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mapWidget,
        if (searchController != null) // Only add SearchBarWidget if controller is not null
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(controller: searchController!),
          ),
      ],
    );
  }
}
