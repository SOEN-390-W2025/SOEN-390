import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_segment.dart';
import '../../../widgets/header_guide_widget.dart';

class POIGuide extends StatelessWidget {
  const POIGuide({super.key});

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
                title: "Find Nearby Facilities",
                description: "Find essential services and amenities close to your location",
                assetPath: 'assets/images/guide/poi_1.png',
              ),
              GuideSegment(
                title: "Nearby Search", 
                description: "Find any POIs within radius", 
                assetPath: 'assets/images/guide/poi_2.png'),
              GuideSegment(
                title: "Radius Adjustment", 
                description: "Adjust radius to find and show only facilities within range"),
              GuideSegment(
                title: "Facility Direction", 
                description: "Display direction between your location and a selected facility",
                assetPath: 'assets/images/guide/poi_3.png'),
              GuideSegment(
                title: "Facility Information", 
                description: "Tap on any facility icon to see detail of the facility"),
            ],
          ),
        ),
      ),
    );
  }
}
