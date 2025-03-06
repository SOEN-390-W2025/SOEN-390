import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/zoom_buttons.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String room;
  final String currentLocation;

  const IndoorDirectionsView(
      {super.key,
      required this.currentLocation,
      required this.building,
      required this.floor,
      required this.room});

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView>
    with SingleTickerProviderStateMixin {
  String _selectedMode = 'Walking';
  final String _eta = '5 min';

  late String buildingAbbreviation;
  late String roomNumber;

  late IndoorMapViewModel _indoorMapViewModel;

  late String floorPlanPath;

  @override
  void initState() {
    super.initState();
    buildingAbbreviation =
        BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.room.replaceFirst(widget.floor, '');
    // floorPlanPath = 'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg';
    // Hardcoding a default selected floor for testing
    floorPlanPath = 'assets/maps/indoor/floorplans/hall1.svg';

    _indoorMapViewModel = IndoorMapViewModel(vsync: this);

    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );
  }

  @override
  void dispose() {
    _indoorMapViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'From: ${widget.currentLocation}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'To: $buildingAbbreviation ${widget.room}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
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
          ),
          Expanded(
            child: Stack(
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
                                'Floor plan of $buildingAbbreviation-${widget.floor}',
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
                Positioned(
                  top: 16,
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
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
                  onPressed: () {
                    // TODO: incorporate "start navigation" functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 10),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
