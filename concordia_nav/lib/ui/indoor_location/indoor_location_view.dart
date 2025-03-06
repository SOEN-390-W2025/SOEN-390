import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../widgets/floor_button.dart';
import '../../widgets/floor_plan_search_widget.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart';
import 'indoor_directions_view.dart';
import 'dart:developer' as dev;

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

  late IndoorMapViewModel _indoorMapViewModel;

  late String floorPlanPath;
  bool _floorPlanExists = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _indoorMapViewModel = IndoorMapViewModel(vsync: this);
    floorPlanPath = 'assets/maps/indoor/floorplans/${widget.building.abbreviation}${widget.floor}.svg';
    _checkIfFloorPlanExists();

    _destinationController = TextEditingController();
    _indoorMapViewModel.setInitialCameraPosition(
        scale: 1.0,
        offsetX: -50.0,
        offsetY: -50.0,
    );
    
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
    return Scaffold(
      appBar: customAppBar(
        context,
        widget.building.name,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _floorPlanExists
        ? Stack(
          children: [
            GestureDetector(
              onDoubleTapDown: (details) {
                final tapPosition = details.localPosition;
                _indoorMapViewModel.panToRegion(
                  offsetX: -tapPosition.dx,
                  offsetY: -tapPosition.dy,
                );
              },
              child: InteractiveViewer(
                constrained: false,
                scaleEnabled: false,
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(50.0),
                transformationController:
                    _indoorMapViewModel.transformationController,
                child: SizedBox(
                  width: 1024,
                  height: 1024,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        floorPlanPath,
                        fit: BoxFit.contain,
                        semanticsLabel:
                            'Floor plan of ${widget.building.abbreviation}-${widget.floor}',
                        placeholderBuilder: (context) => const Center(
                            child: CircularProgressIndicator()),
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Text(
                            'No floor plans exist at this time.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                      final Matrix4 currentMatrix = _indoorMapViewModel
                            .transformationController.value
                            .clone();
                        final Matrix4 zoomedInMatrix = currentMatrix
                          ..scale(1.2);
                        _indoorMapViewModel.animateTo(zoomedInMatrix);
                      },
                      icon: Icons.add,
                      isZoomInButton: true,
                    ),
                  ZoomButton(
                    onTap: () {
                      final Matrix4 currentMatrix = _indoorMapViewModel
                          .transformationController.value
                          .clone();
                      final Matrix4 zoomedOutMatrix = currentMatrix
                        ..scale(0.8);
                      _indoorMapViewModel.animateTo(zoomedOutMatrix);
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
        )
      : const Center(
        child: Text(
          'No floor plans exist at this time.',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
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