import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_room.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/navigation_decision.dart';
import '../../data/repositories/navigation_decision_repository.dart';
import '../../utils/journey/journey_viewmodel.dart';
import '../../widgets/error_page.dart';
import '../../widgets/journey/navigation_step_page.dart';
import '../indoor_location/indoor_directions_view.dart';
import '../outdoor_location/outdoor_location_map_view.dart';

class NavigationJourneyPage extends StatefulWidget {
  final List<Location> journeyItems;
  final String journeyName;

  final NavigationDecision? decision;

  const NavigationJourneyPage({
    super.key,
    required this.journeyItems,
    required this.journeyName,
    this.decision,
  });

  @override
  State<NavigationJourneyPage> createState() => NavigationJourneyPageState();
}

class NavigationJourneyPageState extends State<NavigationJourneyPage> {
  late NavigationJourneyViewModel viewModel;
  late final Location sourceForNextClass;
  late final ConcordiaRoom destinationForNextClass;

  @override
  void initState() {
    super.initState();

    // A minimum (>= 2) number of Locations must be present within the List.
    if (widget.journeyItems.length < 2) {
      throw Exception("Could not build navigation pages for your next class.");
    }

    viewModel = NavigationJourneyViewModel(
      repository: NavigationDecisionRepository(),
      journeyItems: widget.journeyItems,
      initialDecision: widget.decision,
    );

    sourceForNextClass = widget.journeyItems.first;
    destinationForNextClass = (widget.journeyItems.last as ConcordiaRoom);
  }

  /// Builds the page for a given index of the journeyitems Location List.
  Widget _buildPage(int i) {
    switch (viewModel.decision.navCase) {
      // CASE 1: Source and Destination belong to the same ConcordiaBuilding.
      case NavigationCase.sameBuildingClassroom:
        return IndoorDirectionsView(
          sourceRoom:
              "${(sourceForNextClass as ConcordiaRoom).floor.floorNumber}${(sourceForNextClass as ConcordiaRoom).roomNumber}",
          // either source or destination work here for the building attribute
          // since this is Case 1.
          building: sourceForNextClass.name,
          endRoom:
              "${(destinationForNextClass).floor.floorNumber}${(destinationForNextClass).roomNumber}",
          hideAppBar: true,
          hideIndoorInputs: true,
        );
      // CASE 2: Source and Destination are NOT in the same ConcordiaBuilding.
      case NavigationCase.differentBuildingClassroom:
        switch (i) {
          case 0:
            return IndoorDirectionsView(
              sourceRoom:
                  "${(sourceForNextClass as ConcordiaRoom).floor.floorNumber}${(sourceForNextClass as ConcordiaRoom).roomNumber}",
              building: sourceForNextClass.name,
              endRoom: "Your Location",
              hideAppBar: true,
              hideIndoorInputs: true,
            );
          case 1:
            return OutdoorLocationMapView(
              campus: (destinationForNextClass).campus,
              building: (destinationForNextClass).floor.building,
              hideAppBar: true,
              hideInputs: true,
            );
          case 2:
            return IndoorDirectionsView(
              sourceRoom: "Your Location",
              building: destinationForNextClass.name,
              endRoom:
                  "${(destinationForNextClass).floor.floorNumber}${(destinationForNextClass).roomNumber}",
              hideAppBar: true,
              hideIndoorInputs: true,
            );
          default:
            return ErrorPage(
                message:
                    "Out-of-bounds step index ($i) for differentBuildingClassroom journey.");
        }
      // CASE 3: Source is a non-ConcordiaRoom (labelled an outdoor location).
      case NavigationCase.outdoorToClassroom:
        switch (i) {
          case 0:
            return OutdoorLocationMapView(
              campus: (destinationForNextClass).campus,
              building: (destinationForNextClass).floor.building,
              hideAppBar: true,
              hideInputs: true,
            );
          case 1:
            return IndoorDirectionsView(
              sourceRoom: "Your Location",
              building: destinationForNextClass.name,
              endRoom:
                  "${(destinationForNextClass).floor.floorNumber}${(destinationForNextClass).roomNumber}",
              hideAppBar: true,
              hideIndoorInputs: true,
            );
          default:
            return ErrorPage(
                message:
                    "Out-of-bounds step index ($i) for outdoorToClassroom journey.");
        }
      case NavigationCase.journeyFromSmartPlanner:
        return const ErrorPage(
            message: "You're early... there's nothing here for this yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationStepPage(
      journeyName: widget.journeyName,
      pageCount: viewModel.decision.pageCount,
      pageBuilder: _buildPage,
    );
  }
}
