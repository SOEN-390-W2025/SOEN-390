import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/domain-model/travelling_salesman_request.dart';
import '../setting/common_app_bart.dart';

class GeneratedPlanView extends StatelessWidget {
  // Right now, the plan that's getting passed from the "Smart Planner" view
  // to this view is unsorted. ListTile widgets are currently rendered based on
  // the order they appear in the plan. TODO: use TSP logic to optimize plan
  final TravellingSalesmanRequest plan;

  const GeneratedPlanView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    // Formats a duration from seconds to Xh Ym or Xm.
    String formatDuration(int totalSeconds) {
      final hours = totalSeconds ~/ 3600;
      final remainder = totalSeconds % 3600;
      final minutes = remainder ~/ 60;

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    }

    // Events and todoLocations will be merged into a single timeline list
    final timelineItems = <Map<String, dynamic>>[];

    for (final event in plan.events) {
      timelineItems.add({
        'type': 'event',
        'data': event,
      });
    }

    for (final todo in plan.todoLocations) {
      timelineItems.add({
        'type': 'todo',
        'data': todo,
      });
    }

    final tiles = timelineItems.map((item) {
      if (item['type'] == 'event') {
        final event = item['data'];
        final location = event.$2;
        final start = event.$3;
        final end = event.$4;
        return ListTile(
          leading: const Icon(Icons.event),
          title: Text("Event at ${location.name}"),
          subtitle: Text(
            "${timeFormat.format(start.toLocal())} - ${timeFormat.format(end.toLocal())}",
          ),
        );
      } else if (item['type'] == 'todo') {
        final todo = item['data'];
        final location = todo.$2;
        final durationSeconds = todo.$3;
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text("Free-time at ${location.name}"),
          subtitle: Text("Duration: ${formatDuration(durationSeconds)}"),
        );
      } else {
        return const SizedBox();
      }
    }).toList();

    return Scaffold(
      appBar: const CommonAppBar(title: "Generated Plan"),
      body: Padding(
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement directions from generated plan
          },
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
