import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';

class NextClassDirectionsGuide extends StatelessWidget {
  const NextClassDirectionsGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Guide"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Next Class Directions",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                "Quick directions to your upcoming classes",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/next_class_directions_1.png',
                      width: 150,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Key Features:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    "Next Class Direction",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Display directions between your location and your next class's location",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Card(
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/guide/outdoor_directions_2.png',
                          width: 150,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Card(
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/guide/next_class_directions_2.png',
                          width: 150,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    "Automatic Schedule Sync",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Your direction is automatically synced with your class timetable",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    "Real-Time Update",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Get a real time update for your next classroom",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
