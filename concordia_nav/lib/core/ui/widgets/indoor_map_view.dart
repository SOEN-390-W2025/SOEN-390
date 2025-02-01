import 'package:flutter/material.dart';
import 'custom_appbar.dart';
import 'map_layout.dart';

class IndoorMapView extends StatelessWidget {
  const IndoorMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Map'),
      body: MapLayout(
        searchController: TextEditingController(),
        onMyLocation: () {},
        onZoomIn: () {},
        onZoomOut: () {}
      )
    );
  }
}