import 'package:flutter/material.dart';
import '../../data/domain-model/poi.dart';
import '../../ui/indoor_location/indoor_step_view.dart';

class BottomInfoWidget extends StatefulWidget {
  final String building;
  final String sourceRoom;
  final String endRoom;
  final bool isDisability;
  final String eta;
  final bool isMultiFloor;
  final VoidCallback? onNextFloor;
  final VoidCallback? onPrevFloor;
  final String distance;
  final POI? selectedPOI;

  const BottomInfoWidget({
    super.key,
    required this.building,
    required this.sourceRoom,
    required this.endRoom,
    required this.isDisability,
    required this.eta,
    required this.isMultiFloor,
    this.onNextFloor,
    this.onPrevFloor,
    required this.distance,
    this.selectedPOI,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BottomInfoWidgetState createState() => _BottomInfoWidgetState();
}

class _BottomInfoWidgetState extends State<BottomInfoWidget> {
  bool isPrevMode = false; // Track button state

  final String yourLocationString = 'Your Location';

  void toggleButton() {
    setState(() {
      isPrevMode = !isPrevMode;
    });

    // Call the respective function
    if (isPrevMode && widget.onPrevFloor != null) {
      widget.onPrevFloor!();
    } else if (!isPrevMode && widget.onNextFloor != null) {
      widget.onNextFloor!();
    }
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
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 25),
                  const SizedBox(width: 8),
                  Text(widget.eta, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.straighten, color: Colors.grey, size: 25),
                  const SizedBox(width: 8),
                  Text(widget.distance, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          if (widget.isMultiFloor)
            ElevatedButton(
              onPressed: toggleButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrevMode
                    ? const Color.fromARGB(
                        255, 109, 108, 108) // Gray for "Prev"
                    : const Color.fromRGBO(146, 35, 56, 1), // Red for "Next"
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              ),
              child: Text(
                isPrevMode ? 'Prev' : 'Next',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ElevatedButton(
            onPressed: isPrevMode
                ? null // Disabled when "Prev" is active
                : () {
                    final String floor = widget.sourceRoom == yourLocationString
                        ? extractFloor(widget.endRoom)
                        : extractFloor(widget.sourceRoom);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VirtualStepGuideView(
                          building: widget.building,
                          sourceRoom: widget.sourceRoom,
                          endRoom: widget.endRoom,
                          isDisability: widget.isDisability,
                          floor: floor,
                          isMultiFloor: widget.isMultiFloor,
                          selectedPOI: widget.selectedPOI,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrevMode
                  ? Colors.grey // Disabled state
                  : const Color.fromRGBO(146, 35, 56, 1), // Active state
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

  String extractFloor(String roomName) {
    if (roomName == yourLocationString) return '1';
    final cleanedRoom = roomName.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');
    if (cleanedRoom.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(cleanedRoom)) {
      return cleanedRoom.length >= 2
          ? cleanedRoom.substring(0, 2)
          : cleanedRoom;
    } else if (cleanedRoom.isNotEmpty &&
        RegExp(r'^[0-9]').hasMatch(cleanedRoom)) {
      return cleanedRoom.substring(0, 1);
    }
    return '1';
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
