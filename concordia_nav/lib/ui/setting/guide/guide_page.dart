import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_card.dart';
import 'campus_map_guide.dart';
import 'directions_guide.dart';
import 'next_class_directions_guide.dart';
import 'poi_guide.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Guide"),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Explore Campus Features",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 4),
              Text(
                "Find your way around campus with these helpful tools",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              GuideCard(
                title: "Campus Map",
                description: "View an interactive map of the entire campus",
                icon: Icons.map,
                route: CampusMapGuide(),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Outdoor Directions",
                description:
                    "Get directions between campus buildings or your location",
                icon: Icons.maps_home_work,
                route: DirectionsGuide(directionsType: 'Outdoor'),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Next Class Directions",
                description: "Quick navigation to your upcoming class",
                icon: Icons.calendar_today,
                route: NextClassDirectionsGuide(),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Indoor Directions",
                description:
                    "Navigate inside campus buildings with floor plans and guidance",
                icon: Icons.meeting_room,
                route: DirectionsGuide(directionsType: 'Indoor'),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Find Nearby Facilities",
                description:
                    "Discover dining, washrooms, study spaces, and more",
                icon: Icons.wash,
                route: POIGuide(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
