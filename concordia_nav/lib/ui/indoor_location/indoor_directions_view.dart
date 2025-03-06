import 'package:flutter/material.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart';
import '../../utils/building_viewmodel.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String room;
  final String currentLocation;

  const IndoorDirectionsView({
    super.key,
    required this.currentLocation,
    required this.building,
    required this.floor,
    required this.room
  });

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView> {
  bool disability = false;
  final String _eta = '5 min';

  late String buildingAbbreviation;
  late String roomNumber;

  @override
  void initState() {
    super.initState();
    buildingAbbreviation = BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.room.replaceFirst( widget.floor, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'From: ${widget.currentLocation}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'To: $buildingAbbreviation ${widget.room}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Placeholder for the map or directions visualization
                const Center(
                  child: Text(
                    'Directions visualization will go here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: AccessibilityButton(
                    disability: disability,
                    onDisabilityChanged: (value) {
                      setState(() {
                        disability = value;
                      });
                    },
                  ),
                ),

                Positioned(
                  top: 76,
                  right: 16,
                  child: Column(
                    children: [
                      ZoomButton(
                        onTap: () {
                          // Handle zoom in
                        },
                        icon: Icons.add,
                        isZoomInButton: true,
                      ),
                      ZoomButton(
                        onTap: () {
                          // Handle zoom out
                        },
                        icon: Icons.remove,
                        isZoomInButton: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'ETA: $_eta',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}