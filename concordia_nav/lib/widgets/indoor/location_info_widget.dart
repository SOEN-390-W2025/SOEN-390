import 'package:flutter/material.dart';

import '../../data/domain-model/concordia_building.dart';
import '../../utils/building_viewmodel.dart';
import '../compact_location_search_widget.dart';

class LocationInfoWidget extends StatelessWidget {
  final String from;
  final String to;
  final String building;
  final String floor;

  const LocationInfoWidget({
    super.key,
    required this.from,
    required this.to,
    required this.building,
    required this.floor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Column(
            children: [
            Icon(Icons.radio_button_checked,
                  color: Theme.of(context).primaryColor,
            ),
            const VerticalDottedLine(
              height: 20,
              color: Colors.grey,
              dashHeight: 3,
              dashSpace: 3,
              strokeWidth: 2,
            ),
            const Icon(Icons.location_on, color: Colors.red),
            ]
          ),

          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationBox(context, 'From: $from', true),
                const SizedBox(height: 10),
                _buildLocationBox(context, 'To: $to', false),
              ],
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

  Widget _buildLocationBox(BuildContext context, String text, bool isSource) {

    final toBuildingAbbrev = to.split(' ')[0];
    final ConcordiaBuilding? toBuilding = BuildingViewModel().getBuildingByAbbreviation(toBuildingAbbrev);
    final cleanedTo = to.replaceAll('$toBuildingAbbrev ', '').trim();
    final toFloor = cleanedTo.startsWith(RegExp(r'^[a-zA-Z]'))
    ? cleanedTo.substring(0, 2)
    : cleanedTo[0];

    String fromBuildingAbbrev = toBuildingAbbrev;
    ConcordiaBuilding? fromBuilding = toBuilding;
    String fromFloor = toFloor;
    if (from != 'Your Location') {
      fromBuildingAbbrev = from.split(' ')[0];
      fromBuilding = BuildingViewModel().getBuildingByAbbreviation(fromBuildingAbbrev);
      final cleanedFrom = from.replaceAll('$fromBuildingAbbrev ', '').trim();
      fromFloor = cleanedFrom.startsWith(RegExp(r'^[a-zA-Z]'))
        ? cleanedFrom.substring(0, 2)
        : cleanedFrom[0];
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/ClassroomSelection',
          arguments: {
            'building': isSource
                ? fromBuilding!.name
                : toBuilding!.name,
            'floor': (isSource || from == 'Your Location')
                ? 'Floor $fromFloor'
                : 'Floor $toFloor',
            'currentRoom': isSource
                ? to
                : from,
            'isSource': isSource,
          },
        );
      },
      child: Row(  // Wrap it with Row widget to allow Expanded to work
        children: [
          Expanded(  // Expanded widget now works within Row
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(text, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
