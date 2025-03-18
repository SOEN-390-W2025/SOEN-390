import 'dart:developer' as dev;

import '../domain-model/location.dart';
import '../domain-model/travelling_salesman_request.dart';
import '../repositories/building_repository.dart';

class TravellingSalesmanService {
  /// Given a TravellingSalesmanRequest, gives a list where each item contains the
  /// event key string, the location to be visited, and the start and end time of being
  /// at that location. There will be sufficient gaps between locations for travel.
  static Future<List<(String, Location, DateTime, DateTime)>> getSalesmanRoute(
      TravellingSalesmanRequest request) async {
    // Copy since these are not value types
    final List<(String, Location, DateTime, DateTime)> events =
        List.from(request.events);
    List<(String, Location, int)> todoLocations =
        List.from(request.todoLocations);

    final List<(String, Location, DateTime, DateTime)> returnRoute = [];

    // Sort the events by startTime so we can start to _fitTodoItems between any gaps.
    // If there are no gaps, don't issue a call to _fitTodoItems.
    events.sort((a, b) => a.$3.compareTo(b.$3));

    // In principle the request start time should be before the start time of the first
    // event, and we will start looking to fill the gap between those times. But if the
    // first event is already underway before the route startTime, we will need to
    // handle that as a special case.
    DateTime lastEndTime = request.startTime;
    Location lastLocation = request.startLocation;
    if (events.isNotEmpty && events[0].$3.compareTo(request.startTime) <= 0) {
      dev.log("TSP: special case where first event underway");
      returnRoute.add(events[0]);
      lastEndTime = events[0].$4;
      lastLocation = events[0].$2;
      events.removeAt(0);
    }

    while (events.isNotEmpty || todoLocations.isNotEmpty) {
      if (events.isNotEmpty) {
        final nextEvent = events.removeAt(0);
        dev.log(
            // ignore: prefer_adjacent_string_concatenation
            "TSP: working on gap starting ${lastEndTime.toIso8601String()}," +
                " ending event ${nextEvent.$1} ${nextEvent.$3.toIso8601String()}");
        final fitItems = await _fitTodoItems(lastEndTime, lastLocation,
            nextEvent.$3, nextEvent.$2, todoLocations);
        // addAll gives buggy behaviour
        returnRoute.addAll(fitItems.$1);
        returnRoute.add(nextEvent);
        // Keep just the hanging items for the next iteration
        lastEndTime = nextEvent.$4;
        lastLocation = nextEvent.$2;
        todoLocations = fitItems.$2;
      } else {
        dev.log(
            // ignore: prefer_interpolation_to_compose_strings
            "TSP: working on last segment starting " +
                lastEndTime.toIso8601String() +
                " and no fixed end");
        final fitItems = await _fitTodoItems(
            lastEndTime, lastLocation, null, null, todoLocations);
        if (fitItems.$2.isNotEmpty) {
          // Because there is no end to the open period, this list should not be empty.
          // If it is, something has gone wrong.
          dev.log("TSP: ERROR with routing, hanging items not empty");
          break;
        }
        returnRoute.addAll(fitItems.$1);
        // As per above, this is assigning an empty list, which satisfies the while
        // condition to end the loop
        todoLocations = fitItems.$2;
      }
    }

    return returnRoute;
  }

  /// Returns the travel time between two locations in seconds. Needs to support indoor
  /// locations (subclasses of locations) via indoor routing and outdoor locations via
  /// outdoor routing.
  static Future<int> _getTravelTime(
      Location origin, Location destination) async {
    if (origin == destination) {
      dev.log("o = d");
      return 0;
    }
    if (origin == BuildingRepository.h &&
        destination == BuildingRepository.mb) {
      dev.log("h and mb");
      return 300;
    }
    dev.log("default 150");
    return 150;
  }

  /// Given an open period (eg. between classes) that starts at one location and time,
  /// and is either unlimited in time or ends at a second location and time, fits todo
  /// items into an optimal order to be visited. Returns one list with the todo items
  /// to be visited in order (with sufficient gaps for travel time), and another list
  /// with any remaining todo items that could not be visited in this period.
  static Future<
          (
            List<(String, Location, DateTime, DateTime)>,
            List<(String, Location, int)>
          )>
      _fitTodoItems(
          DateTime openPeriodStartTime,
          Location openPeriodStartLocation,
          DateTime? openPeriodEndTime,
          Location? openPeriodEndLocation,
          List<(String, Location, int)> todoItems) async {
    // Copy since not a value type
    final List<(String, Location, int)> remainingItems = List.from(todoItems);
    final List<(String, Location, DateTime, DateTime)> returnTodoItems = [];

    Location lastLocation = openPeriodStartLocation;
    DateTime lastEndTime = openPeriodStartTime;
    // Iterate as long as there is time remaining to get to the end location
    while (true) {
      // Find the nearest neighbour from remainingItems to the lastLocation that still
      // allows us to reach the endLocation on time
      dev.log("TSP: starting nearest neighbour search iteration");
      int? nearestNeighbour;
      int? travelTimeToNearestNeighbour;
      for (int i = 0; i < remainingItems.length; i++) {
        final int travelTimeToI =
            await _getTravelTime(lastLocation, remainingItems[i].$2);
        if (travelTimeToNearestNeighbour == null ||
            travelTimeToI < travelTimeToNearestNeighbour) {
          // Check if we can still reach the destination on time adding this location
          dev.log("TSP: remaining todo item $i is a candidate");
          bool canMakeIt = true;
          if (openPeriodEndTime != null && openPeriodEndLocation != null) {
            final DateTime itemIEndTime = lastEndTime
                .add(Duration(seconds: (travelTimeToI + remainingItems[i].$3)));
            final int travelTimeIToEnd = await _getTravelTime(
                remainingItems[i].$2, openPeriodEndLocation);
            if (itemIEndTime
                    .add(Duration(seconds: travelTimeIToEnd))
                    .compareTo(openPeriodEndTime) >
                0) {
              canMakeIt = false;
              dev.log(
                  "TSP: can't make this item $i due to additional travel time");
            }
          }
          if (canMakeIt) {
            nearestNeighbour = i;
            travelTimeToNearestNeighbour = travelTimeToI;
          }
        }
      }
      // If there is no candidate nearest neighbour, break
      if (nearestNeighbour == null || travelTimeToNearestNeighbour == null) {
        dev.log("TSP: no compatible nearest neighbour");
        break;
      }
      // And if there is, add it to the remainingItems list
      final pluckedTodoItem = remainingItems.removeAt(nearestNeighbour);
      dev.log("TSP: plucked todo item ${pluckedTodoItem.$1}");
      final pluckedItemStartTime =
          lastEndTime.add(Duration(seconds: travelTimeToNearestNeighbour));
      final pluckedItemEndTime =
          pluckedItemStartTime.add(Duration(seconds: pluckedTodoItem.$3));
      returnTodoItems.add((
        pluckedTodoItem.$1,
        pluckedTodoItem.$2,
        pluckedItemStartTime,
        pluckedItemEndTime
      ));
      lastLocation = pluckedTodoItem.$2;
      lastEndTime = pluckedItemEndTime;
    }

    // TODO Locally optimize the todoItems we built based on nearest neighbour

    return (returnTodoItems, remainingItems);
  }
}
