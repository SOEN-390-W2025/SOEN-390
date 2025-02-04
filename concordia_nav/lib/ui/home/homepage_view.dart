import 'package:flutter/material.dart';
import '../campus_map/campus_map_view.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/feature_card.dart';
import '../../../data/domain-model/campus.dart';
import '../indoor_map/indoor_map_view.dart';
import '../poi/poi_choice_view.dart';
import '../indoor_location/indoor_location_view.dart';
import '../outdoor_location/outdoor_selection_view.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// The home page of the app, which displays a list of features
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Home'),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 40.0),
                const SizedBox(width: 10),
                Text(
                  'Concordia Campus Guide',
                  style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // SGW and LOY maps
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeatureCard(
                    title: 'SGW map',
                    icon: const Icon(Icons.map),
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CampusMapPage(campus: Campus.sgw)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'LOY map',
                    icon: const Icon(Icons.map),
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CampusMapPage(campus: Campus.loy)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Outdoor directions and Next class directions
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeatureCard(
                    title: 'Outdoor directions',
                    icon: const Icon(Icons.maps_home_work),
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OutdoorSelectionView()
                      ),
                    )
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'Next class directions',
                    icon: const Icon(Icons.calendar_today),
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IndoorLocationView()
                      ),
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Indoor directions and Find nearby facilities
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeatureCard(
                    title: 'Indoor directions',
                    icon: const Icon(Icons.meeting_room),
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IndoorMapView()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'Find nearby facilities',
                    icon: const Icon(Icons.wash),
                    onPress: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const POIChoiceView()
                      ),
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
