import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/travelling_salesman_request.dart';
import '../domain-model/location.dart';
import '../repositories/places_repository.dart';
import '../repositories/building_repository.dart';
import '../repositories/building_data_manager.dart';
import 'helpers/smart_planner_helpers.dart';
import 'places_service.dart';

class SmartPlannerService {
  final PlacesRepository _placesRepository;
  OpenAIChatCompletionModel? _response;

  SmartPlannerService(
      {OpenAIChatCompletionModel? response, PlacesService? placesService})
      : _placesRepository = PlacesRepository(placesService ?? PlacesService()) {
    OpenAI.apiKey = Platform.environment.containsKey('FLUTTER_TEST')
        ? ""
        : dotenv.env['OPENAI_API_KEY']!;
    _response = response;
  }

  /// Attempts to interpret [name] as an indoor location reference, where [name]
  /// represents a given a text like "H 9.27" or "Hall Building 9.27".
  /// It normalizes the input: if the last token contains a dot (e.g. "9.27"),
  /// it splits that into floor ("9") and room ("27").
  Future<Location?> _lookupIndoorLocation(String name) async {
    final tokens = name.trim().split(RegExp(r'\s+'));
    if (tokens.length < 2) return null;

    String roomToken = tokens.last;
    String? floorToken;
    if (roomToken.contains('.')) {
      final parts = roomToken.split('.');
      if (parts.length == 2) {
        floorToken = parts[0];
        roomToken = parts[1];
      }
    }
    // If no floor token is provided, we cannot do an indoor lookup.
    if (floorToken == null) {
      dev.log("Indoor lookup: no floor token found in '$name'");
      return null;
    }

    final buildingRef = tokens.sublist(0, tokens.length - 1).join(' ');
    final building =
        BuildingRepository.buildingByAbbreviation[buildingRef.toUpperCase()] ??
            BuildingRepository.buildingByAbbreviation.values.firstWhere(
              (b) => b.name.toLowerCase().contains(buildingRef.toLowerCase()),
              orElse: () => throw Exception("Unknown building '$buildingRef'"),
            );

    dev.log(
        "Indoor lookup: using building '${building.name}' for input '$name'");
    final data =
        await BuildingDataManager.getBuildingData(building.abbreviation);
    try {
      final foundRoom = data!.roomsByFloor[floorToken]!.firstWhere(
        (r) => r.roomNumber.trim() == roomToken.trim(),
        orElse: () =>
            throw Exception("Room $roomToken not found in ${building.name}"),
      );
      dev.log(
          "Indoor lookup succeeded for '$name': found room ${foundRoom.roomNumber}");
      dev.log("Runtime type of indoor location: ${foundRoom.runtimeType}");
      return foundRoom;
    } on Error {
      throw Exception("Room $roomToken not found in ${building.name}");
    }
  }

  /// Attempts to find a matching place from our catalogs.
  /// It first checks the indoor catalog, then outdoor ConcordiaBuildings,
  /// then outdoor Places via Google Places.
  /// If no matching location was found, it throws an error.
  Future<Location> getLocationByName(String name) async {
    // Indoor lookup is performed first.
    final indoor = await _lookupIndoorLocation(name);
    if (indoor != null) {
      dev.log(
          "getLocationByName: Returning indoor location. Runtime type: ${indoor.runtimeType}");
      return indoor;
    }

    // Next we'll try to check if the location corresponds to a ConU Building.
    for (var b in BuildingRepository.buildingByAbbreviation.values) {
      if (b.name.toLowerCase().contains(name.toLowerCase())) {
        dev.log(
            "getLocationByName: Found ConcordiaBuilding for '$name'. Runtime type: ${b.runtimeType}");
        return b;
      }
    }

    // Then we'll try outdoor places. To save on real-time calls to the Google
    // Places API, we can hard-code a midpoint between both SGW and LOY, which
    // encompasses a large-enough radius to cover a variety of places.
    const midpointForCampuses = LatLng(45.47800, -73.60885);
    final nearbyPlaces = await _placesRepository.getNearbyPlaces(
      location: midpointForCampuses,
      radius: 15000,
      type: null,
    );
    final idx = nearbyPlaces.indexWhere(
      (p) => p.name.toLowerCase().contains(name.toLowerCase()),
    );
    if (idx != -1) {
      final match = nearbyPlaces[idx];
      dev.log(
          "getLocationByName: Found outdoor place for '$name' via nearbySearch. Runtime type: Location");
      final loc = parseLocationFromPlace(match);
      return loc;
    }

    // If for some reason there was no match from nearbySearch, use textSearch
    // Create TextSearchParams object with the appropriate parameters
    final params = TextSearchParams(
      query: name,
      location: midpointForCampuses,
      radius: 15000, // Larger radius or tune as needed
    );

// Use the params object when calling textSearchPlaces
    final textResults =
        await _placesRepository.textSearchPlaces(params: params);

    if (textResults.isNotEmpty) {
      final first = textResults.first;
      dev.log(
          "getLocationByName: Found outdoor place for '$name' via textSearch. Runtime type: Location");
      final loc = parseLocationFromPlace(first);
      return loc;
    }

    // At this point if no match is found, then the input was probably invalid.
    throw Exception("No location found for '$name'.");
  }

  /// Returns a [TravellingSalesmanRequest] with lists for events and
  /// todoLocations, along with the provided start time and start location.
  Future<TravellingSalesmanRequest> generatePlannerData({
    required String prompt,
    required DateTime startTime,
    required Location startLocation,
  }) async {
    // functions and function_call have been deprecated since v4.1.3 of the
    // dart_openai package, so we instead opt to just use tools. A single
    // add_task function is what lets us add items to either the events List or
    // the todoLocations List, with the help of OpenAI.
    final addIndoorEvent = OpenAIToolModel(
      type: "function",
      function: OpenAIFunctionModel.withParameters(
        name: "add_indoor_event",
        parameters: [
          OpenAIFunctionProperty.string(name: "building"),
          OpenAIFunctionProperty.string(name: "floor"),
          OpenAIFunctionProperty.string(name: "room"),
          OpenAIFunctionProperty.string(name: "startTime"),
          OpenAIFunctionProperty.string(name: "endTime"),
        ],
      ),
    );
    final addIndoorLocation = OpenAIToolModel(
      type: "function",
      function: OpenAIFunctionModel.withParameters(
        name: "add_indoor_location",
        parameters: [
          OpenAIFunctionProperty.string(name: "building"),
          OpenAIFunctionProperty.string(name: "floor"),
          OpenAIFunctionProperty.string(name: "room"),
          OpenAIFunctionProperty.integer(name: "duration"),
        ],
      ),
    );
    final addOutdoorEvent = OpenAIToolModel(
      type: "function",
      function: OpenAIFunctionModel.withParameters(
        name: "add_outdoor_event",
        parameters: [
          OpenAIFunctionProperty.string(name: "locationName"),
          OpenAIFunctionProperty.string(name: "startTime"),
          OpenAIFunctionProperty.string(name: "endTime"),
        ],
      ),
    );
    final addOutdoorLocation = OpenAIToolModel(
      type: "function",
      function: OpenAIFunctionModel.withParameters(
        name: "add_outdoor_location",
        parameters: [
          OpenAIFunctionProperty.string(name: "locationName"),
          OpenAIFunctionProperty.integer(name: "duration"),
        ],
      ),
    );

    // The main idea of having a system message being passed in addition
    // to what the user's trying to ask for is simple: give the LLM context,
    // and (more importantly,) restrict its output to what we want.
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          You are a planning assistant. Split the user's prompt into individual tasks and call exactly one function per task.

          For indoor tasks (if the location refers to a Concordia building with both floor and room details), return one of:
            - add_indoor_event: with separate fields "building", "floor", and "room" plus startTime and endTime.
            - add_indoor_location: with the same fields plus a duration.
          For outdoor tasks (generic venues such as "coffee shop", "grocery shop", etc.), return one of:
            - add_outdoor_event: with "locationName", "startTime", and "endTime" (full ISO8601 strings).
            - add_outdoor_location: with "locationName" and a duration (in seconds).

          Important: All times must be full ISO8601 timestamps. If an indoor task is provided, ensure that the "floor" and "room" values exactly match our data format (e.g. for "H 9.27", use floor "9" and room "27"). If a user omits floor/room for an indoor task, choose an outdoor function instead.

          Return only JSON function calls. No extra text.
        """)
      ],
    );

    final userMsg = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
    );

    final chatResponse = _response ??
        await OpenAI.instance.chat.create(
          // o1 could have been used here too, but 4o does the job. Based on newer
          // models seeming to cost more credits, it's better to just use 4o.
          model: "gpt-4o",
          messages: [systemMessage, userMsg],
          tools: [
            addIndoorEvent,
            addIndoorLocation,
            addOutdoorEvent,
            addOutdoorLocation
          ],
        );

    dev.log("Full Chat Response: ${chatResponse.toString()}");
    final message = chatResponse.choices.first.message;
    dev.log("Raw message: ${message.toString()}");

    if (!message.haveToolCalls) {
      throw Exception("No function calls received from OpenAI.");
    }

    // The entire plan should take place in the same day.
    final planDay = DateTime(startTime.year, startTime.month, startTime.day);
    // As per the TravellingSalesmanRequest structure, we need to make sure that
    // the string attribute stored in tuples is unique across all todoLocations
    // and events in the route and can be used to properly identify the location
    // in the response.
    final usedIds = <String>{};

    final events = <(String, Location, DateTime, DateTime)>[];
    final todos = <(String, Location, int)>[];

    for (var call in message.toolCalls!) {
      final args = jsonDecode(call.function.arguments);
      switch (call.function.name) {
        case "add_indoor_event":
          final indoorKey =
              "${args['building']} ${args['floor']}.${args['room']}";
          final loc = await getLocationByName(indoorKey);
          dev.log(
              "Processed add_indoor_event; runtime type: ${loc.runtimeType}");
          final s = rebaseTime(DateTime.parse(args['startTime']), planDay);
          final e = rebaseTime(DateTime.parse(args['endTime']), planDay);
          if (s.isBefore(e)) {
            events.add(
                (generateUniqueId("event_${loc.name}", usedIds), loc, s, e));
          }
          break;
        case "add_indoor_location":
          final indoorKey =
              "${args['building']} ${args['floor']}.${args['room']}";
          final loc = await getLocationByName(indoorKey);
          dev.log(
              "Processed add_indoor_location; runtime type: ${loc.runtimeType}");
          todos.add((
            generateUniqueId("todo_${loc.name}", usedIds),
            loc,
            args['duration']
          ));
          break;
        case "add_outdoor_event":
          final loc = await getLocationByName(args['locationName']);
          dev.log(
              "Processed add_outdoor_event; runtime type: ${loc.runtimeType}");
          final s = rebaseTime(DateTime.parse(args['startTime']), planDay);
          final e = rebaseTime(DateTime.parse(args['endTime']), planDay);
          if (s.isBefore(e)) {
            events.add(
                (generateUniqueId("event_${loc.name}", usedIds), loc, s, e));
          }
          break;
        case "add_outdoor_location":
          final loc = await getLocationByName(args['locationName']);
          dev.log(
              "Processed add_outdoor_location; runtime type: ${loc.runtimeType}");
          todos.add((
            generateUniqueId("todo_${loc.name}", usedIds),
            loc,
            args['duration']
          ));
          break;
      }
    }

    final validEvents = validateEvents(events, planDay);
    return TravellingSalesmanRequest(
        todos, validEvents, startTime, startLocation);
  }
}
