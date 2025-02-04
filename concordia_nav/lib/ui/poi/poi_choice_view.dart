import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';
import 'poi_map_view.dart';
import '../../widgets/search_bar.dart';
import 'poi_box.dart';

class POIChoiceView extends StatelessWidget {
  const POIChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Nearby Facilities'),
      body: Center(
        child: Column(
          children: [
            Positioned(
              top: 10,
              left: 15,
              right: 15,
              child: SearchBarWidget(controller: TextEditingController(),) ,
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Select a nearby facility',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            // Restrooms and Elevators
            const SizedBox(height: 20),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PoiBox(
                    title: 'Restrooms',
                    icon: const Icon(Icons.wc_outlined),
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const POIMapView()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  PoiBox(
                    title: 'Elevators',
                    icon: const Icon(Icons.elevator_outlined),
                    onPress: () {
                      // TODO: Implement the elevators choice.
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Staircases and Emergency Exits
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PoiBox(
                    title: 'Staircases',
                    icon: const Icon(Icons.stairs_outlined),
                    onPress: () {
                      // TODO: Implement staircases choice
                    },
                  ),
                  const SizedBox(width: 20),
                  PoiBox(
                    title: 'Emergency Exit',
                    icon: const Icon(Icons.directions_run_outlined),
                    onPress: () {
                      // TODO: Implement emergency exits choice
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Health centers and Lost and Found
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PoiBox(
                    title: 'Health centers',
                    icon: const Icon(Icons.local_hospital_outlined),
                    onPress: () {
                      // TODO: Implement Health centers choice
                    },
                  ),
                  const SizedBox(width: 20),
                  PoiBox(
                    title: 'Lost and Found',
                    icon: const Icon(Icons.archive_outlined),
                    onPress: () {
                      // TODO: Implement lost and found choice
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Food and Drink
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PoiBox(
                    title: 'Food & Drink',
                    icon: const Icon(Icons.food_bank_outlined),
                    onPress: () {
                      // TODO: Implement food and drink choice
                    },
                  ),
                  const SizedBox(width: 20),
                  PoiBox(
                    title: 'Others',
                    icon: const Icon(Icons.more_outlined),
                    onPress: () {
                      // TODO: Implement others choice
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