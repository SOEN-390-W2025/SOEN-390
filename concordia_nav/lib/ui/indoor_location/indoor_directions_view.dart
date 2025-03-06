import 'package:flutter/material.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor/bottom_info_widget.dart';
import '../../widgets/indoor/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import '../../utils/building_viewmodel.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String endRoom;
  final String sourceRoom;

  const IndoorDirectionsView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.floor,
    required this.endRoom
  });

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView> {
  bool disability = false;
  final String _eta = '5 min';
  late String from;
  late String to;
  late String buildingAbbreviation;
  late String roomNumber;

  @override
  void initState() {
    super.initState();
    buildingAbbreviation = BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.endRoom.replaceFirst( widget.floor, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          LocationInfoWidget(
            from: widget.sourceRoom == 'Your Location'
              ? 'Your Location'
              : (RegExp(r'^[a-zA-Z]{1,2} ').hasMatch(widget.sourceRoom)
                ? widget.sourceRoom
                : '$buildingAbbreviation ${widget.sourceRoom}'),
            to: widget.endRoom == 'Your Location'
              ? 'Your Location'
              : (RegExp(r'^[a-zA-Z]{1,2} ').hasMatch(widget.endRoom)
                ? widget.endRoom
                : '$buildingAbbreviation ${widget.endRoom}'),
            building: widget.building,
            floor: widget.floor
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
                    sourceRoom: widget.sourceRoom,
                    endRoom: widget.endRoom,
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

          BottomInfoWidget(eta: _eta),
        ],
      ),
    );
  }
}