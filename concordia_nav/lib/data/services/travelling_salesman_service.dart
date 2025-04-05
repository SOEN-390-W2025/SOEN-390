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
        final fitItems = await fitTodoItems(lastEndTime, lastLocation,
            nextEvent.$3, nextEvent.$2, todoLocations, false);
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
        final fitItems = await fitTodoItems(
            lastEndTime, lastLocation, null, null, todoLocations, false);
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
  static Future<int> getTravelTime(
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

  /// Helper method used in the optimization process. This is going to create a lot of
  /// calls to _getTravelTime. It might be a candidate to replace the implementation
  /// here with one that approximates locally simply based on lat/lng, even if we use
  /// the 'real' implementation elsewhere.
  static Future<int> getOverallRouteTime(Location start, Location? end,
      List<(String, Location, DateTime, DateTime)> stops) async {
    if (stops.isEmpty && end != null) return await getTravelTime(start, end);
    if (stops.isEmpty) return 0;
    int sum = await getTravelTime(start, stops[0].$2);
    Location lastLocation = stops[0].$2;
    for (int i = 1; i < stops.length; i++) {
      sum += await getTravelTime(lastLocation, stops[i].$2);
      lastLocation = stops[i].$2;
    }
    if (end != null) {
      sum += await getTravelTime(lastLocation, end);
    }
    return sum;
  }

  /// When you re-order events as part of an optimization, you need to re-order the
  /// times you give for each stop based on new travel times. This method does that.
  static Future<List<(String, Location, DateTime, DateTime)>>
      recalculateStopTimes(Location start, DateTime startTime,
          List<(String, Location, DateTime, DateTime)> stops) async {
    final List<(String, Location, DateTime, DateTime)> copyOfList =
        List.from(stops);
    Location lastLocation = start;
    DateTime lastEndTime = startTime;
    for (int i = 0; i < stops.length; i++) {
      final Duration timeSpentThere = stops[i].$4.difference(stops[i].$3);
      // Update start time based on travel time
      final DateTime newStartTime = lastEndTime.add(
          Duration(seconds: await getTravelTime(lastLocation, stops[i].$2)));
      // Update end time based on time spent there
      final DateTime newEndTime = newStartTime.add(timeSpentThere);
      stops[i] = (stops[i].$1, stops[i].$2, newStartTime, newEndTime);
      lastLocation = stops[i].$2;
      lastEndTime = stops[i].$4;
    }
    return copyOfList;
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
      )> fitTodoItems(
    DateTime openPeriodStartTime,
    Location openPeriodStartLocation,
    DateTime? openPeriodEndTime,
    Location? openPeriodEndLocation,
    List<(String, Location, int)> todoItems,
    bool doBubbleSwapOptim,
  ) async {
    final List<(String, Location, int)> remainingItems = List.from(todoItems);
    List<(String, Location, DateTime, DateTime)> scheduledItems = [];

    Location lastLocation = openPeriodStartLocation;
    DateTime lastEndTime = openPeriodStartTime;

    while (true) {
      final result = await _findNearestNeighbour(
        lastLocation,
        lastEndTime,
        remainingItems,
        openPeriodEndTime,
        openPeriodEndLocation,
      );

      if (result == null) break;

      final (index, travelTime) = result;
      final pluckedItem = remainingItems.removeAt(index);
      final startTime = lastEndTime.add(Duration(seconds: travelTime));
      final endTime = startTime.add(Duration(seconds: pluckedItem.$3));

      scheduledItems.add((pluckedItem.$1, pluckedItem.$2, startTime, endTime));

      lastLocation = pluckedItem.$2;
      lastEndTime = endTime;
    }

    if (scheduledItems.length > 1 && doBubbleSwapOptim) {
      scheduledItems = await _optimizeWithBubbleSwap(
        openPeriodStartLocation,
        openPeriodStartTime,
        openPeriodEndLocation,
        scheduledItems,
      );
    }

    return (scheduledItems, remainingItems);
  }

  static Future<(int, int)?> _findNearestNeighbour(
    Location currentLocation,
    DateTime currentEndTime,
    List<(String, Location, int)> remainingItems,
    DateTime? finalEndTime,
    Location? finalEndLocation,
  ) async {
    int? bestIndex;
    int? bestTravelTime;

    for (int i = 0; i < remainingItems.length; i++) {
      final travelTime =
          await getTravelTime(currentLocation, remainingItems[i].$2);

      if (bestTravelTime != null && travelTime >= bestTravelTime) continue;

      if (await _canFitItem(
        currentEndTime,
        travelTime,
        remainingItems[i],
        finalEndTime,
        finalEndLocation,
      )) {
        bestIndex = i;
        bestTravelTime = travelTime;
      }
    }

    return (bestIndex != null && bestTravelTime != null)
        ? (bestIndex, bestTravelTime)
        : null;
  }

  static Future<bool> _canFitItem(
    DateTime currentEndTime,
    int travelTimeToItem,
    (String, Location, int) item,
    DateTime? finalEndTime,
    Location? finalEndLocation,
  ) async {
    if (finalEndTime == null || finalEndLocation == null) return true;

    final itemEndTime =
        currentEndTime.add(Duration(seconds: travelTimeToItem + item.$3));

    final travelTimeToFinal = await getTravelTime(item.$2, finalEndLocation);
    final arrivalAtFinal =
        itemEndTime.add(Duration(seconds: travelTimeToFinal));

    return arrivalAtFinal.isBefore(finalEndTime) ||
        arrivalAtFinal.isAtSameMomentAs(finalEndTime);
  }

  static Future<List<(String, Location, DateTime, DateTime)>>
      _optimizeWithBubbleSwap(
    Location startLocation,
    DateTime startTime,
    Location? endLocation,
    List<(String, Location, DateTime, DateTime)> items,
  ) async {
    bool swapped;
    List<(String, Location, DateTime, DateTime)> currentItems = items;

    do {
      swapped = false;
      final originalTime = await getOverallRouteTime(
        startLocation,
        endLocation,
        currentItems,
      );

      for (int i = 0; i < currentItems.length - 1; i++) {
        final swappedList =
            List<(String, Location, DateTime, DateTime)>.from(currentItems);
        final temp = swappedList[i];
        swappedList[i] = swappedList[i + 1];
        swappedList[i + 1] = temp;

        final newTime = await getOverallRouteTime(
          startLocation,
          endLocation,
          swappedList,
        );

        if (newTime < originalTime) {
          currentItems = await recalculateStopTimes(
            startLocation,
            startTime,
            swappedList,
          );
          swapped = true;
          break;
        }
      }
    } while (swapped);

    return currentItems;
  }
}
