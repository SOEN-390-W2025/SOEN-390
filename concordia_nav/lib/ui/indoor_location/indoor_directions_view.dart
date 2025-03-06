import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../data/domain-model/concordia_floor_point.dart';
import '../../data/domain-model/concordia_floor.dart';
import '../../data/domain-model/indoor_route.dart';
import '../../data/services/indoor_routing_service.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/building_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_direction/bottom_info_widget.dart';
import '../../widgets/indoor_direction/indoor_path.dart';
import '../../widgets/indoor_direction/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import '../../data/domain-model/concrete_floor_routable_point.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String room;
  final String currentLocation;

  const IndoorDirectionsView({
    super.key,
    required this.currentLocation,
    required this.building,
    required this.floor,
    required this.room,
  });

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView> {
  String _selectedMode = 'Walking';
  final String _eta = '5 min';

  late String buildingAbbreviation;
  late String roomNumber;

  late Offset startLocation = Offset.zero;
  late Offset endLocation = Offset.zero;

  IndoorRoute? _calculatedRoute;

  double _scale = 1.0;
  final double _maxScale = 3.0;
  final double _minScale = 0.55;

  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    buildingAbbreviation = BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.room.replaceFirst(widget.floor, '');

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
    _transformationController.dispose();
    super.dispose();
  }

  void _updateTransformation() {
    _transformationController.value = Matrix4.identity()..scale(_scale);
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.1).clamp(_minScale, _maxScale); // Adjust zoom factor
      _updateTransformation();
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.1).clamp(_minScale, _maxScale); // Adjust zoom factor
      _updateTransformation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Indoor Directions'),
      body: Column(
        children: [
          LocationInfoWidget(
            from: widget.currentLocation,
            to: '$buildingAbbreviation ${widget.room}',
          ),
          _buildDropdown(),

          Expanded(
            child: Stack(
              children: [
                InteractiveViewer(
                  constrained: false, // Important!  Allows panning beyond the widget's initial size.
                  scaleEnabled: false, // Disable built-in scaling - using our buttons
                  panEnabled: true, // Enable panning
                  minScale: _minScale,
                  maxScale: _maxScale,
                  transformationController: _transformationController,
                  child: SizedBox(
                    width: 1024,
                    height: 1024,
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg',
                          fit: BoxFit.contain,
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
                Positioned(  // Position zoom buttons
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      ZoomButton(
                        onTap: _zoomIn,
                        icon: Icons.add,
                        isZoomInButton: true,
                      ),
                      ZoomButton(
                        onTap: _zoomOut,
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

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButton<String>(
        value: _selectedMode,
        onChanged: (String? newValue) {
          setState(() {
            _selectedMode = newValue!;
            // Recalculate route when mode changes
            _initializeRouting();
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
    );
  }
}
