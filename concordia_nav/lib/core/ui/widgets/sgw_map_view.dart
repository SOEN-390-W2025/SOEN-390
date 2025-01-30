import 'package:concordia_nav/core/ui/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:concordia_nav/core/ui/widgets/custom_appbar.dart';
import 'package:concordia_nav/core/ui/widgets/map_controls.dart';

class SgwMapPage extends StatefulWidget {
  const SgwMapPage({super.key});

  @override
  State<SgwMapPage> createState() => SgwMapPageState();
}

class SgwMapPageState extends State<SgwMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'SGW Map'),
      body: Stack(
        children: [
          Placeholder(),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SearchBarWidget(controller: TextEditingController(),) ,
          ),
          Positioned(
            top: 100,
            right: 15,
            child: MapControls(
              onMyLocation: () {}, // Replace with your my location function
              onZoomIn: () {}, // Replace with your zoom in function
              onZoomOut: () {}, // Replace with your zoom out function
            ),
          ),
      ])
    );
  }
}