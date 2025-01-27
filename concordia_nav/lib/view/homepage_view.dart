import 'package:flutter/material.dart';
import 'package:concordia_nav/widgets/custom_appbar.dart';
import 'package:concordia_nav/widgets/feature_card.dart';

class HomePage extends StatelessWidget {
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
                  color: Theme.of(context).primaryColor,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureCard(
                  title: 'SGW map',
                  icon: Icon(Icons.map)
                ),
                const SizedBox(width: 20),
                FeatureCard(
                  title: 'LOY map',
                  icon: const Icon(Icons.map),
                ),
              ]
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureCard(
                  title: 'Outdoor directions',
                  icon: const Icon(Icons.maps_home_work),
                ),
                const SizedBox(width: 20),
                FeatureCard(
                  title: 'Next class directions',
                  icon: const Icon(Icons.calendar_today),
                ),
              ]
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FeatureCard(
                  title: 'Indoor directions',
                  icon: const Icon(Icons.meeting_room),
                ),
                const SizedBox(width: 20),
                FeatureCard(
                  title: 'Find nearby facilities',
                  icon: const Icon(Icons.wash),
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}