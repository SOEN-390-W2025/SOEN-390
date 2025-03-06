import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor/bottom_info_widget.dart';
import '../../widgets/indoor/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String endRoom;
  final String sourceRoom;

  const IndoorDirectionsView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.floor,
    required this.endRoom
  });

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView>
    with SingleTickerProviderStateMixin {
  bool disability = false;
  final String _eta = '5 min';
  late String from;
  late String to;
  late String buildingAbbreviation;
  late String roomNumber;

  late IndoorMapViewModel _indoorMapViewModel;

  late String floorPlanPath;

  @override
  void initState() {
    super.initState();
    buildingAbbreviation = BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.endRoom.replaceFirst( widget.floor, '');

    floorPlanPath = 'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg';

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

  static const yourLocation = 'Your Location';

  static bool hasFullRoomName(String room){
    return RegExp(r'^[a-zA-Z]{1,2} ').hasMatch(room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          LocationInfoWidget(
            from: widget.sourceRoom == yourLocation
              ? yourLocation
              : (hasFullRoomName(widget.sourceRoom)
                ? widget.sourceRoom
                : '$buildingAbbreviation ${widget.sourceRoom}'),
            to: widget.endRoom == yourLocation
              ? yourLocation
              : (hasFullRoomName(widget.endRoom)
                ? widget.endRoom
                : '$buildingAbbreviation ${widget.endRoom}'),
            building: widget.building,
            floor: widget.floor
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
                  child: AccessibilityButton(
                    sourceRoom: widget.sourceRoom,
                    endRoom: widget.endRoom,
                    disability: disability,
                    onDisabilityChanged: (value) {
                      setState(() {
                        disability = value;
                      });
                    },
                  ),
                ),

                Positioned(
                  top: 76,
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

          BottomInfoWidget(eta: _eta),
        ],
      ),
    );
  }
}
