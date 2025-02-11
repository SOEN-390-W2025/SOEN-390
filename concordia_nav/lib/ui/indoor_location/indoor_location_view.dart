import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/map_layout.dart';

class IndoorLocationView extends StatelessWidget {
  const IndoorLocationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context, 'Indoor Location'),
        body: MapLayout(
          mapWidget: Container(),
        ));
  }
}
