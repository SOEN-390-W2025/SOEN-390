import 'package:flutter/material.dart';
import '../../data/domain-model/concordia_campus.dart';
import '../../data/domain-model/page_specification.dart';
import '../../data/repositories/navigation_decision_repository.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/navigation_decision.dart';
import '../../data/domain-model/concordia_room.dart';
import '../../data/domain-model/concordia_building.dart';
import '../../ui/indoor_location/indoor_directions_view.dart';
import '../../ui/outdoor_location/outdoor_location_map_view.dart';

/// Local-scoped class used for representing the mapping for some adjacent pair.
class PairMapping {
  final String pairType;
  final List<String> keys; // ex. ["I","O","I"]
  PairMapping({required this.pairType, required this.keys});
}

/*
These are the different scenarios that attempt to be accounted for:
(source: outdoor), (destination: outdoor);
(source: indoor), (destination: outdoor);
(source: indoor), (destination: outdoor);
(source: indoor), (destination: indoor);
  Note: where both are in different ConcordiaBuildings;
(source: indoor), (destination: indoor)
  Note: where both are in the same ConcordiaBuilding;
(source: different campus), (destination: indoor);
(source different campus), (destination: outdoor);
(source: indoor), (destination: different campus);
(source: outdoor), (destination: different campus);
*/
/// Returns the key mapping comprised of a pairType and keys for an
/// adjacent pair. The generated keys are handled case-by-case.
PairMapping getPairMapping(Location source, Location destination) {
  switch ((source, destination)) {
    case (final ConcordiaRoom src, final ConcordiaRoom dest)
        when src.floor.building == dest.floor.building:
      return PairMapping(pairType: "RR_same", keys: ["I"]);
    case (ConcordiaRoom _, ConcordiaRoom _):
      return PairMapping(pairType: "RR_diff", keys: ["I", "O", "I"]);
    case (ConcordiaRoom _, ConcordiaBuilding _):
      return PairMapping(pairType: "R-X", keys: ["I", "O"]);
    case (ConcordiaBuilding _, ConcordiaRoom _):
      return PairMapping(pairType: "X-R", keys: ["O", "I"]);
    case (ConcordiaBuilding _, ConcordiaBuilding _):
      return PairMapping(pairType: "X-X", keys: ["O"]);
    case (_, ConcordiaRoom _):
      return PairMapping(pairType: "L-R", keys: ["O", "I"]);
    case (_, ConcordiaBuilding _):
      return PairMapping(pairType: "L-X", keys: ["O"]);
    default:
      return PairMapping(pairType: "default", keys: ["O"]);
  }
}

/// Builds a list of (key, destination) pairs from adjacent locations in the
/// journey.
List<MapEntry<String, Location>> buildOverallSequence(List<Location> items) {
  final List<MapEntry<String, Location>> chain = [];
  if (items.length < 2) return chain;
  for (int i = 0; i < items.length - 1; i++) {
    // The pair mapping is what's going to make it possible to consider all
    // cases.
    final pm = getPairMapping(items[i], items[i + 1]);
    final keys = pm.keys;
    for (final k in keys) {
      chain.add(MapEntry(k, items[i + 1]));
    }
  }
  return chain;
}

/// Converts the total mapping sequence into [PageSpec] objects.
List<PageSpec> buildPageSpecs(
    List<MapEntry<String, Location>> overallSeq, List<Location> journey) {
  final List<PageSpec> specs = [];
  int globalIndex = 0;
  for (int i = 0; i < journey.length - 1; i++) {
    // Indices get shifted by 1 to eventually go through the entire list of
    // journey items and decide what the appropriate keys will be.
    final pm = getPairMapping(journey[i], journey[i + 1]);
    final keys = pm.keys;
    for (int j = 0; j < keys.length; j++) {
      specs.add(PageSpec(
          key: keys[j],
          mappingIndex: globalIndex,
          pairType: pm.pairType,
          source: journey[i],
          destination: journey[i + 1]));
      globalIndex++;
    }
  }
  return specs;
}

/// Builds a page widget from a [PageSpec] by handling how many indoor and
/// outdoor page views should be presented for that specific set.
Widget buildPage(PageSpec spec) {
  const String yourLocationString = "Your Location";

  Widget buildIndoorView(
      {required ConcordiaRoom source, required String endRoom}) {
    return IndoorDirectionsView(
      sourceRoom: "${source.floor.floorNumber}${source.roomNumber}",
      building: source.name,
      endRoom: endRoom,
      hideAppBar: true,
      hideIndoorInputs: true,
    );
  }

  Widget buildArrivalView(ConcordiaRoom room) {
    return IndoorDirectionsView(
      sourceRoom: yourLocationString,
      building: room.name,
      endRoom: "${room.floor.floorNumber}${room.roomNumber}",
      hideAppBar: true,
      hideIndoorInputs: true,
    );
  }

  if (spec.key == "I") {
    final source = spec.source;
    final dest = spec.destination;

    if (["R-X", "RR_diff"].contains(spec.pairType)) {
      if (spec.mappingIndex == 0 && source is ConcordiaRoom) {
        return buildIndoorView(source: source, endRoom: yourLocationString);
      } else if (dest is ConcordiaRoom) {
        return buildArrivalView(dest);
      }
    } else if (spec.pairType == "X-R" && dest is ConcordiaRoom) {
      return buildArrivalView(dest);
    } else if (spec.pairType == "RR_same" && dest is ConcordiaRoom) {
      return buildArrivalView(dest);
    } else if (spec.pairType == "L-R" && dest is ConcordiaRoom) {
      return buildArrivalView(dest);
    }

    if (source is ConcordiaRoom) {
      return buildIndoorView(source: source, endRoom: yourLocationString);
    }
  }

  // If we've reached this point it must mean we need to show directions
  // between two outdoor Locations
  return OutdoorLocationMapView(
    campus: ConcordiaCampus.sgw,
    providedJourneyDest: spec.destination,
    providedJourneyStart: spec.source,
    hideAppBar: true,
    hideInputs: true,
  );
}

class NavigationJourneyViewModel extends ChangeNotifier {
  final NavigationDecisionRepository repository;
  final List<Location> journeyItems;
  late NavigationDecision decision;
  late List<Widget> pages;

  NavigationJourneyViewModel({
    required this.repository,
    required this.journeyItems,
  }) {
    if (journeyItems.length < 2) {
      throw Exception("At least two journey items are required.");
    }
    final overallSeq = buildOverallSequence(journeyItems);
    final specs = buildPageSpecs(overallSeq, journeyItems);
    final pageSequence = specs.map((s) => s.key).toList();
    pages = specs.map((spec) => buildPage(spec)).toList();
    decision = NavigationDecisionRepository.determineNavigationDecision(
            journeyItems, pageSequence) ??
        (throw Exception("Failed to determine navigation decision."));
  }
}
