// ignore_for_file: avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor/bottom_info_widget.dart';
import '../../widgets/indoor/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import 'floor_plan_widget.dart'; // Fixed empty import
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  final String floor;
  final String endRoom;
  final String sourceRoom;
  final bool isDisability;

  const IndoorDirectionsView(
      {super.key,
      required this.sourceRoom,
      required this.building,
      required this.floor,
      required this.endRoom,
      this.isDisability = false});

  @override
  State<IndoorDirectionsView> createState() => _IndoorDirectionsViewState();
}

class _IndoorDirectionsViewState extends State<IndoorDirectionsView>
    with SingleTickerProviderStateMixin {
      
  late bool disability;
  late String from;
  late String to;
  late String buildingAbbreviation;
  late String roomNumber;

  late IndoorMapViewModel _indoorMapViewModel;
  late BuildingViewModel _buildingViewModel;
  late IndoorDirectionsViewModel _directionsViewModel;
  late String floorPlanPath;

  double width = 1024.0;
  double height = 1024.0;
  final double _maxScale = 1.5;
  final double _minScale = 0.6;

  static const yourLocation = 'Your Location';

  @override
  void initState() {
    super.initState();
    _directionsViewModel = IndoorDirectionsViewModel();
    _buildingViewModel = BuildingViewModel();

    _indoorMapViewModel = IndoorMapViewModel(vsync: this);
    disability = widget.isDisability;
    buildingAbbreviation = _buildingViewModel.getBuildingAbbreviation(widget.building)!;
    floorPlanPath = 'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg';
    _getSvgSize();

    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );

    _initializeRoute();
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

  Future<void> _initializeRoute() async {
    try {
      await _directionsViewModel.calculateRoute(
        widget.building,
        widget.floor,
        widget.sourceRoom,
        widget.endRoom,
        disability
      );
      if (_directionsViewModel.startLocation != Offset.zero &&
        _directionsViewModel.endLocation != Offset.zero) {
        // Add a slight delay to ensure the UI has been laid out
        Future.delayed(const Duration(milliseconds: 300), () {
          // Get the actual size of the viewport
          final Size viewportSize = Size(width, height);

          _indoorMapViewModel.centerBetweenPoints(
            _directionsViewModel.startLocation,
            _directionsViewModel.endLocation,
            viewportSize,
            padding: 80.0,
          );
        });
      }
    } catch (e) {
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

  String roomName(String room) {
    return RegExp(r'^[a-zA-Z]{1,2} ').hasMatch(room)
        ? room
        : '$buildingAbbreviation $room';
  }

  static bool hasFullRoomName(String room) {
    return RegExp(r'^[a-zA-Z]{1,2} ').hasMatch(room);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _directionsViewModel,
      child: Consumer<IndoorDirectionsViewModel>(
        builder: (context, viewModel, _) {
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
                  floor: widget.floor,
                  isDisability: disability
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FloorPlanWidget(
                        indoorMapViewModel: _indoorMapViewModel,
                        floorPlanPath: floorPlanPath,
                        viewModel: viewModel,
                        semanticsLabel:
                            'Floor plan of $buildingAbbreviation-${widget.floor}',
                        width: width,
                        height: height,
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: AccessibilityButton(
                          sourceRoom: widget.sourceRoom,
                          endRoom: widget.endRoom,
                          disability: disability,
                          onDisabilityChanged: (value) {
                            disability = !disability;
                            _initializeRoute(); // Recalculate route with new setting
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
                BottomInfoWidget(
                  building: widget.building,
                  floor: widget.floor,
                  sourceRoom: widget.sourceRoom,
                  endRoom: widget.endRoom,
                  isDisability: widget.isDisability,
                  eta: viewModel.eta,
                  distance: viewModel.distance,
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}