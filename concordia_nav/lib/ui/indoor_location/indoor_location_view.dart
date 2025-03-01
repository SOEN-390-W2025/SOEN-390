import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class IndoorLocationView extends StatelessWidget {
  final String building;
  final String floor;
  final String room;

  const IndoorLocationView({super.key, required this.building, required this.floor, required this.room});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Location'),
      body: Stack (
        children:[
          MapLayout(
            mapWidget: Container(),
          ),
          Text(building + ' ' + floor + ' ' + room),
        ]
      )
    );
  }
}
