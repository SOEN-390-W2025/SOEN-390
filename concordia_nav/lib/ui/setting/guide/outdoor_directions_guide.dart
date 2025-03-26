import 'package:flutter/material.dart';

import '../common_app_bart.dart';

class OutdoorDirectionsGuide extends StatelessWidget {
  const OutdoorDirectionsGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Guide"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Outdoor Directions",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                "Get directions between campus buildings or your location",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/outdoor_directions_1.png',
                      width: 150,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Key features:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    "Destination direction",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Display directions between two selected locations",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
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
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    "Multiple transportation route option",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Choose your preferred transportation method",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/outdoor_directions_3.png',
                      width: 300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 6),
                  Text(
                    "Select new location",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Choose your new source or destination to see the direction",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/outdoor_directions_4.png',
                      width: 300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
