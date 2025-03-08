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

// ignore: must_be_immutable
class IndoorDirectionsView extends StatefulWidget {
  final String building;
  String floor;
  late String endRoom;
  late String sourceRoom;
  final bool isDisability;

  IndoorDirectionsView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.floor,
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
  late String roomNumber;
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
    floorPlanPath =
        'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg';

    realStartRoom = widget.sourceRoom;
    realEndRoom = widget.endRoom;

    // Check if source and destination are on different floors
    if (!isMultiFloor && !_isSameFloor(widget.sourceRoom, widget.endRoom)) {
      isMultiFloor = true;
      realStartRoom = widget.sourceRoom;
      widget.endRoom = yourLocation;
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

  bool _isSameFloor(String sourceRoom, String endRoom) {
    // If either sourceRoom or endRoom is "Your Location", return true
    if (sourceRoom == yourLocation || endRoom == yourLocation) {
      return true;
    }

    // Clean the room strings by removing leading alphabetic characters and spaces
    final String cleanSourceRoom =
        sourceRoom.replaceAll(RegExp(r'^[a-zA-Z]+|\s+'), '');
    final String cleanEndRoom =
        endRoom.replaceAll(RegExp(r'^[a-zA-Z]+|\s+'), '');

    return cleanSourceRoom[0] == cleanEndRoom[0];
  }

  Future<void> _initializeRoute() async {
    try {
      await _directionsViewModel.calculateRoute(
        widget.building,
        widget.floor,
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
                  floor: widget.floor,
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
                            'Floor plan of $buildingAbbreviation-${widget.floor}',
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
      widget.sourceRoom = realStartRoom;
      widget.endRoom =
          yourLocation; // Go back to the previous floor's start point

      isMultiFloor = true; // Mark as multi-floor again

      final String newFloor =
          realStartRoom.replaceAll(RegExp(regex), '').isNotEmpty
              ? realStartRoom.replaceAll(RegExp(regex), '').substring(0, 1)
              : widget.floor;

      if (widget.floor != newFloor) {
        widget.floor = newFloor;
        floorPlanPath =
            'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg';

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
      widget.sourceRoom = yourLocation;
      widget.endRoom = realEndRoom;

      isMultiFloor = false;

      final String newFloor =
          realEndRoom.replaceAll(RegExp(regex), '').isNotEmpty
              ? realEndRoom.replaceAll(RegExp(regex), '').substring(0, 1)
              : widget.floor;

      if (widget.floor != newFloor) {
        widget.floor = newFloor;
        floorPlanPath =
            'assets/maps/indoor/floorplans/$buildingAbbreviation${widget.floor}.svg';

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
