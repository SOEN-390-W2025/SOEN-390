import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_segment.dart';
import '../../../widgets/header_guide_widget.dart';

class IndoorDirectionsGuide extends StatelessWidget {
  const IndoorDirectionsGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Guide"),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderGuide(
                title: "Indoor Directions", 
                description: "Navigate inside buildings with floor plans", 
                assetPath: 'assets/images/guide/indoor_directions_1.png'),
              GuideSegment(
                title: "Room Finder", 
                description: "Quickly find any available classroom, lab, or office within a building",
                assetPath: 'assets/images/guide/indoor_directions_2.png'),
              GuideSegment(
                title: "Room Navigation", 
                description: "Navigate between different floors",
                assetPath: 'assets/images/guide/indoor_directions_3.png'),
              GuideSegment(
                title: "Virtual Step Guide", 
                description: "Clear step-by-step guide to the destination room",
                assetPath: 'assets/images/guide/indoor_directions_4.png'),
            ],
          ),
        ),
      ),
    );
  }
}
