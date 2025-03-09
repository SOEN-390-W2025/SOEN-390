import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor/bottom_info_widget.dart';
import '../../widgets/indoor/location_info_widget.dart';
import '../../widgets/zoom_buttons.dart';
import 'floor_plan_widget.dart';
import '../../utils/indoor_map_viewmodel.dart';
import 'dart:developer' as dev;

// ignore: must_be_immutable
class IndoorDirectionsView extends StatefulWidget {
  final String building;
  late String endRoom;
  late String sourceRoom;
  final bool isDisability;

  IndoorDirectionsView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.endRoom,
    this.isDisability = false,
  });

  @override
  State<IndoorDirectionsView> createState() => IndoorDirectionsViewState();
}

class IndoorDirectionsViewState extends State<IndoorDirectionsView>
    with SingleTickerProviderStateMixin {
  late bool disability;
  late String from;
  late String to;
  late String buildingAbbreviation;
  late String floorPlanPath;
  static late String realStartRoom;
  static late String realEndRoom;
  late String startFloor;
  late String endFloor;
  late String displayFloor;
  static bool isMultiFloor = false;
  Timer? _timer;

  late IndoorMapViewModel _indoorMapViewModel;
  late IndoorDirectionsViewModel _directionsViewModel;
  late BuildingViewModel _buildingViewModel;

  static const yourLocation = 'Your Location';

  final String regex = r'[^0-9]';

  double width = 1024.0;
  double height = 1024.0;

  @override
  void initState() {
    super.initState();
    _directionsViewModel = IndoorDirectionsViewModel();
    _buildingViewModel = BuildingViewModel();

    _indoorMapViewModel = IndoorMapViewModel(vsync: this);

    disability = widget.isDisability;
    buildingAbbreviation =
        _buildingViewModel.getBuildingAbbreviation(widget.building)!;
    if (widget.sourceRoom != yourLocation) {
      displayFloor = _indoorMapViewModel.extractFloor(widget.sourceRoom);
    } else {
      displayFloor = '1';
    }

    floorPlanPath =
        'assets/maps/indoor/floorplans/$buildingAbbreviation$displayFloor.svg';

    startFloor = _indoorMapViewModel.extractFloor(widget.sourceRoom);
    endFloor = _indoorMapViewModel.extractFloor(widget.endRoom);
    realStartRoom = widget.sourceRoom;
    realEndRoom = widget.endRoom;

    // Check if source and destination are on different floors
    if (startFloor != endFloor) {
      isMultiFloor = true;
      widget.endRoom = 'connection';
    } else {
      isMultiFloor = false;
    }

    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );

    from = realStartRoom;

    if (realStartRoom == yourLocation) {
      from = yourLocation;
    } else if (hasFullRoomName(realStartRoom)) {
      from = realStartRoom;
    } else {
      from = '$buildingAbbreviation $realStartRoom';
    }

    to = hasFullRoomName(realEndRoom)
        ? realEndRoom
        : '$buildingAbbreviation $realEndRoom';

    dev.log('realStartRoom: $realStartRoom, realEndRoom: $realEndRoom');
    dev.log('from: $from, to: $to');
    getSvgSize();

    _initializeRoute();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  Future<void> getSvgSize() async {
    final size = await _directionsViewModel.getSvgDimensions(floorPlanPath);
    if (mounted) {
      // Ensure widget is still mounted before calling setState
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
        displayFloor,
        widget.sourceRoom,
        widget.endRoom,
        disability,

      );

      if (_directionsViewModel.startLocation != Offset.zero &&
          _directionsViewModel.endLocation != Offset.zero) {
        // If you were using Future.delayed before, use Timer instead:
        _timer?.cancel(); // Cancel any existing timer
        _timer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            // Ensure widget is still mounted before proceeding
            final Size viewportSize = Size(width, height);
            _indoorMapViewModel.centerBetweenPoints(
              _directionsViewModel.startLocation,
              _directionsViewModel.endLocation,
              viewportSize,
              padding: 80.0,
            );
          }
        });
      }
      // ignore: avoid_catches_without_on_clauses
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
                  from: from,
                  to: to,
                  building: widget.building,
                  isDisability: disability,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FloorPlanWidget(
                        indoorMapViewModel: _indoorMapViewModel,
                        floorPlanPath: floorPlanPath,
                        viewModel: viewModel,
                        semanticsLabel:
                            'Floor plan of $buildingAbbreviation-$displayFloor',
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
                                final Matrix4 currentMatrix =
                                    _indoorMapViewModel
                                        .transformationController.value
                                        .clone();
                                final double currentScale =
                                    currentMatrix.getMaxScaleOnAxis();
                                if (currentScale < 1.5) {
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
                                final Matrix4 currentMatrix =
                                    _indoorMapViewModel
                                        .transformationController.value
                                        .clone();
                                final double currentScale =
                                    currentMatrix.getMaxScaleOnAxis();
                                if (currentScale > 0.6) {
                                  final Matrix4 zoomedOutMatrix = currentMatrix
                                    ..scale(0.8);
                                  _indoorMapViewModel
                                      .animateTo(zoomedOutMatrix);
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
                  eta: viewModel.eta,
                  isMultiFloor: isMultiFloor,
                  onNextFloor: handleNextFloorPress,
                  onPrevFloor: handlePrevFloorPress,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void handlePrevFloorPress() {
    setState(() {
      if (realStartRoom == yourLocation) {
        widget.sourceRoom = realStartRoom;
        widget.endRoom = 'connection';
      } else {
        widget.sourceRoom = realStartRoom;
        widget.endRoom = yourLocation;
      }

      isMultiFloor = true;

      if (displayFloor != startFloor) {
        displayFloor = startFloor;
        floorPlanPath =
            'assets/maps/indoor/floorplans/$buildingAbbreviation$displayFloor.svg';

        _indoorMapViewModel.setInitialCameraPosition(
          scale: 1.0,
          offsetX: -50.0,
          offsetY: -50.0,
        );

        getSvgSize();
      }
    });

    _initializeRoute();
  }

  void handleNextFloorPress() {
    setState(() {
      if (realEndRoom == yourLocation) {
        widget.sourceRoom = 'connection';
        widget.endRoom = realEndRoom;
      } else {
        widget.sourceRoom = yourLocation;
        widget.endRoom = realEndRoom;
      }

      isMultiFloor = true;

      if (displayFloor != endFloor) {
        displayFloor = endFloor;
        floorPlanPath =
            'assets/maps/indoor/floorplans/$buildingAbbreviation$displayFloor.svg';

        // Reset the state of _indoorMapViewModel instead of recreating it
        _indoorMapViewModel.setInitialCameraPosition(
          scale: 1.0,
          offsetX: -50.0,
          offsetY: -50.0,
        );

        getSvgSize(); // Ensure floor plan dimensions update
      }

    });

    _initializeRoute();
  }
}
