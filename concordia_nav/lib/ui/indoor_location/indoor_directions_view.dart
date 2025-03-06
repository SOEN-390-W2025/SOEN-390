import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_floor_point.dart';
import '../../data/domain-model/concordia_floor.dart';
import '../../data/domain-model/indoor_route.dart';
import '../../data/services/indoor_routing_service.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor/indoor_path.dart';
import '../../widgets/indoor/bottom_info_widget.dart';
import '../../widgets/indoor/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../../data/domain-model/concrete_floor_routable_point.dart';

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

  late Offset startLocation = Offset.zero;
  late Offset endLocation = Offset.zero;

  IndoorRoute? _calculatedRoute;

  final double _maxScale = 3.0;
  final double _minScale = 0.6;

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

     _initializeRouting();
  }

  Future<void> _initializeRouting() async {
    try {

      final dynamic yamlData = await BuildingViewModel().getYamlDataForBuilding(buildingAbbreviation);
      // Get start location (elevator point)
      final ConcordiaFloorPoint? startPositionPoint = await IndoorDirectionsViewModel()
          .getElevatorPoint(widget.building, widget.floor);
      
      // Get end location (room point)
      final ConcordiaFloorPoint? endPositionPoint = await IndoorDirectionsViewModel()
          .getPositionPoint(widget.building, widget.floor, widget.room);

      if (startPositionPoint != null && endPositionPoint != null) {
        setState(() {
          // Update location points
          startLocation = Offset(startPositionPoint.positionX, startPositionPoint.positionY);
          endLocation = Offset(endPositionPoint.positionX, endPositionPoint.positionY);

          final ConcordiaBuilding buildingData = BuildingViewModel().getBuildingByName(widget.building)!;
          // Create ConcordiaFloor for the current floor
          final currentFloor = ConcordiaFloor(
            widget.floor,
            buildingData
          );

          // Create FloorRoutablePoint for start and end
          final startRoutablePoint = ConcreteFloorRoutablePoint(
            floor: currentFloor,
            positionX: startPositionPoint.positionX,
            positionY: startPositionPoint.positionY,
          );

          final endRoutablePoint = ConcreteFloorRoutablePoint(
            floor: currentFloor,
            positionX: endPositionPoint.positionX,
            positionY: endPositionPoint.positionY,
          );

          // Calculate route based on accessibility mode
          final isAccessible = _selectedMode == 'Accessibility';
          _calculatedRoute = IndoorRoutingService.getIndoorRoute(
            yamlData,
            startRoutablePoint,
            endRoutablePoint,
            isAccessible
          );
        });
      } else {
        _showErrorMessage('Could not find start or end location');
      }
    } on Exception catch (e) {
      _showErrorMessage('Error calculating route: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
                          CustomPaint(
                            painter: IndoorMapPainter(
                              route: _calculatedRoute,
                              startLocation: startLocation,
                              endLocation: endLocation,
                            ),
                            size: Size.infinite,
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
                          final double currentScale = currentMatrix.getMaxScaleOnAxis();
                          if (currentScale < _maxScale) {
                            final Matrix4 zoomedInMatrix = currentMatrix
                              ..scale(1.2);
                            _indoorMapViewModel.animateTo(zoomedInMatrix);
                          }
                        },
                        icon: Icons.add,
                        isZoomInButton: true,
                      ),
                      ZoomButton(
                        onTap: () {
                          final Matrix4 currentMatrix = _indoorMapViewModel
                              .transformationController.value
                              .clone();
                          final double currentScale = currentMatrix.getMaxScaleOnAxis();
                          if (currentScale > _minScale) {
                            final Matrix4 zoomedOutMatrix = currentMatrix
                              ..scale(0.8);
                            _indoorMapViewModel.animateTo(zoomedOutMatrix);
                          }
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