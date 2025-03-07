import 'package:flutter/material.dart';

import '../../ui/indoor_location/indoor_step_view.dart';

class BottomInfoWidget extends StatelessWidget {
  final String building;
  final String floor;
  final String sourceRoom;
  final String endRoom;
  final bool isDisability;
  final String eta;

  const BottomInfoWidget({
    super.key,
    required this.building,
    required this.floor,
    required this.sourceRoom,
    required this.endRoom,
    required this.isDisability,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
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
                eta,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VirtualStepGuideView(
                    building: building,
                    floor: floor,
                    sourceRoom: sourceRoom,
                    endRoom: endRoom,
                    isDisability: isDisability,
                  ),
                ),
              );
            },
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
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}
