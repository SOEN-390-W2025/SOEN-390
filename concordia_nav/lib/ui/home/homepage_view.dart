import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/feature_card.dart';
import '../../data/domain-model/location.dart';
import '../../data/repositories/calendar.dart';
import '../../data/services/map_service.dart';
import '../../utils/building_viewmodel.dart';

class HomePage extends StatelessWidget {
  final Function? onAppBarActionPressed;

  const HomePage({super.key, this.onAppBarActionPressed});

  /// The home page of the app, which displays a list of features
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          customAppBar(context, 'Home', onActionPressed: onAppBarActionPressed),
      body: SingleChildScrollView(
        child: Center(
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
              Row(
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
              const SizedBox(height: 20),
              // Outdoor directions and Next class directions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeatureCard(
                      title: 'Outdoor directions',
                      icon: const Icon(Icons.maps_home_work),
                      onPress: () => Navigator.pushNamed(
                          context, '/OutdoorLocationMapView',
                          arguments: {'campus': ConcordiaCampus.sgw})),
                  const SizedBox(width: 20),
                  FeatureCard(
                    title: 'Next class directions',
                    icon: const Icon(Icons.calendar_today),
                    onPress: () async {
                      final buildingViewModel = BuildingViewModel();

                      final nextClassRoom =
                          await CalendarRepository().getNextClassRoom(
                        null,
                        buildingViewModel,
                      );

                      if (nextClassRoom == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("No upcoming classes found.")),
                          );
                        }
                        return;
                      }

                      final MapService mapService = MapService();
                      final position = await mapService.getCurrentLocation();
                      final currentLocation = Location(
                        position!.latitude,
                        position.longitude,
                        "Your Location",
                        "",
                        "",
                        "",
                        "",
                      );

                      if (context.mounted) {
                        await Navigator.pushNamed(
                          context,
                          '/NextClassDirectionsPreview',
                          arguments: [currentLocation, nextClassRoom],
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Indoor directions and Find nearby facilities
              Row(
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
              // TODO: Remove this. Just for testing purposes
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FeatureCard(
                    title: 'Places API Test',
                    icon: const Icon(Icons.science),
                    onPress: () => Navigator.pushNamed(context, '/PlacesTest'),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Added bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
