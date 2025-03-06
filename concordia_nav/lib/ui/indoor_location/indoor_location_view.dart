import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart';



class IndoorLocationView extends StatefulWidget {
  final ConcordiaBuilding building;
  final String? floor;

  const IndoorLocationView({super.key, required this.building, this.floor = '1'});

  @override
  State<IndoorLocationView> createState() => _IndoorLocationViewState();
}

class _IndoorLocationViewState extends State<IndoorLocationView> {
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
                    building: widget.building.name,
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
            child: InkWell(
              onTap: () {
                // Handle current location
              },
              child: Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1), // Shadow position
                    ),
                  ],
                ),
                child: Text(
                  widget.floor!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
          
        ],
      ),
    );
  }
}
