import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override

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
            const SizedBox(height: 30),
            // SGW and LOY maps
            Row(
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
              ]
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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