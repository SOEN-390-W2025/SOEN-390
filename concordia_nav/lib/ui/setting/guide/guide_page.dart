import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/guide_card.dart';
import 'campus_map_guide.dart';
import 'indoor_directions_guide.dart';
import 'next_class_directions_guide.dart';
import 'outdoor_directions_guide.dart';
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
                "Explore Campus features",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 4),
              Text(
                "Find your way around campus with these helpful tools",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              GuideCard(
                title: "Campus map",
                description: "View an interactive map of the entire campus",
                icon: Icons.map,
                route: CampusMapGuide(),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Outdoor directions",
                description:
                    "Get directions between campus buildings or your location",
                icon: Icons.maps_home_work,
                route: OutdoorDirectionsGuide(),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Next class directions",
                description: "Quick navigation to your upcoming class",
                icon: Icons.calendar_today,
                route: NextClassDirectionsGuide(),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Indoor directions",
                description:
                    "Navigate inside campus buildings with floor plans and guidance",
                icon: Icons.meeting_room,
                route: IndoorDirectionsGuide(),
              ),
              SizedBox(height: 14),
              GuideCard(
                title: "Find nearby facilities",
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
