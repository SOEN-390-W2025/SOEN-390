import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/ui/next_class/next_class_directions_view.dart';
import 'package:concordia_nav/utils/next_class/next_class_directions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';

import '../../map/map_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  final testPosition = Position(
      longitude: 100.0,
      latitude: 100.0,
      timestamp: DateTime.now(),
      accuracy: 30.0,
      altitude: 20.0,
      heading: 120,
      speed: 150.9,
      speedAccuracy: 10.0,
      altitudeAccuracy: 10.0,
      headingAccuracy: 10.0);
  // ref to permission integers: https://github.com/Baseflow/flutter-geolocator/blob/main/geolocator_platform_interface/lib/src/extensions/integer_extensions.dart
  const permission = 3; // permission set to accept
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
    if (methodCall.method == 'getLastKnownPosition') {
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

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(locationChannel, locationHandler);
  });

  late NextClassViewModel viewModel;
  late MockODSDirectionsService mockService;

  setUp(() {
    mockService = MockODSDirectionsService();

    viewModel = NextClassViewModel(
      startLocation: const Location(45.4215, -75.6972, "", "", "", "", ""),
      endLocation: const Location(45.4215, -75.6972, "", "", "", "", ""),
      odsDirectionsService: mockService,
    );

    when(mockService.fetchStaticMapUrl(
      originAddress: anyNamed('originAddress'),
      destinationAddress: anyNamed('destinationAddress'),
      width: anyNamed('width'),
      height: anyNamed('height'),
    )).thenAnswer((_) async => 'https://placehold.co/600x400');
  });

  group('NextClassDirectionsPreview Tests', () {
    testWidgets('Next Class navigation should work with one classroom',
        (WidgetTester tester) async {
      // define routes needed for this test
      final routes = {
        '/': (context) => const HomePage(),
        '/IndoorDirectionsView': (context) => IndoorDirectionsView(
            sourceRoom: 'Your location',
            building: 'Hall Building',
            endRoom: '901'),
        '/NextClassDirectionsPreview': (context) {
          final routeArgs = ModalRoute.of(context)!.settings.arguments;
          List<Location> locations = [];
          if (routeArgs is List<Location>) {
            locations = routeArgs;
          }
          return NextClassDirectionsPreview(
              journeyItems: locations, viewModel: viewModel);
        },
      };

      // Build the HomePage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));

      // Tap on the Next Class directions FeatureCard
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle(); // Wait for navigation to complete

      // Tap the back button in the app bar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(); // Wait for navigation to complete
    });

    testWidgets('Next Class navigation should work with one classroom',
        (WidgetTester tester) async {
      // define routes needed for this test
      final routes = {
        '/': (context) => const HomePage(),
        '/IndoorDirectionsView': (context) => IndoorDirectionsView(
            sourceRoom: 'Your location',
            building: 'Hall Building',
            endRoom: '901'),
        '/NextClassDirectionsPreview': (context) {
          final routeArgs = ModalRoute.of(context)!.settings.arguments;
          List<Location> locations = [
            ConcordiaRoom(
                'H-801',
                RoomCategory.classroom,
                ConcordiaFloor("1", BuildingRepository.h),
                ConcordiaFloorPoint(
                    ConcordiaFloor("1", BuildingRepository.h), 0, 0))
          ];
          if (routeArgs is List<Location>) {
            locations = routeArgs;
          }
          return NextClassDirectionsPreview(
              journeyItems: locations, viewModel: viewModel);
        },
      };

      // Build the HomePage widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));

      // Tap on the Next Class directions FeatureCard
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle(); // Wait for navigation to complete

      // Tap the back button in the app bar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(); // Wait for navigation to complete
    });

    testWidgets('Journey items: Same Building Classroom',
        (WidgetTester tester) async {
      // Create mock locations for the same building
      final ConcordiaFloor room = ConcordiaFloor("8", BuildingRepository.h);
      final ConcordiaFloorPoint entrancePoint = ConcordiaFloorPoint(room, 0, 0);
      final source =
          ConcordiaRoom("3", RoomCategory.classroom, room, entrancePoint);
      final destination =
          ConcordiaRoom("7", RoomCategory.classroom, room, entrancePoint);

      // Initialize the widget with these locations and add the /HomePage route
      await tester.pumpWidget(MaterialApp(
        routes: {
          '/': (context) => NextClassDirectionsPreview(
              journeyItems: [source, destination], viewModel: viewModel),
          '/HomePage': (context) =>
              const HomePage(), // Make sure you have a HomePage widget
        },
        initialRoute: '/',
      ));

      // Check if the source and destination names are displayed correctly
      expect(find.text('Hall Building, 8.3 (SGW Campus)'), findsOneWidget);
      expect(find.text('Hall Building, 8.7 (SGW Campus)'), findsOneWidget);

      await tester.tap(find.text('Hall Building, 8.3 (SGW Campus)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Building'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hall Building'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Floor'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Floor 8'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Classroom').at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('03'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hall Building, 8.7 (SGW Campus)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Building'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hall Building'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Floor'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Floor 8'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Classroom'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('07'));
      await tester.pumpAndSettle();

      // Simulate tap on "Begin Navigation"
      await tester.tap(find.text("Begin Navigation"));
      await tester.pumpAndSettle();

      // Simulate tap on "Complete My Journey"
      await tester.tap(find.text("Complete My Journey"));
      await tester.pumpAndSettle();

      // Verify that HomePage is displayed
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Journey items: Different Building Classroom',
        (WidgetTester tester) async {
      // Create mock locations for the same building
      final ConcordiaFloor room = ConcordiaFloor("8", BuildingRepository.h);
      final ConcordiaFloor room2 = ConcordiaFloor("1", BuildingRepository.lb);
      final ConcordiaFloorPoint entrancePoint = ConcordiaFloorPoint(room, 0, 0);
      final source =
          ConcordiaRoom("04", RoomCategory.classroom, room, entrancePoint);
      final destination =
          ConcordiaRoom("07", RoomCategory.classroom, room2, entrancePoint);

      // Initialize the widget with these locations
      await tester.pumpWidget(MaterialApp(
        home: NextClassDirectionsPreview(
            journeyItems: [source, destination], viewModel: viewModel),
      ));

      // Check if the source and destination names are displayed correctly
      expect(find.text('Hall Building, 8.04 (SGW Campus)'), findsOneWidget);
      expect(find.text('J.W. McConnell Building, 1.07 (SGW Campus)'),
          findsOneWidget);

      // await tester.tap(find.text("Next"));
      // await tester.pumpAndSettle();

      // await tester.tap(find.text("Next"));
      // await tester.pumpAndSettle();

      // await tester.tap(find.text("Prev"));
      // await tester.pumpAndSettle();

      // await tester.tap(find.text("Next"));
      // await tester.pumpAndSettle();

      // await tester.tap(find.text("Begin Navigation"));
      // await tester.pumpAndSettle();
    });

    testWidgets('Journey items: Outdoor to Indoor',
        (WidgetTester tester) async {
      // Create mock locations for the same building
      final ConcordiaFloor room = ConcordiaFloor("8", BuildingRepository.h);
      final ConcordiaFloorPoint entrancePoint = ConcordiaFloorPoint(room, 0, 0);
      const source = Location(100.0, 100.0, '', '', '', '', '');

      final destination =
          ConcordiaRoom("07", RoomCategory.classroom, room, entrancePoint);

      // Initialize the widget with these locations
      await tester.pumpWidget(MaterialApp(
        home: NextClassDirectionsPreview(
            journeyItems: [source, destination], viewModel: viewModel),
      ));

      expect(find.text('Hall Building, 8.07 (SGW Campus)'), findsOneWidget);
    });
  });
}
