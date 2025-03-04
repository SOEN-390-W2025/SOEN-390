import 'package:flutter/material.dart';
import '../../utils/building_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_path.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String room;
  final String currentLocation;
  final Offset currentPosition;
  final Offset destinationPosition;

  const IndoorDirectionsView({
    super.key,
    required this.currentLocation,
    required this.building,
    required this.floor,
    required this.room,
    this.currentPosition = const Offset(120, 345),
    this.destinationPosition = const Offset(100, 250),
  });

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView> {
  String _selectedMode = 'Walking';
  final String _eta = '5 min';

  late String buildingAbbreviation;
  late String roomNumber;

  @override
  void initState() {
    super.initState();
    buildingAbbreviation =
        BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.room.replaceFirst(widget.floor, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          _buildLocationInfo(),
          _buildDropdown(),
          Expanded(
            child: Stack(
              children: [
                // Background floor plan
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg',
                    fit: BoxFit.contain,
                  ),
                ),

                // Path and markers
                Positioned.fill(
                  child: CustomPaint(
                    painter: PathPainter(
                      start: widget.currentPosition,
                      end: widget.destinationPosition,
                    ),
                  ),
                ),

                // Current location marker
                Positioned(
                  left: widget.currentPosition.dx-15,
                  top: widget.currentPosition.dy-27,
                  child: const Icon(Icons.location_on, color:Colors.deepOrange, size: 30),
                ),

                // Destination marker
                Positioned(
                  left: widget.destinationPosition.dx-15,
                  top: widget.destinationPosition.dy-27,
                  child: const Icon(Icons.location_on, color: Colors.blueAccent, size: 30),
                ),
              ],
            ),
          ),
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationBox('From: ${widget.currentLocation}'),
                const SizedBox(height: 8),
                _buildLocationBox('To: $buildingAbbreviation ${widget.room}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButton<String>(
        value: _selectedMode,
        onChanged: (String? newValue) {
          setState(() {
            _selectedMode = newValue!;
          });
        },
        items: <String>['Walking', 'Accessibility', 'X']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
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
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(26),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildLocationBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
