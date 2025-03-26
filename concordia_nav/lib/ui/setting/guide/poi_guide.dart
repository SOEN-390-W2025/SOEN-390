import 'package:flutter/material.dart';
import '../common_app_bart.dart';

class POIGuide extends StatelessWidget {
  const POIGuide({super.key});

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
                "Find Nearby Facilities",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                "Find essential services and amenities close to your location",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/poi_1.png',
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
                    "Nearby search",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Find any POIs within radius",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/poi_2.png',
                      width: 200,
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
                    "Radius adjustment",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Adjust radius to find and show only facilities within range",
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
                    "Facility direction",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Display direction between your location and a selected facility",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/poi_3.png',
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
                    "Facility information",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Tap on any facility icon to see detail of the facility",
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
