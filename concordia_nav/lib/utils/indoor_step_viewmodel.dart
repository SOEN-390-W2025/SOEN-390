// ignore_for_file: unused_local_variable, avoid_catches_without_on_clauses

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../data/domain-model/floor_routable_point.dart';
import '../../data/services/routecalculation_service.dart';
import '../../utils/building_viewmodel.dart';
import '../../utils/indoor_directions_viewmodel.dart';
import '../../utils/indoor_map_viewmodel.dart';
import '../data/domain-model/indoor_route.dart';
import '../data/domain-model/poi.dart';

// Model classes moved from the view to the model layer
class NavigationStep {
  String title;
  String description;
  final Offset focusPoint;
  final double zoomLevel;
  final IconData icon;

  NavigationStep({
    required this.title,
    required this.description,
    required this.focusPoint,
    this.zoomLevel = 1.0,
    this.icon = Icons.directions,
  });
}

class TurnPoint {
  final Offset point;
  final String turnInstruction;
  final int index;

  TurnPoint({
    required this.point,
    required this.turnInstruction,
    required this.index,
  });
}

class VirtualStepGuideViewModel extends ChangeNotifier {
  // Constants
  static const String yourLocation = 'Your Location';
  final double maxScale = 1.5;
  final double minScale = 0.6;

  // Input parameters
  final String sourceRoom;
  final String building;
  final String floor;
  final String endRoom;
  bool disability;
  POI? selectedPOI;

  // Dependencies
  final IndoorDirectionsViewModel directionsViewModel;
  final BuildingViewModel buildingViewModel;
  final IndoorMapViewModel indoorMapViewModel;

  // State variables
  bool isLoading = true;
  int currentStepIndex = 0;
  List<NavigationStep> navigationSteps = [];
  double width = 1024.0;
  double height = 1024.0;

  String measurementUnit = 'Metric';
  List<double> stepDistanceMeters = [];
  List<int> stepTimeSeconds = [];

  // Derived properties
  late String buildingAbbreviation;
  late String floorPlanPath;

  VirtualStepGuideViewModel({
    required this.sourceRoom,
    required this.building,
    required this.floor,
    this.endRoom = '',
    required bool isDisability,
    required TickerProvider vsync,
    this.selectedPOI,
    IndoorDirectionsViewModel? directionsViewModel,
  })  : directionsViewModel =
            directionsViewModel ?? IndoorDirectionsViewModel(),
        buildingViewModel = BuildingViewModel(),
        indoorMapViewModel = IndoorMapViewModel(vsync: vsync),
        disability = isDisability {
    buildingAbbreviation = buildingViewModel.getBuildingAbbreviation(building)!;
    floorPlanPath =
        'assets/maps/indoor/floorplans/$buildingAbbreviation$floor.svg';
    _initializeSvgSize();

    indoorMapViewModel.setInitialCameraPosition(
      scale: 1.0,
      offsetX: -50.0,
      offsetY: -50.0,
    );
  }

  Future<void> _initializeSvgSize() async {
    try {
      final size = await directionsViewModel.getSvgDimensions(floorPlanPath);
      width = size.width;
      height = size.height;
      notifyListeners();
    } catch (e) {
      dev.log('Error getting SVG dimensions: $e');
    }
  }

  Future<void> initializeRoute() async {
    isLoading = true;
    notifyListeners();

    try {
      if (selectedPOI != null) {
        // Use POI for route calculation
        await directionsViewModel.calculateRoute(
            building, floor, sourceRoom, endRoom, disability,
            destinationPOI: selectedPOI);
      } else {
        // Use endRoom for route calculation
        await directionsViewModel.calculateRoute(
            building, floor, sourceRoom, endRoom, disability);
      }

      if (directionsViewModel.calculatedRoute != null) {
        _generateNavigationSteps();
        calculateTimeAndDistanceEstimates();
      }
    } catch (e) {
      dev.log('Error calculating route: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void focusOnCurrentStep(BuildContext context) {
    if (navigationSteps.isEmpty || currentStepIndex >= navigationSteps.length) {
      return;
    }

    final step = navigationSteps[currentStepIndex];

    if (step.focusPoint != Offset.zero) {
      final Matrix4 matrix = Matrix4.identity()
        ..translate(
            -step.focusPoint.dx * step.zoomLevel +
                MediaQuery.of(context).size.width / 2,
            -step.focusPoint.dy * step.zoomLevel +
                MediaQuery.of(context).size.height / 3)
        ..scale(step.zoomLevel);

      indoorMapViewModel.animateTo(matrix);
    }
  }

  void nextStep(BuildContext context) {
    if (currentStepIndex < navigationSteps.length - 1) {
      currentStepIndex++;
      notifyListeners();
      focusOnCurrentStep(context);
    }
  }

  void previousStep(BuildContext context) {
    if (currentStepIndex > 0) {
      currentStepIndex--;
      notifyListeners();
      focusOnCurrentStep(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    indoorMapViewModel.dispose();
  }

  void addConnectionStep(IndoorRoute route) {
    String actionText = '';

    if (route.firstIndoorConnection!.name.toLowerCase().contains('elevator')) {
      actionText = 'Take the elevator';
    } else if (route.firstIndoorConnection!.name
        .toLowerCase()
        .contains('stair')) {
      actionText = 'Use the stairs';
    } else if (route.firstIndoorConnection!.name
        .toLowerCase()
        .contains('escalator')) {
      actionText = 'Take the escalator';
    } else {
      actionText = 'Use ${route.firstIndoorConnection!.name}';
    }

    navigationSteps.add(NavigationStep(
      title: route.firstIndoorConnection!.name,
      description:
          '$actionText ${route.firstIndoorConnection!.isAccessible ? '(accessible)' : 'to continue your route'}',
      focusPoint: RouteCalculationService.getConnectionFocusPoint(
          route.firstIndoorConnection!,
          floor,
          directionsViewModel.startLocation,
          directionsViewModel.endLocation),
      zoomLevel: 1.2,
      icon: route.firstIndoorConnection!.name.toLowerCase().contains('elevator')
          ? Icons.elevator
          : Icons.stairs,
    ));
  }

  String formatRoom(String room) {
    return room.replaceAllMapped(RegExp(r'^S(\d)(\d*)$'), (match) {
      return 'S${match[1]}.${match[2]}';
    });
  }

  String removeBuildingAbbreviation(String room, String buildingAbbreviation) {
    // Ensure the building abbreviation is not in the formatted room string
    final String formattedRoom = formatRoom(room);

    // If the formatted room starts with the building abbreviation, remove it
    if (formattedRoom.startsWith(buildingAbbreviation)) {
      return formattedRoom.substring(buildingAbbreviation.length).trim();
    }

    return formattedRoom;
  }

  void _handleSecondBuilding(IndoorRoute route) {
    navigationSteps.add(NavigationStep(
      title: 'Building Transition',
      description:
          'You are now entering ${route.secondBuilding!.name} building',
      focusPoint:
          Offset.zero, // This would need actual building transition point
      zoomLevel: 1.0,
      icon: Icons.business,
    ));

    // Add second building navigation steps
    if (route.secondIndoorPortionToConnection != null &&
        route.secondIndoorPortionToConnection!.length > 1) {
      _addDirectionalSteps(route.secondIndoorPortionToConnection!);
    }

    if (route.secondIndoorConnection != null) {
      navigationSteps.add(NavigationStep(
        title: route.secondIndoorConnection!.name,
        description:
            'Use ${route.secondIndoorConnection!.name} ${route.secondIndoorConnection!.isAccessible ? '(accessible)' : ''}',
        focusPoint: RouteCalculationService.getConnectionFocusPoint(
            route.secondIndoorConnection!,
            floor,
            directionsViewModel.startLocation,
            directionsViewModel.endLocation),
        zoomLevel: 1.2,
        icon: route.secondIndoorConnection!.name
                .toLowerCase()
                .contains('elevator')
            ? Icons.elevator
            : Icons.stairs,
      ));
    }

    if (route.secondIndoorPortionFromConnection != null &&
        route.secondIndoorPortionFromConnection!.length > 1) {
      _addDirectionalSteps(route.secondIndoorPortionFromConnection!);
    }
  }

  void _generateNavigationSteps() {
    navigationSteps = [];

    if (directionsViewModel.calculatedRoute == null) return;

    final route = directionsViewModel.calculatedRoute!;

    // Start with initial orientation step
    navigationSteps.add(NavigationStep(
      title: 'Start',
      description:
          'Begin navigation from ${sourceRoom == yourLocation ? yourLocation : '$buildingAbbreviation ${removeBuildingAbbreviation(sourceRoom, buildingAbbreviation)}'}',
      focusPoint: directionsViewModel.startLocation,
      zoomLevel: 1.3,
      icon: Icons.my_location,
    ));

    // Add steps from first indoor portion to connection
    if (route.firstIndoorPortionToConnection != null &&
        route.firstIndoorPortionToConnection!.length > 1) {
      _addDirectionalSteps(route.firstIndoorPortionToConnection!);
    }

    // Add connection step
    if (route.firstIndoorConnection != null) {
      addConnectionStep(route);
    }

    // Add steps from first connection to second connection or destination
    if (route.firstIndoorPortionFromConnection != null &&
        route.firstIndoorPortionFromConnection!.length > 1) {
      _addDirectionalSteps(route.firstIndoorPortionFromConnection!);
    }

    // Handle second building if applicable
    if (route.secondBuilding != null) {
      _handleSecondBuilding(route);
    }

    // Add final arrival step - customize for POI if available
    if (selectedPOI != null) {
      navigationSteps.add(NavigationStep(
        title: 'Destination',
        description: 'You have reached ${selectedPOI!.name}',
        focusPoint: directionsViewModel.endLocation,
        zoomLevel: 1.3,
        icon: getPOICategoryIcon(selectedPOI!.category),
      ));
    } else {
      navigationSteps.add(NavigationStep(
        title: 'Destination',
        description:
            'You have reached your destination: ${endRoom == yourLocation ? 'Main Entrance' : '$buildingAbbreviation ${removeBuildingAbbreviation(endRoom, buildingAbbreviation)}'}',
        focusPoint: directionsViewModel.endLocation,
        zoomLevel: 1.3,
        icon: Icons.place,
      ));
    }

    // Ensure we have at least one step
    if (navigationSteps.isEmpty) {
      navigationSteps.add(NavigationStep(
        title: 'Navigate to Destination',
        description: 'Follow the highlighted path to your destination',
        focusPoint: directionsViewModel.endLocation,
        zoomLevel: 1.0,
        icon: Icons.directions,
      ));
    }

    notifyListeners();
  }

  void _addDirectionalSteps(List<FloorRoutablePoint> points) {
    // Skip if there are too few points to create meaningful steps
    if (points.length < 3) return;

    // Track previous point for calculations
    Offset previousPoint = Offset(points[0].positionX, points[0].positionY);

    // Create a list to store significant turns
    final List<TurnPoint> turnPoints = [];

    // Identify turn points by looking at direction changes
    for (int i = 1; i < points.length - 1; i++) {
      final currentPoint = Offset(points[i].positionX, points[i].positionY);
      final nextPoint =
          Offset(points[i + 1].positionX, points[i + 1].positionY);

      // Calculate the previous and next segments' directions (including diagonals)
      final prevDirection =
          RouteCalculationService.getDetailedDirectionBetweenPoints(
              previousPoint, currentPoint);
      final nextDirection =
          RouteCalculationService.getDetailedDirectionBetweenPoints(
              currentPoint, nextPoint);

      // If there's a direction change (including diagonal changes), add it as a turn point
      if (prevDirection != nextDirection) {
        final turnType = RouteCalculationService.getDetailedTurnType(
            prevDirection, nextDirection);

        // Only add meaningful turns (skip "Continue straight" instructions)
        if (turnType != 'Continue straight') {
          turnPoints.add(TurnPoint(
              point: previousPoint, // Use previous point to give advance notice
              turnInstruction: "Prepare to ${turnType.toLowerCase()}",
              index: i - 1));
        }
      }

      previousPoint = currentPoint;
    }

    // Add steps for each significant turn (limit to reasonable number)
    int lastAddedIndex = -1;
    for (int i = 0; i < turnPoints.length; i++) {
      final turn = turnPoints[i];

      // Skip if too close to last added step (prevents redundant instructions)
      if (turn.index - lastAddedIndex < 2) continue;

      final IconData icon =
          RouteCalculationService.getTurnIcon(turn.turnInstruction);
      String description =
          '${turn.turnInstruction} at the upcoming intersection';

      // If this is the last turn point, change the description to reference the classroom
      if (i == turnPoints.length - 1) {
        description = '${turn.turnInstruction} in front of the classroom';
      }

      navigationSteps.add(NavigationStep(
        title: turn.turnInstruction,
        description: description,
        focusPoint: turn.point,
        zoomLevel: 1.2,
        icon: icon,
      ));

      lastAddedIndex = turn.index;
    }
  }

  void calculateTimeAndDistanceEstimates() {
    final route = directionsViewModel.calculatedRoute;
    if (route == null) return;

    // Reset lists
    stepDistanceMeters = List.filled(navigationSteps.length, 0.0);
    stepTimeSeconds = List.filled(navigationSteps.length, 0);

    // Calculate total metrics
    var totalDistanceEstimateMeters = 0.0;
    var totalTimeEstimateMinutes = 0;

    // Calculate for first portion (up to first connection)
    if (route.firstIndoorPortionToConnection != null &&
        route.firstIndoorPortionToConnection!.length > 1) {
      RouteCalculationService.calculateSegmentMetrics(
          route.firstIndoorPortionToConnection,
          onResult: (distanceMeters, timeSeconds) {
        stepDistanceMeters[1] = distanceMeters;
        stepTimeSeconds[1] = timeSeconds;
        totalDistanceEstimateMeters += distanceMeters;
        totalTimeEstimateMinutes += (timeSeconds / 60).ceil();
      });
    }

    // Connection waiting time (e.g., elevator)
    if (route.firstIndoorConnection != null &&
        route.firstIndoorPortionFromConnection != null) {
      final int connectionIndex = navigationSteps.indexWhere(
          (step) => step.title == route.firstIndoorConnection!.name);

      if (connectionIndex >= 0) {
        final int waitTimeSeconds =
            RouteCalculationService.getConnectionWaitTime(
                route.firstIndoorConnection!,
                route.firstIndoorPortionToConnection![0].floor.name,
                route.firstIndoorPortionFromConnection![0].floor.name);

        stepTimeSeconds[connectionIndex] = waitTimeSeconds;
        totalTimeEstimateMinutes += (waitTimeSeconds / 60).ceil();
      }
    }

    notifyListeners();
  }

  // Helper method to get time estimate for current step
  String getCurrentStepTimeEstimate() {
    if (navigationSteps.isEmpty || currentStepIndex >= stepTimeSeconds.length) {
      return "N/A";
    }
    final seconds = stepTimeSeconds[currentStepIndex];
    return RouteCalculationService.formatTime(seconds);
  }

  // Helper method to get distance estimate for current step
  String getCurrentStepDistanceEstimate() {
    if (navigationSteps.isEmpty ||
        currentStepIndex >= stepDistanceMeters.length) {
      return "N/A";
    }
    final meters = stepDistanceMeters[currentStepIndex];
    return RouteCalculationService.formatDistance(
      meters,
      measurementUnit: measurementUnit,
    );
  }

  // Helper method to get appropriate icon for POI category
  IconData getPOICategoryIcon(POICategory category) {
    switch (category) {
      case POICategory.washroom:
        return Icons.wc;
      case POICategory.waterFountain:
        return Icons.water_drop;
      case POICategory.restaurant:
        return Icons.restaurant;
      case POICategory.elevator:
        return Icons.elevator;
      case POICategory.escalator:
        return Icons.escalator;
      case POICategory.stairs:
        return Icons.stairs;
      case POICategory.exit:
        return Icons.exit_to_app;
      case POICategory.police:
        return Icons.local_police;
      case POICategory.other:
      // ignore: unreachable_switch_default
      default:
        return Icons.place;
    }
  }

  // Helper method to get remaining time
  String getRemainingTimeEstimate() {
    if (navigationSteps.isEmpty) return "N/A";

    int remainingSeconds = 0;
    for (int i = currentStepIndex; i < stepTimeSeconds.length; i++) {
      remainingSeconds += stepTimeSeconds[i];
    }

    return RouteCalculationService.formatTime(remainingSeconds);
  }

  // Helper method to get remaining distance
  String getRemainingDistanceEstimate() {
    if (navigationSteps.isEmpty) return "N/A";

    double remainingMeters = 0;
    for (int i = currentStepIndex; i < stepDistanceMeters.length; i++) {
      remainingMeters += stepDistanceMeters[i];
    }

    return RouteCalculationService.formatDistance(
      remainingMeters,
      measurementUnit: measurementUnit,
    );
  }
}
