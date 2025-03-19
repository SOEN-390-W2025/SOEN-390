/*
In theory, these are the different Location-to-Location scenarios we'll need to
take into account for the List provided from the Smart Planner section:

(source: outdoor), (destination: outdoor)
(source: indoor), (destination: outdoor)
(source: indoor), (destination: outdoor)
(source: indoor), (destination: indoor)
(source: different campus), (destination: indoor)
(source different campus), (destination: outdoor)
(source: indoor), (destination: different campus)
(source: outdoor), (destination: different campus)

As of now, the cases addressed are those pertaining to Next Class Directions.
*/
enum NavigationCase {
  sameBuildingClassroom,
  differentBuildingClassroom,
  outdoorToClassroom,
  journeyFromSmartPlanner
}

class NavigationDecision {
  final NavigationCase navCase;
  final int pageCount;

  NavigationDecision({required this.navCase, required this.pageCount});
}
