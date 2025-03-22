import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain-model/travelling_salesman_request.dart';
import '../domain-model/location.dart';
import '../repositories/places_repository.dart';
import 'places_service.dart';
import '../domain-model/place.dart';
import '../domain-model/concordia_building.dart';
import '../repositories/building_repository.dart';
import '../repositories/building_data_manager.dart';
import './helpers/smart_planner_helpers.dart';

class SmartPlannerService {
  final PlacesRepository _placesRepository;

  SmartPlannerService()
      : _placesRepository = PlacesRepository(PlacesService()) {
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
  }

  /// Attempts to interpret [name] as an indoor location reference.
  /// If [name] has two or more tokens and the last token is numeric,
  /// it will consider the first tokens as a building reference and the last
  /// token as a room number. If a matching ConcordiaRoom is found via
  /// BuildingDataManager, returns that room.
  Future<Location?> _lookupIndoorLocation(String name) async {
    final tokens = name.trim().split(RegExp(r'\s+'));
    if (tokens.length >= 2) {
      final potentialRoomNumber = tokens.last;
      if (double.tryParse(potentialRoomNumber) != null) {
        final buildingReference =
            tokens.sublist(0, tokens.length - 1).join(" ");
        ConcordiaBuilding? building;
        // Try by abbreviation.
        building = BuildingRepository
            .buildingByAbbreviation[buildingReference.toUpperCase()];
        if (building == null) {
          for (var b in BuildingRepository.buildingByAbbreviation.values) {
            if (b.name
                .toLowerCase()
                .contains(buildingReference.toLowerCase())) {
              building = b;
              break;
            }
          }
        }
        if (building != null) {
          final buildingData =
              await BuildingDataManager.getBuildingData(building.abbreviation);
          if (buildingData != null) {
            for (var roomList in buildingData.roomsByFloor.values) {
              for (var room in roomList) {
                if (room.roomNumber.trim() == potentialRoomNumber.trim()) {
                  dev.log(
                      "Found ConcordiaRoom for '$name': ${room.roomNumber} in ${building.name}");
                  return room;
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  /// Attempts to find a matching place from our catalogs.
  /// It first checks the indoor catalog, then outdoor ConcordiaBuildings,
  /// then outdoor Places via Google Places.
  /// If no matching location was found, it throws an error.
  Future<Location> getLocationByName(String name) async {
    // Indoor lookup is performed first.
    final indoorResult = await _lookupIndoorLocation(name);
    if (indoorResult != null) {
      dev.log("Found ConcordiaFloor for '$name': ${indoorResult.name}");
      return indoorResult;
    }

    // Next we'll try to check if the location corresponds to a ConU Building.
    for (var building in BuildingRepository.buildingByAbbreviation.values) {
      if (building.name.toLowerCase().contains(name.toLowerCase())) {
        dev.log("Found ConcordiaBuilding for '$name': ${building.name}");
        return building;
      }
    }

    // Then we'll try outdoor places. To save on real-time calls to the Google
    // Places API, we can hard-code a midpoint between both SGW and LOY, which
    // encompasses a large-enough radius to cover a variety of places.
    const midpointForCampuses = LatLng(45.47800, -73.60885);
    try {
      final List<Place> nearbyPlaces = await _placesRepository.getNearbyPlaces(
        location: midpointForCampuses,
        radius: 6000, // hopefully enough to capture most places
        type: null,
      );
      final index = nearbyPlaces.indexWhere(
        (place) => place.name.toLowerCase().contains(name.toLowerCase()),
      );
      if (index != -1) {
        final match = nearbyPlaces[index];
        dev.log("Found matching outdoor place for '$name': ${match.name}");
        return Location(
          match.location.latitude,
          match.location.longitude,
          match.name,
          match.address,
          null,
          null,
          null,
        );
      }
    } on Error catch (e, stackTrace) {
      dev.log("Error fetching nearby places: $e", stackTrace: stackTrace);
    }

    // At this point if no match is found, then the input was probably invalid.
    dev.log("No location found for '$name'.");
    throw Exception(
        "No matching location found for '$name'. Please verify the name and try again.");
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
    final addTaskTool = OpenAIToolModel(
      type: "function",
      function: OpenAIFunctionModel.withParameters(
        name: "add_task",
        parameters: [
          OpenAIFunctionProperty.string(
            name: "locationName",
            description:
                "Name of the location. Must be unique across all todoLocations and events in the OpenAI response.",
          ),
          OpenAIFunctionProperty.string(
            name: "startTime",
            description:
                "Event start time in ISO8601 format if provided, else empty",
          ),
          OpenAIFunctionProperty.string(
            name: "endTime",
            description:
                "Event end time in ISO8601 format if provided, else empty",
          ),
          OpenAIFunctionProperty.integer(
            name: "duration",
            description:
                "Duration in seconds if provided (for free-time tasks), else 0",
          ),
        ],
      ),
    );

    // The main idea of having a system message being passed in addition
    // to what the user's trying to ask for is simple: give the LLM context,
    // and (more importantly,) restrict its output to what we want.
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          You are a planning assistant. The user may provide times in natural language 
          (e.g. "from 11:00 AM to 2:00 PM", "from 3 pm to 4 pm", "for 30 minutes"). 
          Your job is to convert these times into either ISO8601 date/time or a duration in seconds.

          - If the user specifies both a start time and an end time, fill in 'startTime' and 'endTime' (e.g. "2025-03-18T14:00:00" and "2025-03-18T15:00:00").
          - If the user only provides a duration (e.g. "for 30 minutes"), fill in 'duration'.
          - If the user provides no times at all, a start time with no end time, or an end time with no start time, throw an error and cancel the operation.
          - Return only function calls to 'add_task'. No extra text.
          """)
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
      role: OpenAIChatMessageRole.user,
    );

    final chatResponse = await OpenAI.instance.chat.create(
      // o1 could have been used here too, but 4o does the job. Based on newer
      // models seeming to cost more credits, it's better to just use 4o.
      model: "gpt-4o",
      messages: [systemMessage, userMessage],
      tools: [addTaskTool],
    );

    dev.log("Full Chat Response: ${chatResponse.toString()}");

    final message = chatResponse.choices.first.message;
    dev.log("Raw message: ${message.toString()}");

    if (!message.haveToolCalls) {
      dev.log("No tool calls detected. Message content: ${message.content}");
      throw Exception("No function calls received from OpenAI.");
    }

    final List<(String, Location, DateTime, DateTime)> events = [];
    final List<(String, Location, int)> todoLocations = [];

    // The entire plan should take place in the same day.
    final planDay = DateTime(startTime.year, startTime.month, startTime.day);

    // As per the TravellingSalesmanRequest structure, we need to make sure that
    // the string attribute stored in tuples is unique across all todoLocations
    // and events in the route and can be used to properly identify the location
    // in the response.
    final Set<String> usedIds = {};

    for (final toolCall in message.toolCalls!) {
      final args = jsonDecode(toolCall.function.arguments);
      final locationName = args["locationName"] as String? ?? "Plan Item";
      final startStr = args["startTime"] as String? ?? "";
      final endStr = args["endTime"] as String? ?? "";
      final durationSec = args["duration"] as int? ?? 0;
      final loc = await getLocationByName(locationName);

      if (startStr.isNotEmpty && endStr.isNotEmpty) {
        try {
          final parsedStart = DateTime.parse(startStr);
          final parsedEnd = DateTime.parse(endStr);
          final startTimeParsed = rebaseTime(parsedStart, planDay);
          final endTimeParsed = rebaseTime(parsedEnd, planDay);
          if (!startTimeParsed.isBefore(endTimeParsed)) {
            dev.log(
                "Invalid event (start is not before end) for '$locationName': skipping.");
            continue;
          }
          events.add((
            generateUniqueId("add_event_$locationName", usedIds),
            loc,
            startTimeParsed,
            endTimeParsed
          ));
        } on Error catch (e) {
          dev.log("Error parsing times for event '$locationName': $e");
        }
      } else if (durationSec > 0) {
        todoLocations.add((
          generateUniqueId("add_location_$locationName", usedIds),
          loc,
          durationSec
        ));
      } else {
        dev.log(
            "No time info provided for '$locationName'. Cancelling operation.");
        throw Exception(
            "No time information provided for task '$locationName'. Please re-enter your prompt with proper time details.");
      }
    }

    final validEvents = validateEvents(events, planDay);

    return TravellingSalesmanRequest(
      todoLocations,
      validEvents,
      startTime,
      startLocation,
    );
  }
}
