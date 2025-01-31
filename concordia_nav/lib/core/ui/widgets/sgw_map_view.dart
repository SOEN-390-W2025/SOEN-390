import 'package:concordia_nav/core/ui/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:concordia_nav/core/ui/widgets/custom_appbar.dart';
import 'package:concordia_nav/core/ui/widgets/map_layout.dart';

class SgwMapPage extends StatefulWidget {
  const SgwMapPage({super.key});

  @override
  State<SgwMapPage> createState() => SgwMapPageState();
}

class SgwMapPageState extends State<SgwMapPage> {
  bool isSGW = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSGW
        ? customAppBar(context, 'SGW Map', actionIcon: const Icon(Icons.swap_horiz, color: Colors.white) ,
  onActionPressed: () => setState(() => isSGW = !isSGW),)
        : customAppBar(context, 'LOY Map', actionIcon: const Icon(Icons.swap_horiz, color: Colors.white)),
      body: MapLayout(
        searchController: TextEditingController(),
        onMyLocation: () {},
        onZoomIn: () {},
        onZoomOut: () {}
      )
    );
  }
}