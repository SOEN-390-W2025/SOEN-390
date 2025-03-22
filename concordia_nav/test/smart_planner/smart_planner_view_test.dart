import 'package:concordia_nav/ui/home/homepage_view.dart';
import 'package:concordia_nav/ui/smart_planner/generated_plan_view.dart';
import 'package:concordia_nav/ui/smart_planner/smart_planner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';

import '../map/map_viewmodel_test.mocks.dart';

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
      // Build our app and trigger a frame.
      final routes = {
        '/': (context) =>
            SmartPlannerView(mapViewModel: mockMapViewModel),
        '/GeneratedPlanView': (context) => const GeneratedPlanView()
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
      expect(find.textContaining("Building"),
          findsOneWidget); // Assumes a building is chosen

      // Now "Make Plan" should be enabled
      expect(
          tester.widget<ElevatedButton>(makePlanButton).onPressed, isNotNull);

      // Tap on "Make Plan"
      await tester.tap(makePlanButton);
      await tester.pumpAndSettle();
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
