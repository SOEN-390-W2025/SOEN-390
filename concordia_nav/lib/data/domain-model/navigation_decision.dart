enum NavigationCase {
  multiStepJourney,
}

class NavigationDecision {
  final NavigationCase navCase;

  /// The page sequence is comprised of any number of "I"'s (for an indoor view)
  /// or "O"'s (for an outdoor view).
  final List<String> pageSequence;

  NavigationDecision({required this.navCase, required this.pageSequence});

  int get pageCount => pageSequence.length;
}
