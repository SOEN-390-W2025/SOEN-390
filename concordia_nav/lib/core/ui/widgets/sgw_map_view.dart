import 'package:flutter/material.dart';
import 'search_bar.dart';
import 'custom_appbar.dart';
import 'map_layout.dart';

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