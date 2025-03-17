import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_room.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/navigation_decision.dart';

class NavigationDecisionRepository {
  /// Attempts to determine a NavigationDecision for a given list of Locations,
  /// otherwise return null.
  ///
  /// Properly accounts for two-point journeys — specifically the ones related to
  /// getting directions to one's next class — but intends to get extended for
  /// multi-step journeys (see Epic 9 in the backlog for more info).
  static NavigationDecision? determineNavigationDecision(
      List<Location> journeyItems) {
    try {
      switch (journeyItems.length) {
        case 2:
          // Here's where we handle 2-point navigation, with some assumptions
          // about where the source and destination always are in the List.
          final Location source = journeyItems[0];
          final Location destination = journeyItems[1];

          // This next part generates a key for a case and then switches on it.
          // The format is represented by the convention "X-Y-Z" where:
          //
          //   X = 'I' if the source is 'I'ndoor (ConcordiaRoom), else 'O'
          //           (for 'O'utdoor).
          //
          //
          //   Y = 'I' if the destination is 'I'ndoor (ConcordiaRoom) else 'O'.
          //
          //
          //   Z = 'S' if both are 'I'ndoor and in the 'S'ame building,
          //           otherwise 'D' (for 'D'efault).
          //
          // From this key, we determine what the NavigationDecision will be.
          final bool isIndoorSource = source is ConcordiaRoom;
          final bool isIndoorDestination = destination is ConcordiaRoom;
          final bool sameBuilding = isIndoorSource && isIndoorDestination
              ? ((source).floor.building == (destination).floor.building)
              : false;

          final String key =
              "${isIndoorSource ? 'I' : 'O'}-${isIndoorDestination ? 'I' : 'O'}-${sameBuilding ? 'S' : 'D'}";

          switch (key) {
            case "I-I-S":
              return NavigationDecision(
                  navCase: NavigationCase.sameBuildingClassroom, pageCount: 1);
            case "I-I-D":
              return NavigationDecision(
                  navCase: NavigationCase.differentBuildingClassroom,
                  pageCount: 3);
            default:
              return NavigationDecision(
                  navCase: NavigationCase.outdoorToClassroom, pageCount: 2);
          }
        default:
          // Multi-step journeys are to be extended when covering Epic 9.
          return NavigationDecision(
              navCase: NavigationCase.journeyFromSmartPlanner,
              pageCount: journeyItems.length);
      }
    } on Error catch (e) {
      // There's a check in NavigationJourneyPageState to make sure that we have
      // at least 2 Location objs in our list, so this is really to check for
      // some other kind(s) of error(s).
      debugPrint("Error determining navigation decision: $e");
      return null;
    }
  }
}
