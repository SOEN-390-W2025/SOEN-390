import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/floor_button.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import 'floor_plan_widget.dart';
import 'indoor_directions_view.dart';
import 'dart:developer' as dev;

class IndoorLocationView extends StatefulWidget {
  final ConcordiaBuilding building;
  final String? floor;
  final String? room;

  const IndoorLocationView(
      {super.key, required this.building, this.floor = '1', this.room});

  @override
  State<IndoorLocationView> createState() => _IndoorLocationViewState();
}

class _IndoorLocationViewState extends State<IndoorLocationView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _destinationController;

  late IndoorMapViewModel _indoorMapViewModel;

  late String floorPlanPath;
  double width = 1024.0;
  double height = 1024.0;
  bool _floorPlanExists = true;
  bool _isLoading = true;
  late IndoorDirectionsViewModel _directionsViewModel;

  @override
  void initState() {
    super.initState();
    _directionsViewModel = IndoorDirectionsViewModel();
    _indoorMapViewModel = IndoorMapViewModel(vsync: this);
    floorPlanPath =
        'assets/maps/indoor/floorplans/${widget.building.abbreviation}${widget.floor}.svg';
    _checkIfFloorPlanExists();

    _getSvgSize();

    _destinationController = TextEditingController();
    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );
  }

  Future<void> _getSvgSize() async {
    final size = await _directionsViewModel.getSvgDimensions(floorPlanPath);
    if (mounted) {
      setState(() {
        width = size.width;
        height = size.height;
      });
    }
  }

  Future<void> _checkIfFloorPlanExists() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final bool exists = await _indoorMapViewModel.doesAssetExist(floorPlanPath);
    setState(() {
      _floorPlanExists = exists;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _indoorMapViewModel.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log(_floorPlanExists.toString());

    // Extracted body content decision into a separate statement
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_floorPlanExists) {
      bodyContent = Semantics(
        label: 'Indoor location floor plans',
        child: Stack(
          children: [
            FloorPlanWidget(
                indoorMapViewModel: _indoorMapViewModel,
                floorPlanPath: floorPlanPath,
                semanticsLabel:
                    'Floor plan of ${widget.building.abbreviation}-${widget.floor}',
                width: width,
                height: height),
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
              ),
            ),
            if (widget.room != null) _buildFooter(),
          ],
        ),
      );
    } else {
      bodyContent = const Center(
        child: Text(
          'No floor plans exist at this time.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Scaffold(
      appBar: customAppBar(
        context,
        widget.building.name,
      ),
      body: bodyContent,
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
                      endRoom: widget.room!,
                    ),
                  ),
                  (route) {
                    return route.settings.name == '/HomePage' ||
                        route.settings.name == '/CampusMapPage';
                  },
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
