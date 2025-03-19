import 'package:flutter/material.dart';
import '../../data/repositories/navigation_decision_repository.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/navigation_decision.dart';

class NavigationJourneyViewModel extends ChangeNotifier {
  final NavigationDecisionRepository repository;
  late NavigationDecision decision;

  NavigationJourneyViewModel({
    required this.repository,
    required List<Location> journeyItems,
    // An initialDecision refers to the NavigationDecision that could have been
    // passed from a previous page, like the "Next Class Directions" page.
    NavigationDecision? initialDecision,
  }) {
    if (journeyItems.length < 2) {
      throw Exception("At least two journey items are required.");
    }

    decision = initialDecision ??
        NavigationDecisionRepository.determineNavigationDecision(
            journeyItems) ??
        (throw Exception("Failed to determine navigation decision."));
  }
}
