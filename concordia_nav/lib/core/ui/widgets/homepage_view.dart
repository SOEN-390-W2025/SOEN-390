import 'package:concordia_nav/core/ui/widgets/sgw_map_view.dart';
import 'package:flutter/material.dart';
import 'package:concordia_nav/core/ui/widgets/custom_appbar.dart';
import 'package:concordia_nav/core/ui/widgets/feature_card.dart';

class HomePage extends StatelessWidget {

  /// The home page of the app, which displays a list of features
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Home'),
      body: Center(
        child: Column(

          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 40.0,
                ),
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
            const SizedBox(height: 30),
            // SGW and LOY maps
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureCard(
                  title: 'SGW map',
                  icon: Icon(Icons.map),
                  onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SGW_MAP_Page())
                  ),
                ),
                const SizedBox(width: 20),
                FeatureCard(
                  title: 'LOY map',
                  icon: const Icon(Icons.map),
                  onPress: () {
                    // TODO: Implement navigation to LOY map
                  },
                ),
              ]
            ),
            SizedBox(height: 10),
            // Outdoor directions and Next class directions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureCard(
                  title: 'Outdoor directions',
                  icon: const Icon(Icons.maps_home_work),
                  onPress: () {
                    // TODO: Implement navigation to Outdoor map
                  },
                ),
                const SizedBox(width: 20),
                FeatureCard(
                  title: 'Next class directions',
                  icon: const Icon(Icons.calendar_today),
                  onPress: () {
                    // TODO: Implement navigation to Next class directions
                  },
                ),
              ]
            ),
            SizedBox(height: 10),
            // Indoor directions and Find nearby facilities
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureCard(
                  title: 'Indoor directions',
                  icon: const Icon(Icons.meeting_room),
                  onPress: () {
                    // TODO: Implement navigation to Indoor map
                  },
                ),
                const SizedBox(width: 20),
                FeatureCard(
                  title: 'Find nearby facilities',
                  icon: const Icon(Icons.wash),
                  onPress: () {
                    // TODO: Implement navigation to POI map
                  },
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}