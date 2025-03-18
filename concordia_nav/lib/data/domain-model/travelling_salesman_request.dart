import 'location.dart';

class TravellingSalesmanRequest {
  /// A list of Locations to visited and how many seconds need to be spent there, that
  /// do not need to be visited in any particular order. The string must be unique
  /// across all todoLocations and events in the route and can be used to identify the
  /// location in the response.
  List<(String, Location, int)> todoLocations;

  /// A list of events that need to be attended at fixed *local* times. Todo items will
  /// be fit between any gaps.
  List<(String, Location, DateTime, DateTime)> events;

  /// A *local* start time for the route.
  DateTime startTime;

  /// Start location for the route
  Location startLocation;

  TravellingSalesmanRequest(
      this.todoLocations, this.events, this.startTime, this.startLocation);
}
