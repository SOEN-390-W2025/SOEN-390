// ignore_for_file: unused_local_variable, avoid_catches_without_on_clauses

import 'package:flutter/material.dart';
import '../data/domain-model/connection.dart';
import '../data/domain-model/floor_routable_point.dart';
import '../utils/indoor_directions_viewmodel.dart';
import '../utils/building_viewmodel.dart';
import '../utils/indoor_map_viewmodel.dart';

// Model classes moved from the view to the model layer
class NavigationStep {
  final String title;
  final String description;
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
  
  // Derived properties
  late String buildingAbbreviation;
  late String floorPlanPath;
  
  VirtualStepGuideViewModel({
    required this.sourceRoom,
    required this.building,
    required this.floor,
    required this.endRoom,
    required bool isDisability,
    required TickerProvider vsync,
  }) : 
    directionsViewModel = IndoorDirectionsViewModel(),
    buildingViewModel = BuildingViewModel(),
    indoorMapViewModel = IndoorMapViewModel(vsync: vsync),
    disability = isDisability {
      buildingAbbreviation = buildingViewModel.getBuildingAbbreviation(building)!;
      floorPlanPath = 'assets/maps/indoor/floorplans/$buildingAbbreviation$floor.svg';
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
      debugPrint('Error getting SVG dimensions: $e');
    }
  }

  Future<void> initializeRoute() async {
    isLoading = true;
    notifyListeners();
    
    try {
      await directionsViewModel.calculateRoute(
        building,
        floor,
        sourceRoom,
        endRoom,
        disability
      );
      
      if (directionsViewModel.calculatedRoute != null) {
        _generateNavigationSteps();
      }
    } catch (e) {
      debugPrint('Error calculating route: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleDisability() {
    disability = !disability;
    notifyListeners();
    initializeRoute();
  }

  void focusOnCurrentStep(BuildContext context) {
    if (navigationSteps.isEmpty || currentStepIndex >= navigationSteps.length) return;
    
    final step = navigationSteps[currentStepIndex];
    
    if (step.focusPoint != Offset.zero) {
      final Matrix4 matrix = Matrix4.identity()
        ..translate(
          -step.focusPoint.dx * step.zoomLevel + MediaQuery.of(context).size.width / 2,
          -step.focusPoint.dy * step.zoomLevel + MediaQuery.of(context).size.height / 2
        )
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

  void zoomIn() {
    final Matrix4 currentMatrix = indoorMapViewModel.transformationController.value.clone();
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale < maxScale) {
      final Matrix4 zoomedInMatrix = currentMatrix..scale(1.2);
      indoorMapViewModel.animateTo(zoomedInMatrix);
    }
  }

  void zoomOut() {
    final Matrix4 currentMatrix = indoorMapViewModel.transformationController.value.clone();
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale > minScale) {
      final Matrix4 zoomedOutMatrix = currentMatrix..scale(0.8);
      indoorMapViewModel.animateTo(zoomedOutMatrix);
    }
  }

  @override
  void dispose() {
    super.dispose();
    indoorMapViewModel.dispose();
  }

  void _generateNavigationSteps() {
    navigationSteps = [];
    
    if (directionsViewModel.calculatedRoute == null) return;
    
    final route = directionsViewModel.calculatedRoute!;
    
    // Start with initial orientation step
    navigationSteps.add(
      NavigationStep(
        title: 'Start',
        description: 'Begin navigation from ${sourceRoom == yourLocation ? yourLocation : '$buildingAbbreviation ${sourceRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '')}'}',
        focusPoint: directionsViewModel.startLocation,
        zoomLevel: 1.3,
        icon: Icons.my_location,
      )
    );
    
    // Add steps from first indoor portion to connection
    if (route.firstIndoorPortionToConnection != null && 
        route.firstIndoorPortionToConnection!.length > 1) {
      _addDirectionalSteps(route.firstIndoorPortionToConnection!);
    }
    
    // Add connection step
    if (route.firstIndoorConnection != null) {
      String actionText = '';
      
      if (route.firstIndoorConnection!.name.toLowerCase().contains('elevator')) {
        actionText = 'Take the elevator';
      } else if (route.firstIndoorConnection!.name.toLowerCase().contains('stair')) {
        actionText = 'Use the stairs';
      } else if (route.firstIndoorConnection!.name.toLowerCase().contains('escalator')) {
        actionText = 'Take the escalator';
      } else {
        actionText = 'Use ${route.firstIndoorConnection!.name}';
      }
      
      navigationSteps.add(
        NavigationStep(
          title: route.firstIndoorConnection!.name,
          description: '$actionText ${route.firstIndoorConnection!.isAccessible ? '(accessible)' : 'to continue your route'}',
          focusPoint: _getConnectionFocusPoint(route.firstIndoorConnection!),
          zoomLevel: 1.2,
          icon: route.firstIndoorConnection!.name.toLowerCase().contains('elevator') 
              ? Icons.elevator 
              : Icons.stairs,
        )
      );
    }
    
    // Add steps from first connection to second connection or destination
    if (route.firstIndoorPortionFromConnection != null && 
        route.firstIndoorPortionFromConnection!.length > 1) {
      _addDirectionalSteps(route.firstIndoorPortionFromConnection!);
    }
    
    // Handle second building if applicable
    if (route.secondBuilding != null) {
      navigationSteps.add(
        NavigationStep(
          title: 'Building Transition',
          description: 'You are now entering ${route.secondBuilding!.name} building',
          focusPoint: Offset.zero, // This would need actual building transition point
          zoomLevel: 1.0,
          icon: Icons.business,
        )
      );
      
      // Add second building navigation steps
      if (route.secondIndoorPortionToConnection != null && 
          route.secondIndoorPortionToConnection!.length > 1) {
        _addDirectionalSteps(route.secondIndoorPortionToConnection!);
      }
      
      if (route.secondIndoorConnection != null) {
        navigationSteps.add(
          NavigationStep(
            title: route.secondIndoorConnection!.name,
            description: 'Use ${route.secondIndoorConnection!.name} ${route.secondIndoorConnection!.isAccessible ? '(accessible)' : ''}',
            focusPoint: _getConnectionFocusPoint(route.secondIndoorConnection!),
            zoomLevel: 1.2,
            icon: route.secondIndoorConnection!.name.toLowerCase().contains('elevator') 
                ? Icons.elevator 
                : Icons.stairs,
          )
        );
      }
      
      if (route.secondIndoorPortionFromConnection != null && 
          route.secondIndoorPortionFromConnection!.length > 1) {
        _addDirectionalSteps(route.secondIndoorPortionFromConnection!);
      }
    }
    
    // Add final arrival step
    navigationSteps.add(
      NavigationStep(
        title: 'Destination',
        description: 'You have reached your destination: ${endRoom == yourLocation
                ? yourLocation
                : '$buildingAbbreviation ${endRoom.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '')}'}',
        focusPoint: directionsViewModel.endLocation,
        zoomLevel: 1.3,
        icon: Icons.place,
      )
    );
    
    // Ensure we have at least one step
    if (navigationSteps.isEmpty) {
      navigationSteps.add(
        NavigationStep(
          title: 'Navigate to Destination',
          description: 'Follow the highlighted path to your destination',
          focusPoint: directionsViewModel.endLocation,
          zoomLevel: 1.0,
          icon: Icons.directions,
        )
      );
    }
    
    notifyListeners();
  }
  
  void _addDirectionalSteps(List<FloorRoutablePoint> points) {
    // Skip if there are too few points to create meaningful steps
    if (points.length < 3) return;
    
    // Track current direction to detect turns
    final String currentDirection = _getInitialDirection(points);
    Offset previousPoint = Offset(points[0].positionX, points[0].positionY);
    
    // Create a list to store significant turns
    final List<TurnPoint> turnPoints = [];
    
    // Identify turn points by looking at direction changes
    for (int i = 1; i < points.length - 1; i++) {
      final currentPoint = Offset(points[i].positionX, points[i].positionY);
      final nextPoint = Offset(points[i + 1].positionX, points[i + 1].positionY);
      
      // Calculate the previous and next segments' directions
      final prevDirection = _getDirectionBetweenPoints(previousPoint, currentPoint);
      final nextDirection = _getDirectionBetweenPoints(currentPoint, nextPoint);
      
      // If there's a significant turn (direction change), add it to turn points
      if (prevDirection != nextDirection) {
        final turnType = _getTurnType(prevDirection, nextDirection);
        if (turnType != 'Continue straight') {
          turnPoints.add(
            TurnPoint(
              point: currentPoint,
              turnInstruction: turnType,
              index: i
            )
          );
        }
      }
      
      previousPoint = currentPoint;
    }
    
    // Add steps for each significant turn (limit to reasonable number)
    int lastAddedIndex = -1;
    for (int i = 0; i < turnPoints.length; i++) {
      final turn = turnPoints[i];
      
      // Skip if too close to last added step (prevents redundant instructions)
      if (turn.index - lastAddedIndex < 3) continue;
      
      IconData icon;
      if (turn.turnInstruction.contains('right')) {
        icon = Icons.turn_right;
      } else if (turn.turnInstruction.contains('left')) {
        icon = Icons.turn_left;
      } else if (turn.turnInstruction.contains('U-turn')) {
        icon = Icons.u_turn_right;
      } else {
        icon = Icons.straight;
      }
      
      navigationSteps.add(
        NavigationStep(
          title: turn.turnInstruction,
          description: '${turn.turnInstruction} and continue walking',
          focusPoint: turn.point,
          zoomLevel: 1.2,
          icon: icon,
        )
      );
      
      lastAddedIndex = turn.index;
    }
    
    // Add "Continue walking" steps at reasonable intervals if no turns
    if (turnPoints.isEmpty && points.length > 5) {
      final int step = (points.length / 2).floor();
      final midPoint = points[step];
      
      navigationSteps.add(
        NavigationStep(
          title: 'Continue straight',
          description: 'Continue walking straight along the corridor',
          focusPoint: Offset(midPoint.positionX, midPoint.positionY),
          zoomLevel: 1.1,
          icon: Icons.straight,
        )
      );
    }
  }
  
  String _getInitialDirection(List<FloorRoutablePoint> points) {
    if (points.length < 2) return 'unknown';
    
    final start = Offset(points[0].positionX, points[0].positionY);
    final next = Offset(points[1].positionX, points[1].positionY);
    
    return _getDirectionBetweenPoints(start, next);
  }
  
  String _getDirectionBetweenPoints(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    
    // Determine if movement is more horizontal or vertical
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? 'east' : 'west';
    } else {
      return dy > 0 ? 'south' : 'north';
    }
  }
  
  String _getTurnType(String fromDirection, String toDirection) {
    // Define the clockwise order of directions
    final directions = ['north', 'east', 'south', 'west', 'north'];
    
    // Find indices of the from and to directions
    final fromIndex = directions.indexOf(fromDirection);
    final toIndex = directions.indexOf(toDirection);
    
    // Handle the special case for west to north (which is a right turn)
    if (fromDirection == 'west' && toDirection == 'north') {
      return 'Turn right';
    }
    
    // Calculate the difference
    var diff = toIndex - fromIndex;
    
    // Handle wrap-around
    if (diff == -3) diff = 1;
    if (diff == 3) diff = -1;
    
    // Interpret the turn based on the difference
    if (diff == 0) {
      return 'Continue straight';
    } else if (diff == 1 || diff == -3) {
      return 'Turn right';
    } else if (diff == -1 || diff == 3) {
      return 'Turn left';
    } else {
      return 'Make a U-turn';
    }
  }
  
  Offset _getConnectionFocusPoint(Connection connection) {
    // In a real implementation, you'd get the specific point for the current floor
    final floorKey = floor;
    final points = connection.floorPoints[floorKey];
    
    if (points != null && points.isNotEmpty) {
      return Offset(points.first.positionX, points.first.positionY);
    }
    
    // Fallback to center between start and end
    return Offset(
      (directionsViewModel.startLocation.dx + directionsViewModel.endLocation.dx) / 2,
      (directionsViewModel.startLocation.dy + directionsViewModel.endLocation.dy) / 2
    );
  }
}