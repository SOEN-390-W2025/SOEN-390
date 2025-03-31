import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_segment.dart';
import '../../../widgets/header_guide_widget.dart';

class CampusMapGuide extends StatelessWidget {
  const CampusMapGuide({super.key});

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
                title: "Campus Map", 
                description: "Explore the entire campus with our map", 
                assetPath: 'assets/images/guide/campus_map_1.png'),
              GuideSegment(
                title: "Building Information", 
                description: "Tap on any building's marker to see details of the building",
                assetPath: 'assets/images/guide/campus_map_2.png'),
              GuideSegment(
                title: "Search Functionality", 
                description: "Find a specific building", 
                assetPath: 'assets/images/guide/campus_map_3.png'),
            ],
          ),
        ),
      ),
    );
  }
}
