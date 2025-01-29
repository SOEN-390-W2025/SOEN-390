import 'package:flutter/material.dart';
import 'package:concordia_nav/core/ui/widgets/custom_appbar.dart';
import 'package:concordia_nav/core/ui/widgets/feature_card.dart';

class SGW_MAP_Page extends StatefulWidget {
  const SGW_MAP_Page({super.key});

  @override
  State<SGW_MAP_Page> createState() => _SGW_MAP_PageState();
}

class _SGW_MAP_PageState extends State<SGW_MAP_Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'SGW Map'),
      body: Center(
        child: Column(
          children: const [
            Text("data")
          ],
        ),
      )
    );
  }
}