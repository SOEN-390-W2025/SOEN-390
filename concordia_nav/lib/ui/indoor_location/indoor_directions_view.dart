import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/domain-model/concordia_floor_point.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor_direction/bottom_info_widget.dart';
import '../../widgets/indoor_direction/indoor_path.dart';
import '../../widgets/indoor_direction/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import '../../utils/building_viewmodel.dart';

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

  double _scale = 1.0;  // Initial scale for zooming
  final double _maxScale = 3.0; // Maximum zoom
  final double _minScale = 0.5; // Minimum zoom

  final TransformationController _transformationController = TransformationController();


  @override
  void initState() {
    super.initState();
    buildingAbbreviation = BuildingViewModel().getBuildingAbbreviation(widget.building)!;
    roomNumber = widget.room.replaceFirst( widget.floor, '');

    _getStartLocation();
    _getEndLocation();
  }

  Future<void> _getStartLocation() async {
    final ConcordiaFloorPoint? startPositionPoint = await IndoorDirectionsViewModel().getElevatorPoint(
      widget.building,
      widget.floor,
    );
    
    if (startPositionPoint != null) {
      // If position point is not null, update the end location
      setState(() {
        startLocation = Offset(startPositionPoint.positionX, startPositionPoint.positionY); // Assuming ConcordiaFloorPoint has x and y
      });
    }
  }

  Future<void> _getEndLocation() async {
    final ConcordiaFloorPoint? endPositionPoint = await IndoorDirectionsViewModel().getPositionPoint(
      widget.building,
      widget.floor,
      widget.room,
    );

    if (endPositionPoint != null) {
      // If position point is not null, update the end location
      setState(() {
        endLocation = Offset(endPositionPoint.positionX, endPositionPoint.positionY); // Assuming ConcordiaFloorPoint has x and y
      });
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
            child: Stack(  // Add Stack to allow positioning of zoom buttons
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
                            startLocation: startLocation,
                            endLocation: endLocation,
                          ),
                          size: Size.infinite, // Important!  Take up all available space.
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