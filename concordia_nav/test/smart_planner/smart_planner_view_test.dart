// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:convert';

import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/place.dart';
import 'package:concordia_nav/data/domain-model/travelling_salesman_request.dart';
import 'package:concordia_nav/data/repositories/places_repository.dart';
import 'package:concordia_nav/data/services/places_service.dart';
import 'package:concordia_nav/data/services/smart_planner_service.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';
import 'package:concordia_nav/ui/smart_planner/generated_plan_view.dart';
import 'package:concordia_nav/ui/smart_planner/smart_planner_view.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dart_openai/src/core/models/chat/sub_models/choices/sub_models/sub_models/sub_models/response_function_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../map/map_viewmodel_test.mocks.dart';

OpenAIChatCompletionModel mockChatResponse = OpenAIChatCompletionModel(
  id: "mock-id",
  created: DateTime.now(),
  systemFingerprint: "mock-system-fingerprint",
  choices: [
    OpenAIChatCompletionChoiceModel(
      index: 0,
      message: OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: null, // Function call responses typically have no text content
        toolCalls: [
          // Tool call for add_indoor_event
          OpenAIResponseToolCall(
            id: "tool-call-1",
            type: "function_call",
            function: OpenAIResponseFunction(
              name: "add_indoor_event",
              arguments: jsonEncode({
                "building": "Hall Building",
                "floor": "9",
                "room": "27",
                "startTime": "2025-03-23T10:00:00Z",
                "endTime": "2025-03-23T11:00:00Z",
              }),
            ),
          ),
          // Tool call for add_indoor_location
          OpenAIResponseToolCall(
            id: "tool-call-2",
            type: "function_call",
            function: OpenAIResponseFunction(
              name: "add_indoor_location",
              arguments: jsonEncode({
                "building": "Hall Building",
                "floor": "9",
                "room": "27",
                "duration": 3600, // 1 hour
              }),
            ),
          ),
          // Tool call for add_outdoor_event
          OpenAIResponseToolCall(
            id: "tool-call-3",
            type: "function_call",
            function: OpenAIResponseFunction(
              name: "add_outdoor_event",
              arguments: jsonEncode({
                "locationName": "Starbucks",
                "startTime": "2025-03-23T10:00:00Z",
                "endTime": "2025-03-23T11:00:00Z",
              }),
            ),
          ),
          // Tool call for add_outdoor_location
          OpenAIResponseToolCall(
            id: "tool-call-4",
            type: "function_call",
            function: OpenAIResponseFunction(
              name: "add_outdoor_location",
              arguments: jsonEncode({
                "locationName": "Starbucks",
                "duration": 1800, // 30 minutes
              }),
            ),
          ),
          OpenAIResponseToolCall(
            id: "tool-call-4",
            type: "function_call",
            function: OpenAIResponseFunction(
              name: "add_outdoor_event",
              arguments: jsonEncode({
                "locationName": "bababooey",
                "startTime": "2025-03-23T10:00:00Z",
                "endTime": "2025-03-23T11:00:00Z",
              }),
            ),
          ),
        ],
      ),
      finishReason: "tool_calls",
    ),
  ],
  usage: const OpenAIChatCompletionUsageModel(
    promptTokens: 50,
    completionTokens: 100,
    totalTokens: 150,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  // random position far away from campuses
  var testPosition = Position(
      longitude: 45.49733709485399,
      latitude: -73.57903300554355,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 20.0,
      heading: 120,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0);
  // ref to permission integers: https://github.com/Baseflow/flutter-geolocator/blob/main/geolocator_platform_interface/lib/src/extensions/integer_extensions.dart
  const permission = 3; // permission set to accept
  const request = 3; // request permission set to accept
  const service = true; // locationService set to true

  const MethodChannel locationChannel =
      MethodChannel('flutter.baseflow.com/geolocator');

  Future locationHandler(MethodCall methodCall) async {
    // grants access to location permissions
    if (methodCall.method == 'requestPermission') {
      return request;
    }
    // return testPosition when searching for the current location
    if (methodCall.method == 'getCurrentPosition') {
      return testPosition.toJson();
    }
    // set to true when device tries to check for permissions
    if (methodCall.method == 'isLocationServiceEnabled') {
      return service;
    }
    // returns authorized when checking for location permissions
    if (methodCall.method == 'checkPermission') {
      return permission;
    }
  }

  late MockMapViewModel mockMapViewModel;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(locationChannel, locationHandler);
  });

  setUp(() {
    mockMapViewModel = MockMapViewModel();

    testPosition = Position(
        longitude: 45.49733709485399,
        latitude: -73.57903300554355,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 20.0,
        heading: 120,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0);

    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);
  });

  group('SmartPlannerView Flow Tests', () {
    late PlacesService placesService;
    late MockClient mockClient;

    final mockResponse = jsonEncode({
      'places': [
        {
          'id': 'place_1',
          'displayName': {'text': 'Starbucks'},
          'name': 'Starbucks',
          'formattedAddress':
              '1453 Mackay St LB Building, Montreal, QC H3G 2H6',
          'location': {
            'latitude': 45.4215,
            'longitude': -75.6972,
          },
          'rating': 4.5,
          'types': ['restaurant', 'food'],
          'currentOpeningHours': {'openNow': true},
          'nationalPhoneNumber': '+1234567890',
          'internationalPhoneNumber': '+1234567890',
          'websiteUri': 'https://example.com',
          'primaryType': 'restaurant',
          'userRatingCount': 150,
          'priceLevel': '2',
          'accessibilityOptions': {
            'wheelchairAccessibleParking': true,
            'wheelchairAccessibleEntrance': true,
            'wheelchairAccessibleRestroom': false,
            'wheelchairAccessibleSeating': true,
          },
        },
      ],
      'routingSummaries': [
        {
          'distance': 1500,
          'duration': 300,
        },
      ],
    });

    setUp(() {
      mockClient = MockClient();
      placesService = PlacesService(mockClient);
    });

    test('getNearbyPlaces throws exception', () async {
      // Arrange
      final PlacesRepository repo = PlacesRepository(placesService);

      const location =
          LatLng(45.4215, -75.6972); // Example coordinates (Ottawa)
      const radius = 1500.0;
      const type = PlaceType.coffeeShop;

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponse, 400));
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockResponse, 400));

      // Act
      try {
        await repo.getNearbyPlaces(
          location: location,
          radius: radius,
          type: type,
        );
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('textSearchPlaces throws exception', () async {
      // Arrange
      const query = 'coffee shop';
      const location =
          LatLng(45.4215, -75.6972); // Example coordinates (Ottawa)
      const radius = 1500.0;
      const type = PlaceType.coffeeShop;
      const openNow = true;
      final PlacesRepository repo = PlacesRepository(placesService);

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponse, 400));
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockResponse, 400));

      // Act
      try {
        // Create TextSearchParams object with the required parameters
        final params = TextSearchParams(
          query: query,
          location: location,
          radius: radius,
          type: type,
          openNow: openNow,
        );

        // Call textSearchPlaces using the params object
        await repo.textSearchPlaces(params: params);
      } catch (e) {
        // Expect the exception to be of type Exception
        expect(e, isA<Exception>());
      }
    });

    testWidgets('SmartPlannerView - Press on Generate Plan',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponse, 200));
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(mockResponse, 200));

      testPosition = Position(
          longitude: -73.5788992164221,
          latitude: 45.4952628500172,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 20.0,
          heading: 120,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0);

      final SmartPlannerService mockService = SmartPlannerService(
          response: mockChatResponse, placesService: placesService);

      final routes = {
        '/SmartPlannerView': (context) => SmartPlannerView(
            mapViewModel: mockMapViewModel, smartPlannerService: mockService),
      };

      // Build the HomePage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/SmartPlannerView',
        routes: routes,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first,
          'I have to attend a seminar at the J.W. McConnell Building from 9 am to 9:30 am, I have a lecture in H 9.27 from 10:00 am to 11:00 am, and go to a coffee shop for 30 minutes, and I also have to go to Hall Building for 20 minutes.');
      await tester.pumpAndSettle();

      await tester.tap(find.text("Make Plan"));
      await tester.pumpAndSettle();
    });

    testWidgets('Tap on the smart planner button from home page',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      final routes = {
        '/': (context) => const HomePage(),
        '/SmartPlannerView': (context) =>
            SmartPlannerView(mapViewModel: mockMapViewModel),
      };

      // Build the HomePage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));

      // Ensure we are on HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // Tap on the edit note icon to open Smart Planner
      final editNoteIcon = find.byIcon(Icons.edit_note);
      expect(editNoteIcon, findsOneWidget);
      await tester.tap(editNoteIcon);
      await tester.pumpAndSettle();
    });

    testWidgets('Navigate to SmartPlannerView from HomePage and create a plan',
        (WidgetTester tester) async {
      final samplePlan = TravellingSalesmanRequest(
        [
          (
            "Place A",
            const Location(45.5017, -73.5673, "Place A", "Description",
                "Category", "Address", "Building Code"),
            900
          ),
          (
            "Place B",
            const Location(45.5017, -73.5673, "Place A", "Description",
                "Category", "Address", "Building Code"),
            1200
          ),
        ],
        [
          (
            "Meeting",
            const Location(45.5017, -73.5673, "Place A", "Description",
                "Category", "Address", "Building Code"),
            DateTime(2025, 3, 24, 14, 0),
            DateTime(2025, 3, 24, 15, 0)
          )
        ],
        DateTime(2025, 3, 24, 9, 0),
        const Location(45.5017, -73.5673, "Place A", "Description", "Category",
            "Address", "Building Code"),
      );

      final routes = {
        '/': (context) => SmartPlannerView(mapViewModel: mockMapViewModel),
        '/GeneratedPlanView': (context) {
          return GeneratedPlanView(
            plan: samplePlan,
          );
        }
      };

      // Build the HomePage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));

      // Check if we navigated to SmartPlannerView
      expect(find.byType(SmartPlannerView), findsOneWidget);

      // Check for presence of form elements
      expect(find.text("Create new plan..."), findsOneWidget);
      expect(find.text("Pick a source location..."), findsOneWidget);
      expect(find.text("Make Plan"), findsOneWidget);

      // Try pressing "Make Plan" while fields are empty (should be disabled)
      final makePlanButton = find.widgetWithText(ElevatedButton, "Make Plan");
      expect(tester.widget<ElevatedButton>(makePlanButton).onPressed, isNull);

      // Open source selector
      final sourceField = find.byType(TextField).at(1);
      await tester.ensureVisible(sourceField);
      await tester.tap(sourceField, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Fill the plan name
      await tester.enterText(find.byType(TextField).first, "My optimized day");
      await tester.pumpAndSettle();

      // Select first building from the list
      final buildingOption = find.byType(ListTile).first;
      await tester.tap(buildingOption);
      await tester.pumpAndSettle();

      // Check if source is updated
      expect(find.byType(TextField).at(1),
          findsOneWidget); // Second TextField is source
    });

    testWidgets(
        'SmartPlannerView - Use current location as source when enabled',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      testPosition = Position(
          longitude: -73.5788992164221,
          latitude: 45.4952628500172,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 20.0,
          heading: 120,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0);

      final routes = {
        '/SmartPlannerView': (context) =>
            SmartPlannerView(mapViewModel: mockMapViewModel),
      };

      // Build the HomePage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/SmartPlannerView',
        routes: routes,
      ));

      await tester.pumpAndSettle();

      // Check for "Use current location" button (assuming location enabled and detected)
      final useLocationButton = find.text("Use current location");
      expect(useLocationButton, findsOneWidget);

      // Tap to set "Your location" as source
      await tester.tap(useLocationButton);
      await tester.pumpAndSettle();

      // Check that source is updated
      expect(find.text("Your location"), findsOneWidget);
    });

    // testWidgets(
    //     'SmartPlannerView - Auto-detect nearest building if within 1000m',
    //     (WidgetTester tester) async {
    //   // Build our app and trigger a frame.
    //   testPosition = Position(
    //       longitude: 45.49733709485399,
    //       latitude: -73.57903300554355,
    //       timestamp: DateTime.now(),
    //       accuracy: 10.0,
    //       altitude: 20.0,
    //       heading: 120,
    //       speed: 0.0,
    //       speedAccuracy: 0.0,
    //       altitudeAccuracy: 0.0,
    //       headingAccuracy: 0.0);

    //   final routes = {
    //     '/SmartPlannerView': (context) =>
    //         SmartPlannerView(mapViewModel: mockMapViewModel),
    //   };

    //   // Build the HomePage widget
    //   await tester.pumpWidget(MaterialApp(
    //     initialRoute: '/SmartPlannerView',
    //     routes: routes,
    //   ));

    //   await tester.pumpAndSettle();

    //   // Check if the source field is auto-filled with a nearby building
    //   expect(find.byType(TextField).at(1),
    //       findsOneWidget); // Second TextField is source
    //   expect(find.textContaining("Building"),
    //       findsOneWidget); // Assuming name contains "Building"

    //   // Check that "Use current location" button is visible for manual switch
    //   final useLocationButton = find.text("Use current location");
    //   expect(useLocationButton, findsOneWidget);
    // });
  });
}
