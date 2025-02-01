import 'package:flutter/material.dart';
import './search_bar.dart';

class MapLayout extends StatelessWidget {
  final TextEditingController searchController;
  final Widget mapWidget;

  const MapLayout({
    super.key,
    required this.searchController,
    required this.mapWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mapWidget,
        Positioned(
          top: 10,
          left: 15,
          right: 15,
          /*  
              Note that the placeholder searchbar is tentative and
              may be replaced with a Google Maps control
           */
          child: SearchBarWidget(controller: searchController),
        ),
      ],
    );
  }
}
