import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../widgets/floor_button.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart';
import 'indoor_directions_view.dart';

class IndoorLocationView extends StatefulWidget {
  final ConcordiaBuilding building;
  final String? floor;
  final String? room;

  const IndoorLocationView({super.key, required this.building, this.floor = '1', this.room});

  @override
  State<IndoorLocationView> createState() => _IndoorLocationViewState();
}

class _IndoorLocationViewState extends State<IndoorLocationView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _destinationController;


@override
void initState() {
  super.initState();
  _destinationController = TextEditingController();
}

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        widget.building.name,
      ),
      body: Stack(
        children: [
          Center(
            child: Text(
              'asset/images/floor_plans/${widget.building.abbreviation}${widget.floor!}',
            )
          ),
          // Search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloorPlanSearchWidget(
                    searchController: _destinationController,
                    building: widget.building,
                    floor: 'Floor ${widget.floor}',
                    disabled: true,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 16,
            child: FloorButton(
              floor: widget.floor!,
              building: widget.building,
            )
          ),
          Positioned(
            top: 140,
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
          if (widget.room != null)
            _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${widget.building.abbreviation} ${widget.room!}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndoorDirectionsView(
                      sourceRoom: 'Your Location',
                      building: widget.building.name,
                      floor: widget.floor!,
                      endRoom: widget.room!,
                    ),
                  ),
                  (route) {
                    return route.settings.name == '/HomePage' || route.settings.name == '/CampusMapPage';
                  }
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
              ),
              child: const Text(
                'Directions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}