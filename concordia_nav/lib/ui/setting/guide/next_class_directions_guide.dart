import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_segment.dart';
import '../../../widgets/header_guide_widget.dart';

class NextClassDirectionsGuide extends StatelessWidget {
  const NextClassDirectionsGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Guide"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderGuide(
                title: "Next Class Directions", 
                description: "Quick directions to your upcoming classes", 
                assetPath: 'assets/images/guide/next_class_directions_1.png'),
              const GuideSegment(
                title: "Next Class Direction", 
                description: "Display directions between your location and your next class's location"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Card(
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/guide/outdoor_directions_2.png',
                          width: 150,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Card(
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/guide/next_class_directions_2.png',
                          width: 150,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const GuideSegment(
                title: "Automatic Schedule Sync", 
                description: "Your direction is automatically synced with your class timetable"),
              const GuideSegment(
                title: "Real-Time Update", 
                description: "Get a real time update for your next classroom"),
            ],
          ),
        ),
      ),
    );
  }
}
