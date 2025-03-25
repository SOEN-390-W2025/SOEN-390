import '../../data/domain-model/location.dart';
import '../../data/domain-model/navigation_decision.dart';

class NavigationDecisionRepository {
  /// Determines a NavigationDecision given the journey items and page sequence.
  static NavigationDecision? determineNavigationDecision(
      List<Location> journeyItems, List<String> pageSequence) {
    if (journeyItems.length < 2) return null;
    return NavigationDecision(
      navCase: NavigationCase.multiStepJourney,
      pageSequence: pageSequence,
    );
  }
}
