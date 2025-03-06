import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  final Function? onAppBarActionPressed;

  const HomePage({super.key, this.onAppBarActionPressed});

  /// The home page of the app, which displays a list of features
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          customAppBar(context, 'Home', onActionPressed: onAppBarActionPressed),
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
                    onPress: () => Navigator.pushNamed(
                        context, '/CampusMapPage',
                        arguments: ConcordiaCampus.sgw),
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'LOY map',
                    icon: const Icon(Icons.map),
                    onPress: () => Navigator.pushNamed(
                        context, '/CampusMapPage',
                        arguments: ConcordiaCampus.loy),
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
                      onPress: () => Navigator.pushNamed(
                          context, '/OutdoorLocationMapView',
                          arguments: ConcordiaCampus.sgw)),
                  const SizedBox(width: 20),
                  FeatureCard(
                      title: 'Next class directions',
                      icon: const Icon(Icons.calendar_today),
                      onPress: () =>
                        Navigator.pushNamed(context, '/IndoorDirectionsView',
                          arguments: {
                            'sourceRoom': 'Your Location',
                            'building': 'Hall Building',
                            'floor': '1',
                            'endRoom': 'H 101'
                          }
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
                    onPress: () =>
                        Navigator.pushNamed(context, '/BuildingSelection'),
                  ),
                  const SizedBox(width: 20),
                  FeatureCard(
                      title: 'Find nearby facilities',
                      icon: const Icon(Icons.wash),
                      onPress: () =>
                          Navigator.pushNamed(context, '/POIChoiceView')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
