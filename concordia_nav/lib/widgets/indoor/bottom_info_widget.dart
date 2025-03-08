import 'package:flutter/material.dart';

import '../../ui/indoor_location/indoor_step_view.dart';

class BottomInfoWidget extends StatefulWidget {
  final String building;
  final String floor;
  final String sourceRoom;
  final String endRoom;
  final bool isDisability;
  final String eta;
  final String distance;
  final VoidCallback? onNextFloor;
  final VoidCallback? onPrevFloor;

  const BottomInfoWidget({
    super.key,
    required this.building,
    required this.floor,
    required this.sourceRoom,
    required this.endRoom,
    required this.isDisability,
    required this.eta,
    required this.distance,
    this.onNextFloor,
    this.onPrevFloor,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BottomInfoWidgetState createState() => _BottomInfoWidgetState();
}

class _BottomInfoWidgetState extends State<BottomInfoWidget> {
  bool isNextFloorActive = true; // Track the button state (Next/Prev)

  void _toggleFloorButton() {
    setState(() {
      // Toggle between "Next" and "Prev"
      isNextFloorActive = !isNextFloorActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time row
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 25),
                  const SizedBox(width: 8),
                  Text(
                    widget.eta,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Distance row
              Row(
                children: [
                  const Icon(Icons.straighten, color: Colors.grey, size: 25),
                  const SizedBox(width: 8),
                  Text(
                    widget.distance,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Show "Prev"/"Next" button only if both callbacks are provided
              if (widget.onPrevFloor != null && widget.onNextFloor != null)
                ElevatedButton(
                  onPressed: () {
                    if (isNextFloorActive) {
                      widget.onNextFloor?.call();
                    } else {
                      widget.onPrevFloor?.call();
                    }
                    _toggleFloorButton();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  child: Text(
                    isNextFloorActive ? 'Next' : 'Prev',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              if (widget.onNextFloor != null)
                const SizedBox(
                    width: 10), // Add spacing if "Next" button is visible
              // "Start" button (only enabled when "Next" is active)
              ElevatedButton(
                onPressed: isNextFloorActive
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VirtualStepGuideView(
                              building: widget.building,
                              floor: widget.floor,
                              sourceRoom: widget.sourceRoom,
                              endRoom: widget.endRoom,
                              isDisability: widget.isDisability,
                            ),
                          ),
                        );
                      }
                    : null, // Disable button when "Prev" is active
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ],
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
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}
