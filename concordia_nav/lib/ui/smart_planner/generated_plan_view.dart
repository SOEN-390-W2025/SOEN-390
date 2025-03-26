import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/domain-model/location.dart';
import '../setting/common_app_bart.dart';

class GeneratedPlanView extends StatelessWidget {
  final List<(String, Location, DateTime, DateTime)> optimizedRoute;
  final Location startLocation;

  const GeneratedPlanView(
      {super.key, required this.optimizedRoute, required this.startLocation});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    final routeLocations = optimizedRoute.map((stop) => stop.$2).toList();
    final journeyItems = <Location>[startLocation, ...routeLocations];

    final tiles = optimizedRoute.map((stop) {
      final (id, location, start, end) = stop;
      return ListTile(
        leading: const Icon(Icons.place),
        title: Text("Visit ${location.name}"),
        subtitle: Text(
          "${timeFormat.format(start.toLocal())} - ${timeFormat.format(end.toLocal())}",
        ),
      );
    }).toList();

    return Scaffold(
      appBar: const CommonAppBar(title: "Generated Plan"),
      body: Semantics(
        label:
            'Generated plan view with an optimized timeline of events and free locations, including an option to get directions.',
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                "Suggested Plan:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 0.5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tiles,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/NavigationJourneyPage',
            arguments: {
              'journeyName': 'Smart Plan Directions',
              'journeyItems': journeyItems,
            },
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            minimumSize: const Size(150, 40),
          ),
          child: const Text("Get Directions",
              style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
