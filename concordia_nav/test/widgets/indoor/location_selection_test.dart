// ignore_for_file: depend_on_referenced_packages

import 'package:concordia_nav/widgets/next_class/location_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();

  dotenv.load(fileName: '.env');

// random position far away from campuses
  var testPosition = Position(
      longitude: 45.497211,
      latitude: -73.57875,
      timestamp: DateTime.now(),
      accuracy: 30.0,
      altitude: 20.0,
      heading: 120,
      speed: 150.9,
      speedAccuracy: 10.0,
      altitudeAccuracy: 10.0,
      headingAccuracy: 10.0);
  // ref to permission integers: https://github.com/Baseflow/flutter-geolocator/blob/main/geolocator_platform_interface/lib/src/extensions/integer_extensions.dart
  var permission = 3; // permission set to accept
  const request = 3; // request permission set to accept
  const service = true; // locationService set to true

  // ensure plugin is initialized
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

    if (methodCall.method == "getLastKnownPosition") {
      if (testPosition.latitude == 100) {
        return testPosition.toJson();
      } else {
        return null;
      }
    }
  }

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(locationChannel, locationHandler);
  });

  testWidgets('Displays correct UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LocationSelection(
          isSource: true,
          onSelectionComplete: (location) {},
        ),
      ),
    );

    expect(find.text('My Location'), findsOneWidget);
    expect(find.text('Outdoor Location'), findsOneWidget);
    expect(find.text('Select Classroom'), findsOneWidget);
  });

  testWidgets('Selecting My Location triggers location fetching',
      (WidgetTester tester) async {
    bool callbackInvoked = false;

    permission = 3;

    await tester.pumpWidget(
      MaterialApp(
        home: LocationSelection(
          isSource: true,
          onSelectionComplete: (location) {
            callbackInvoked = true;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();

    expect(callbackInvoked, isTrue);

    testPosition = Position(
        longitude: 45.497211,
        latitude: -73.57875,
        timestamp: DateTime.now(),
        accuracy: 30.0,
        altitude: 20.0,
        heading: 120,
        speed: 150.9,
        speedAccuracy: 10.0,
        altitudeAccuracy: 10.0,
        headingAccuracy: 10.0);

    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();
  });

  testWidgets('Selecting My Location without permission triggers error',
      (WidgetTester tester) async {
    bool callbackInvoked = false;

    permission = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: LocationSelection(
          isSource: true,
          onSelectionComplete: (location) {
            callbackInvoked = true;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();

    expect(callbackInvoked, isTrue);
  });

  testWidgets('Selecting Classroom updates dropdowns correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LocationSelection(
          isSource: true,
          onSelectionComplete: (location) {},
        ),
      ),
    );

    await tester.tap(find.text('Select Classroom'));
    await tester.pumpAndSettle();

    expect(find.text('Select Building'), findsOneWidget);
  });

  testWidgets('Selecting Building updates dropdowns correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LocationSelection(
          isSource: true,
          onSelectionComplete: (location) {},
        ),
      ),
    );

    await tester.tap(find.text('Select Classroom'));
    await tester.pumpAndSettle();

    expect(find.text('Select Building'), findsOneWidget);
    await tester.tap(find.text('Select Building'));
    await tester.pumpAndSettle();
  });

  testWidgets('Handles permission denial gracefully',
      (WidgetTester tester) async {
    permission = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: LocationSelection(
          isSource: false,
          onSelectionComplete: (location) {},
        ),
      ),
    );

    await tester.tap(find.text('Course Calendar'));
    await tester.pumpAndSettle();
  });
}
