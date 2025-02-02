import 'package:flutter/material.dart';
import 'custom_appbar.dart';
import 'feature_card.dart';
import 'indoor_map_view.dart';

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
                const Icon(
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
            // SGW and LOY maps
            const SizedBox(height: 40),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeatureCard(
                    title: 'SGW map',
                    icon: const Icon(Icons.map),
                    onPress: () {
                      // TODO: Implement navigation to SGW map
                    },
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'LOY map',
                    icon: const Icon(Icons.map),
                    onPress: () {
                      // TODO: Implement navigation to LOY map
                    },
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
                      MaterialPageRoute(builder: (context) => const IndoorMapView()
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'Find nearby facilities',
                    icon: const Icon(Icons.wash),
                    onPress: () {
                      // TODO: Implement navigation to POI map
                    },
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
