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
    
    // Track previous point for calculations
    Offset previousPoint = Offset(points[0].positionX, points[0].positionY);
    
    // Create a list to store significant turns
    final List<TurnPoint> turnPoints = [];
    
    // Identify turn points by looking at direction changes
    for (int i = 1; i < points.length - 1; i++) {
      final currentPoint = Offset(points[i].positionX, points[i].positionY);
      final nextPoint = Offset(points[i + 1].positionX, points[i + 1].positionY);
      
      // Calculate the previous and next segments' directions (including diagonals)
      final prevDirection = _getDetailedDirectionBetweenPoints(previousPoint, currentPoint);
      final nextDirection = _getDetailedDirectionBetweenPoints(currentPoint, nextPoint);
      
      // If there's a direction change (including diagonal changes), add it as a turn point
      if (prevDirection != nextDirection) {
        final turnType = _getDetailedTurnType(prevDirection, nextDirection);
        
        // Only add meaningful turns (skip "Continue straight" instructions)
        if (turnType != 'Continue straight') {
          turnPoints.add(
            TurnPoint(
              point: previousPoint, // Use previous point to give advance notice
              turnInstruction: "Prepare to ${turnType.toLowerCase()}",
              index: i - 1
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
      if (turn.index - lastAddedIndex < 2) continue;
      
      IconData icon;
      if (turn.turnInstruction.contains('right')) {
        icon = Icons.turn_right;
      } else if (turn.turnInstruction.contains('left')) {
        icon = Icons.turn_left;
      } else if (turn.turnInstruction.contains('diagonal')) {
        // For diagonal turns, use a different icon
        if (turn.turnInstruction.contains('right')) {
          icon = Icons.turn_slight_right;
        } else {
          icon = Icons.turn_slight_left;
        }
      } else if (turn.turnInstruction.contains('U-turn')) {
        icon = Icons.u_turn_right;
      } else {
        icon = Icons.straight;
      }
      
      String description = '${turn.turnInstruction} at the upcoming intersection';
      
      // If this is the last turn point, change the description to reference the classroom
      if (i == turnPoints.length - 1) {
        description = '${turn.turnInstruction} in front of the classroom';
      }
      
      navigationSteps.add(
        NavigationStep(
          title: turn.turnInstruction,
          description: description,
          focusPoint: turn.point,
          zoomLevel: 1.2,
          icon: icon,
        )
      );
      
      lastAddedIndex = turn.index;
    }

  }

  // New helper method for detailed direction detection (including diagonals)
  String _getDetailedDirectionBetweenPoints(Offset point1, Offset point2) {
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;
    
    // Determine primary movement direction
    final double absX = dx.abs();
    final double absY = dy.abs();
    
    // Use a threshold to detect diagonal movement
    // If x and y components are similar in magnitude, it's diagonal
    final bool isDiagonal = absX > 0.3 && absY > 0.3 && absX / absY < 3 && absY / absX < 3;
    
    if (isDiagonal) {
      // Determine which diagonal
      if (dx > 0 && dy > 0) return 'SouthEast';
      if (dx > 0 && dy < 0) return 'NorthEast';
      if (dx < 0 && dy > 0) return 'SouthWest';
      if (dx < 0 && dy < 0) return 'NorthWest';
    }
    
    // For non-diagonal movement
    if (absX > absY) {
      return dx > 0 ? 'East' : 'West';
    } else {
      return dy > 0 ? 'South' : 'North';
    }
  }
  
  String _getDetailedTurnType(String fromDirection, String toDirection) {
    // Define a map of direction changes to turn types
    final Map<String, Map<String, String>> turnTypes = {
      'North': {
        'North': 'Continue straight',
        'East': 'Turn right',
        'West': 'Turn left',
        'South': 'Make a U-turn',
        'NorthEast': 'Turn slight right',
        'NorthWest': 'Turn slight left',
        'SouthEast': 'Turn diagonal right',
        'SouthWest': 'Turn diagonal left',
      },
      'South': {
        'South': 'Continue straight',
        'East': 'Turn left',
        'West': 'Turn right',
        'North': 'Make a U-turn',
        'SouthEast': 'Turn slight left',
        'SouthWest': 'Turn slight right',
        'NorthEast': 'Turn diagonal left',
        'NorthWest': 'Turn diagonal right',
      },
      'East': {
        'East': 'Continue straight',
        'North': 'Turn left',
        'South': 'Turn right',
        'West': 'Make a U-turn',
        'NorthEast': 'Turn slight left',
        'SouthEast': 'Turn slight right',
        'NorthWest': 'Turn diagonal left',
        'SouthWest': 'Turn diagonal right',
      },
      'West': {
        'West': 'Continue straight',
        'North': 'Turn right',
        'South': 'Turn left',
        'East': 'Make a U-turn',
        'NorthWest': 'Turn slight right',
        'SouthWest': 'Turn slight left',
        'NorthEast': 'Turn diagonal right',
        'SouthEast': 'Turn diagonal left',
      },
      
      // Handle diagonal directions too
      'NorthEast': {
        'NorthEast': 'Continue straight',
        'North': 'Turn slight left',
        'East': 'Turn slight right',
        'South': 'Turn diagonal right',
        'West': 'Turn diagonal left',
        'SouthWest': 'Make a U-turn',
        'NorthWest': 'Turn left',
        'SouthEast': 'Turn right',
      },
      'NorthWest': {
        'NorthWest': 'Continue straight',
        'North': 'Turn slight right',
        'West': 'Turn slight left',
        'South': 'Turn diagonal left',
        'East': 'Turn diagonal right',
        'SouthEast': 'Make a U-turn',
        'NorthEast': 'Turn right',
        'SouthWest': 'Turn left',
      },
      'SouthEast': {
        'SouthEast': 'Continue straight',
        'South': 'Turn slight left',
        'East': 'Turn slight right',
        'North': 'Turn diagonal left',
        'West': 'Turn diagonal right',
        'NorthWest': 'Make a U-turn',
        'SouthWest': 'Turn left',
        'NorthEast': 'Turn right',
      },
      'SouthWest': {
        'SouthWest': 'Continue straight',
        'South': 'Turn slight right',
        'West': 'Turn slight left',
        'North': 'Turn diagonal right',
        'East': 'Turn diagonal left',
        'NorthEast': 'Make a U-turn',
        'SouthEast': 'Turn right',
        'NorthWest': 'Turn left',
      },
    };
    
    // Return the turn type if defined, otherwise return a generic "Change direction"
    return turnTypes[fromDirection]?[toDirection] ?? 'Change direction';
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