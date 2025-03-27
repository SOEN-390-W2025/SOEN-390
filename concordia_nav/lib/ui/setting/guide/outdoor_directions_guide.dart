import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_segment.dart';
import '../../../widgets/header_guide_widget.dart';

class OutdoorDirectionsGuide extends StatelessWidget {
  const OutdoorDirectionsGuide({super.key});

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
                title: "Outdoor Directions", 
                description: "Get directions between campus buildings or your location", 
                assetPath: 'assets/images/guide/outdoor_directions_1.png'),
              GuideSegment(
                title: "Destination Direction", 
                description: "Display directions between two selected locations",
                assetPath: 'assets/images/guide/outdoor_directions_2.png'),
              GuideSegment(
                title: "Multiple Transportation Route Option", 
                description: "Choose your preferred transportation method",
                assetPath: 'assets/images/guide/outdoor_directions_3.png'),
              GuideSegment(
                title: "Select New Location", 
                description: "Choose a new source or destination to see the direction",
                assetPath: 'assets/images/guide/outdoor_directions_4.png'),
            ],
          ),
        ),
      ),
    );
  }
}
