import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_segment.dart';
import '../../../widgets/header_guide_widget.dart';

class DirectionsGuide extends StatelessWidget {
  final String directionsType;

  const DirectionsGuide({
    super.key,
    required this.directionsType,
  });

  @override
  Widget build(BuildContext context) {
    final String headerTitle;
    final String headerDescription;
    final String headerAsset;
    final List<String> titles;
    final List<String> descriptions;
    final List<String> assets;

    if (directionsType == 'Indoor'){
      headerTitle = "Indoor Directions";
      headerDescription = "Navigate inside buildings with floor plans";
      headerAsset = 'assets/images/guide/indoor_directions_1.png';
      titles = ["Room Finder", "Room Navigation", "Virtual Step Guide"];
      descriptions = [
        "Quickly find any available classroom, lab, or office within a building",
        "Navigate between different floors",
        "Clear step-by-step guide to the destination room"
      ];
      assets = [
        'assets/images/guide/indoor_directions_2.png',
        'assets/images/guide/indoor_directions_3.png',
        'assets/images/guide/indoor_directions_4.png'
      ];
    }
    else {
      headerTitle = "Outdoor Directions";
      headerDescription = "Get directions between campus buildings or your location";
      headerAsset = 'assets/images/guide/outdoor_directions_1.png';
      titles = ["Destination Direction", "Multiple Transportation Route Option", "Select New Location"];
      descriptions = [
        "Display directions between two selected locations",
        "Choose your preferred transportation method",
        "Choose a new source or destination to see the direction"
      ];
      assets = [
        'assets/images/guide/outdoor_directions_2.png',
        'assets/images/guide/outdoor_directions_3.png',
        'assets/images/guide/outdoor_directions_4.png'
      ];
    }

    return Scaffold(
      appBar: customAppBar(context, "Guide"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderGuide(
                title: headerTitle, 
                description: headerDescription, 
                assetPath: headerAsset),
              GuideSegment(
                title: titles[0], 
                description: descriptions[0],
                assetPath: assets[0]),
              GuideSegment(
                title: titles[1], 
                description: descriptions[1],
                assetPath: assets[1]),
              GuideSegment(
                title: titles[2], 
                description: descriptions[2],
                assetPath: assets[2]),
            ],
          ),
        ),
      ),
    );
  }
}