// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/domain-model/poi.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../widgets/accessibility_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/indoor/bottom_info_widget.dart';
import '../../widgets/indoor/location_info_widget.dart';
import 'floor_plan_widget.dart';
import '../../utils/indoor_map_viewmodel.dart';
import 'dart:developer' as dev;

class IndoorDirectionsView extends StatefulWidget {
  final String building;
  late String endRoom;
  late String sourceRoom;
  final bool isDisability;
  final bool hideAppBar;
  final bool hideIndoorInputs;
  final POI? selectedPOI;

  IndoorDirectionsView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.endRoom,
    this.isDisability = false,
    this.hideAppBar = false,
    this.hideIndoorInputs = false,
    this.selectedPOI,
  });

  @override
  State<IndoorDirectionsView> createState() => IndoorDirectionsViewState();
}

class IndoorDirectionsViewState extends State<IndoorDirectionsView>
    with SingleTickerProviderStateMixin {
  static late bool disability;
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
  bool isPOIOnDifferentFloor = false;
  POI? targetPOI;

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
        _buildingViewModel.getBuildingByName(widget.building)!.abbreviation;

    // If we have a POI passed directly, use its coordinates instead of the room
    if (widget.selectedPOI != null) {
      _handleSelectedPOI();
    } else {
      // Original logic when no POI is provided
      _initializeWithRoomNames();
    }

    _indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );

    getSvgSize();
    _initializeRoute();

    // Initialize multi-floor view if needed
    if (isMultiFloor) {
      if (realStartRoom == yourLocation) {
        handleNextFloorPress();
      } else if (isPOIOnDifferentFloor && displayFloor == startFloor) {
        // If we're on the start floor and need to go to a POI on a different floor
        handlePrevFloorPress();
      }
    }
  }

  // Enhanced method to handle POI-based initialization
  void _handleSelectedPOI() {
    targetPOI = widget.selectedPOI!;

    // Extract floor information
    startFloor = _indoorMapViewModel.extractFloor(widget.sourceRoom);
    endFloor = targetPOI!.floor;

    // Determine if we're dealing with a multi-floor scenario
    isPOIOnDifferentFloor = startFloor != endFloor;
    isMultiFloor = isPOIOnDifferentFloor;

    // Set the initial display floor based on source
    if (widget.sourceRoom.trim().toLowerCase() == 'your location') {
      // Start with the POI's floor when coming from "Your Location"
      displayFloor = endFloor;
    } else {
      // Otherwise start with the source floor
      displayFloor = startFloor;
    }

    // Update the floor plan path
    floorPlanPath =
        'assets/maps/indoor/floorplans/$buildingAbbreviation$displayFloor.svg';

    // Set up the real room references
    realStartRoom = widget.sourceRoom;
    realEndRoom =
        '${targetPOI!.buildingId} ${targetPOI!.floor}${targetPOI!.name}';

    // If multi-floor, set the appropriate end room for the current floor view
    if (isPOIOnDifferentFloor) {
      // If we're on the starting floor, we need to navigate to the connection point
      if (displayFloor == startFloor) {
        widget.endRoom = 'connection';
      }
      // If we're on the destination floor, we need to navigate from the connection to the POI
      else if (displayFloor == endFloor) {
        widget.sourceRoom = 'connection';
        widget.endRoom = targetPOI!.name;
      }
    } else {
      // If same floor, just navigate directly to the POI
      widget.endRoom = targetPOI!.name;
    }

    // Set up display names for the UI
    from = realStartRoom;
    if (realStartRoom == yourLocation) {
      from = yourLocation;
    } else if (hasFullRoomName(realStartRoom)) {
      from = realStartRoom;
    } else {
      from = '$buildingAbbreviation $realStartRoom';
    }

    to = '${targetPOI!.name} (${targetPOI!.buildingId} ${targetPOI!.floor})';

    dev.log('IndoorDirectionsView with POI: from: $from, to: $to');
    dev.log(
        'Multi-floor POI navigation: $isPOIOnDifferentFloor, display floor: $displayFloor');
  }

  // Original initialization logic moved to a separate method
  void _initializeWithRoomNames() {
    // extractFloor() returns "1" for "main entrance" or "Your Location"
    startFloor = _indoorMapViewModel.extractFloor(widget.sourceRoom);
    endFloor = _indoorMapViewModel.extractFloor(widget.endRoom);

    if (widget.sourceRoom.trim().toLowerCase() != 'your location') {
      displayFloor = _indoorMapViewModel.extractFloor(widget.sourceRoom);
    } else {
      displayFloor = _indoorMapViewModel.extractFloor(widget.endRoom);
    }

    floorPlanPath =
        'assets/maps/indoor/floorplans/$buildingAbbreviation$displayFloor.svg';

    realStartRoom = widget.sourceRoom;
    realEndRoom = widget.endRoom;

    // Check if source and destination are on different floors
    if (startFloor != endFloor) {
      isMultiFloor = true;
      widget.endRoom = 'connection';
    } else {
      isMultiFloor = false;
    }

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

    dev.log(
        'IndoorDirectionsView: realStartRoom: $realStartRoom, realEndRoom: $realEndRoom');
    dev.log('IndoorDirectionsView: from: $from, to: $to');
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
      setState(() {
        width = size.width;
        height = size.height;
      });
    }
  }

  Future<void> _initializeRoute() async {
    try {
      // Enhanced routing initialization with better POI support
      await _directionsViewModel.calculateRoute(
        widget.building,
        displayFloor,
        widget.sourceRoom,
        widget.endRoom,
        disability,
        destinationPOI: displayFloor == endFloor ? widget.selectedPOI : null,
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
      child:
          Consumer<IndoorDirectionsViewModel>(builder: (context, viewModel, _) {
        return Scaffold(
          appBar: (widget.hideAppBar)
              ? null
              : customAppBar(context, 'Indoor Directions'),
          body: Semantics(
            label: 'Get information on floor plans, routes, and travel time.',
            child: Column(
              children: [
                Visibility(
                  visible: !widget.hideIndoorInputs,
                  child: LocationInfoWidget(
                      from: from,
                      to: to,
                      building: widget.building,
                      isDisability: disability,
                      isPOI: widget.selectedPOI != null),
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
                            _initializeRoute();
                          },
                        ),
                      ),
                      if (isPOIOnDifferentFloor)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Floor $displayFloor',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                BottomInfoWidget(
                  building: widget.building,
                  sourceRoom: realStartRoom,
                  endRoom: realEndRoom,
                  isDisability: disability,
                  eta: viewModel.eta,
                  distance: viewModel.distance,
                  isMultiFloor: isMultiFloor,
                  onNextFloor: handleNextFloorPress,
                  onPrevFloor: handlePrevFloorPress,
                  selectedPOI: widget.selectedPOI,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void handleNextFloorPress() {
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

  void handlePrevFloorPress() {
    setState(() {
      widget.sourceRoom = 'connection';
      widget.endRoom = realEndRoom;

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
