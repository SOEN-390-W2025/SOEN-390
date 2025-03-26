import 'package:flutter/material.dart';
import '../../../widgets/custom_appbar.dart';

class IndoorDirectionsGuide extends StatelessWidget {
  const IndoorDirectionsGuide({super.key});

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
                "Indoor directions",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                "Navigate inside buildings with floor plans",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/indoor_directions_1.png',
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
                    "Room Finder",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Quickly find any available classroom, lab, or office within a building",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/indoor_directions_2.png',
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
                    "Room Navigation",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Navigate between different floors",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/indoor_directions_3.png',
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
                    "Virtual Step Guide",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Clear step-by-step guide to the destination room",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Center(
                child: Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/guide/indoor_directions_4.png',
                      width: 150,
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
