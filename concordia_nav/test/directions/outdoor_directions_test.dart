import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/place.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/services/outdoor_directions_service.dart';
import 'package:concordia_nav/ui/search/search_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:concordia_nav/widgets/compact_location_search_widget.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/outdoor_location/outdoor_location_map_view.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../map/map_viewmodel_test.mocks.dart' as map_mocks;
import '../map/map_viewmodel_test.mocks.dart';
import 'outdoor_directions_test.mocks.dart' as directions_mocks;
import '../settings/preferences_view_test.mocks.dart';
import 'outdoor_directions_test.mocks.dart';

@GenerateMocks([gda.DirectionsService, ODSDirectionsService])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  late map_mocks.MockMapViewModel mockMapViewModel;
  late map_mocks.MockMapService mockMapService;
  late ODSDirectionsService directionsService;
  late directions_mocks.MockDirectionsService mockDirectionsService;
  late TextEditingController originController;
  late TextEditingController destinationController;
  late MockPreferencesModel mockPreferencesModel;

  const Marker mockMarker = Marker(
    markerId: MarkerId('mock_marker'),
    alpha: 1.0,
    anchor: const Offset(0.5, 1.0),
    consumeTapEvents: false,
    draggable: false,
    flat: false,
    icon: BitmapDescriptor.defaultMarker,
    infoWindow: InfoWindow.noText,
    position:
        const LatLng(37.7749, -122.4194), // Example coordinates (San Francisco)
    rotation: 0.0,
    visible: true,
    zIndex: 0.0,
  );

  final Set<Polyline> mockPolylines = {
    const Polyline(
      polylineId: PolylineId('mock_polyline'),
      points: [
        LatLng(37.7749, -122.4194), // Example coordinates
        LatLng(37.7849, -122.4094),
      ],
      color: Color(0xFF0000FF), // Blue color
      width: 5,
    ),
  };

  setUp(() {
    mockMapViewModel = MockMapViewModel();
    mockMapService = MockMapService();
    originController = TextEditingController();
    destinationController = TextEditingController();

    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));
    when(mockMapViewModel.shuttleMarkersNotifier)
        .thenReturn(ValueNotifier<Set<Marker>>({}));
    when(mockMapViewModel.staticBusStopMarkers).thenReturn({});

    when(mockMapViewModel.getCampusPolygonsAndLabels(any))
        .thenAnswer((_) async {
      return {
        "polygons": <Polygon>{const Polygon(polygonId: PolygonId('polygon1'))},
        "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
      };
    });

    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });
    when(mockMapViewModel.fetchCurrentLocation())
        .thenAnswer((_) async => const LatLng(45.4215, -75.6992));
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);

    when(mockMapViewModel.mapService).thenReturn(mockMapService);
    when(mockMapViewModel.originMarker).thenReturn(mockMarker);
    when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
    when(mockMapViewModel.activePolylines).thenReturn(mockPolylines);
    when(mockMapViewModel.shuttleMarkersNotifier)
        .thenReturn(ValueNotifier<Set<Marker>>({}));
    when(mockMapViewModel.staticBusStopMarkers).thenReturn({});
    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});
    when(mockMapViewModel.multiModeRoutes)
        .thenReturn(<CustomTravelMode, Polyline>{});
    when(mockMapViewModel.activePolylines).thenReturn(<Polyline>{});

    mockDirectionsService = MockDirectionsService();
    directionsService = ODSDirectionsService();
    directionsService.directionsService = mockDirectionsService;
    mockPreferencesModel = MockPreferencesModel();
    when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
    when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');
  });

  group('fetchStaticMapUrl', () {
    test('should return a valid static map URL with polyline', () async {
      // Arrange
      const originAddress = "New York, NY";
      const destinationAddress = "Los Angeles, CA";
      const width = 600;
      const height = 400;

      // Mock the DirectionsService to return a valid response with a polyline
      when(mockDirectionsService.route(any, any)).thenAnswer((invocation) {
        final Function(gda.DirectionsResult, gda.DirectionsStatus?) callback =
            invocation.positionalArguments[1];

        // Simulate an immediate API response
        callback(
          const gda.DirectionsResult(routes: [
            gda.DirectionsRoute(
              overviewPolyline:
                  gda.OverviewPolyline(points: "encodedPolylineExample"),
            ),
          ]),
          gda.DirectionsStatus.ok,
        );

        return Future.value();
      });

      // Act
      final url = await directionsService.fetchStaticMapUrl(
        originAddress: originAddress,
        destinationAddress: destinationAddress,
        width: width,
        height: height,
      );

      // Assert
      expect(url, isNotNull);
      expect(url!.contains("https://maps.googleapis.com/maps/api/staticmap"),
          isTrue);
      expect(
          url.contains(
              "path=color:0xDE3355|weight:5|enc:encodedPolylineExample"),
          isTrue);
    });

    test('should return a valid static map URL with only markers', () async {
      // Arrange
      const originAddress = "New York, NY";
      const destinationAddress = "Los Angeles, CA";
      const width = 600;
      const height = 400;

      // Mock the DirectionsService to return a response without a polyline
      when(mockDirectionsService.route(any, any)).thenAnswer((invocation) {
        final Function(gda.DirectionsResult, gda.DirectionsStatus?) callback =
            invocation.positionalArguments[1];

        // Simulate an API response without polyline
        callback(
          const gda.DirectionsResult(routes: [
            gda.DirectionsRoute(
              overviewPolyline: gda.OverviewPolyline(points: ""),
            ),
          ]),
          gda.DirectionsStatus.ok,
        );

        return Future.value();
      });

      // Act
      final url = await directionsService.fetchStaticMapUrl(
        originAddress: originAddress,
        destinationAddress: destinationAddress,
        width: width,
        height: height,
      );

      // Assert
      expect(url, isNotNull);
      expect(url!.contains("https://maps.googleapis.com/maps/api/staticmap"),
          isTrue);
      expect(url.contains("markers="), isTrue);
      expect(url.contains("path=color:0xDE3355|weight:5|enc:"), isFalse);
    });

    test('should return a valid static map URL when API fails', () async {
      // Arrange
      const originAddress = "New York, NY";
      const destinationAddress = "Los Angeles, CA";
      const width = 600;
      const height = 400;

      // Mock the DirectionsService to simulate an API failure
      when(mockDirectionsService.route(any, any)).thenAnswer((invocation) {
        final Function(gda.DirectionsResult, gda.DirectionsStatus?) callback =
            invocation.positionalArguments[1];

        // Simulate API failure
        callback(
          const gda.DirectionsResult(routes: []),
          gda.DirectionsStatus.notFound,
        );

        return Future.value();
      });

      // Act
      final url = await directionsService.fetchStaticMapUrl(
        originAddress: originAddress,
        destinationAddress: destinationAddress,
        width: width,
        height: height,
      );

      // Assert
      expect(url, isNotNull);
      expect(url!.contains("https://maps.googleapis.com/maps/api/staticmap"),
          isTrue);
      expect(url.contains("markers="), isTrue);
    });
  });

  testWidgets(
      'Tapping on origin field should unselect building and call handleSelection',
      (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = {
      '/SearchView': (context) => const SearchView(),
    };

    await tester.pumpWidget(
      MaterialApp(
          home: CompactSearchCardWidget(
            originController: originController,
            destinationController: destinationController,
            mapViewModel: mockMapViewModel,
            searchList: ['Building A', 'Building B'],
          ),
          routes: routes),
    );

    final ValueNotifier<ConcordiaBuilding> selectedBuildingNotifier =
        ValueNotifier(BuildingRepository.h);

    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(selectedBuildingNotifier);

    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.hintText == 'Your Location'));

    await tester.pumpAndSettle();

    verify(mockMapViewModel.unselectBuilding()).called(1);
  });

  testWidgets(
      'Tapping on destination field should unselect building and call handleSelection',
      (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = {
      '/SearchView': (context) => const SearchView(),
    };

    await tester.pumpWidget(
      MaterialApp(
          home: CompactSearchCardWidget(
            originController: originController,
            destinationController: destinationController,
            mapViewModel: mockMapViewModel,
            searchList: ['Building A', 'Building B'],
          ),
          routes: routes),
    );

    final ValueNotifier<ConcordiaBuilding> selectedBuildingNotifier =
        ValueNotifier(BuildingRepository.h);

    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(selectedBuildingNotifier);

    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Enter Destination'));

    await tester.pumpAndSettle();

    verify(mockMapViewModel.unselectBuilding()).called(1);
  });

  testWidgets(
      'Button press triggers updatePath without start and end dests and fetches routes',
      (WidgetTester tester) async {
    // Create a mock MapViewModel
    when(mockMapViewModel.fetchRoutesForAllModes(any, any))
        .thenAnswer((_) async {});

    // Create a ConcordiaCampus and MapViewModel for the test
    const campus = ConcordiaCampus.sgw;

    // Build the widget tree
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
              campus: campus,
              building: BuildingRepository.h,
              mapViewModel: mockMapViewModel),
        )));

    // Get the state of OutdoorLocationMapView
    final state = tester.state<OutdoorLocationMapViewState>(
        find.byType(OutdoorLocationMapView));

    // Call setDefaultTravelMode on the state
    await state.setDefaultTravelMode();

    // Find the "Get Directions" button in the widget tree
    final buttonFinder = find.text('Get Directions');

    // Ensure the button exists
    expect(buttonFinder, findsOneWidget);

    // Tap the button to trigger updatePath
    await tester.tap(buttonFinder);

    // Rebuild the widget after the tap
    await tester.pump();
  });

  testWidgets('Button press triggers updatePath and fetches routes',
      (WidgetTester tester) async {
    // Create a mock MapViewModel
    when(mockMapViewModel.fetchRoutesForAllModes(any, any))
        .thenAnswer((_) async {});

    // Create a ConcordiaCampus and MapViewModel for the test
    const campus = ConcordiaCampus.sgw;

    final directions_mocks.MockODSDirectionsService mockDirectionsService =
        directions_mocks.MockODSDirectionsService();

    final expectedRoute = <LatLng>[
      const LatLng(45.4215, -75.6972),
      const LatLng(45.4216, -75.6969),
    ];

    when(mockDirectionsService.fetchRouteFromCoords(any, any,
            transport: anyNamed("transport")))
        .thenAnswer((_) async => expectedRoute);

    when(mockMapViewModel.odsDirectionsService)
        .thenReturn(mockDirectionsService);

    const start = Location(45.4215, -75.6992, "Start", null, null, null, null);
    const end = Location(45.4215, -75.6992, "End", null, null, null, null);

    // Build the widget tree
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
              campus: campus,
              building: BuildingRepository.h,
              mapViewModel: mockMapViewModel,
              providedJourneyStart: start,
              providedJourneyDest: end),
        )));

    // Find the "Get Directions" button in the widget tree
    final buttonFinder = find.text('Get Directions');

    // Ensure the button exists
    expect(buttonFinder, findsOneWidget);

    // Tap the button to trigger updatePath
    await tester.tap(buttonFinder);

    // Rebuild the widget after the tap
    await tester.pump();
  });

  testWidgets('widgets are present in the page', (WidgetTester tester) async {
    // Arrange
    const String origin = 'Current Location';
    const String destination = 'Destination Address';

    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    when(mockMapViewModel.fetchRoutesForAllModes(any, any))
        .thenAnswer((_) async {});

    // Build the widget tree
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
          ),
        )));

    // Enter text in the search bars
    await tester.enterText(find.byType(TextField).first, origin);
    await tester.enterText(find.byType(TextField).at(1), destination);

    // Manually trigger a state change to simulate keyboard visibility
    (tester.state<OutdoorLocationMapViewState>(
            find.byType(OutdoorLocationMapView)))
        // ignore: invalid_use_of_protected_member
        .setState(() {
      (tester.state<OutdoorLocationMapViewState>(
              find.byType(OutdoorLocationMapView)))
          .isKeyboardVisible = true;
    });

    // Pump the widget again to reflect the UI update
    await tester.pump();
  });

  testWidgets('outdoorLocationMapView with pois', (WidgetTester tester) async {
    // Arrange
    final place = Place(
        id: "1",
        name: "Allons Burger",
        location: const LatLng(45.49648751167641, -73.57862647170876),
        types: ["foodDrink"]);

    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    when(mockMapViewModel.fetchRoutesForAllModes(any, any))
        .thenAnswer((_) async {});

    // Build the widget tree
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
      create: (BuildContext context) => mockPreferencesModel,
      child: MaterialApp(
        home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
            additionalData: {
              "place": place,
              "destinationLatLng": const LatLng(45.4215, -75.6992)
            }),
      ),
    ));
    await tester.pump();

    final destination = find
        .byType(CompactSearchCardWidget)
        .evaluate()
        .single
        .widget as CompactSearchCardWidget;
    expect(destination.destinationController.text, place.name);
    expect(find.text("Directions to Allons Burger"), findsOneWidget);
  });

  testWidgets('outdoorLocationMapView with destination marker',
      (WidgetTester tester) async {
    // Arrange
    final place = Place(
        id: "1",
        name: "Allons Burger",
        location: const LatLng(45.49648751167641, -73.57862647170876),
        types: ["foodDrink"]);

    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    when(mockMapViewModel.fetchRoutesForAllModes(any, any))
        .thenAnswer((_) async {});
    when(mockMapViewModel.destinationMarker).thenReturn(null);

    // Build the widget tree
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
      create: (BuildContext context) => mockPreferencesModel,
      child: MaterialApp(
        home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
            additionalData: {
              "place": place,
              "destinationLatLng": const LatLng(45.4215, -75.6992)
            }),
      ),
    ));
    await tester.pump();

    expect(find.byType(GoogleMap), findsOneWidget);
  });

  test('fetchWalkingPolyline returns a polyline', () async {
    // Arrange
    const origin = 'New York, NY';
    const destination = 'Los Angeles, CA';
    const encodedPolyline = 'a~l~Fjk~uOwHJy@P';

    const mockResult = gda.DirectionsResult(
      routes: [
        gda.DirectionsRoute(
          overviewPolyline: gda.OverviewPolyline(points: encodedPolyline),
        )
      ],
    );

    when(mockDirectionsService.route(any, any)).thenAnswer((invocation) async {
      final Function(gda.DirectionsResult, gda.DirectionsStatus?) callback =
          invocation.positionalArguments[1];
      callback(mockResult, gda.DirectionsStatus.ok);
    });

    // Act
    final polyline = await directionsService.fetchWalkingPolyline(
        originAddress: origin, destinationAddress: destination);

    // Assert
    expect(polyline, isA<Polyline>());
  });

  test('fetchRoute returns a list of LatLng when API call is successful',
      () async {
    const origin = 'New York, NY';
    const destination = 'Los Angeles, CA';
    const encodedPolyline = 'a~l~Fjk~uOwHJy@P';

    const mockResult = gda.DirectionsResult(
      routes: [
        gda.DirectionsRoute(
          overviewPolyline: gda.OverviewPolyline(points: encodedPolyline),
        )
      ],
    );

    when(mockDirectionsService.route(any, any)).thenAnswer((invocation) async {
      final Function(gda.DirectionsResult, gda.DirectionsStatus?) callback =
          invocation.positionalArguments[1];
      callback(mockResult, gda.DirectionsStatus.ok);
    });

    final List<LatLng> result =
        await directionsService.fetchRoute(origin, destination);

    expect(result, isA<List<LatLng>>());
    expect(result.isNotEmpty, true);
  });

  test('fetchRoute throws an error when no routes are returned', () async {
    const origin = 'New York, NY';
    const destination = 'Los Angeles, CA';

    when(mockDirectionsService.route(any, any)).thenAnswer((invocation) async {
      throw Exception('An error occurred while fetching directions.');
    });

    expect(() async => await directionsService.fetchRoute(origin, destination),
        throwsA(isA<Exception>()));
  });

  test('fetchRouteFromCoords gets list of coordinates', () async {
    // Arrange
    const origin = LatLng(45.4215, -75.6972);
    const destination = LatLng(45.4216, -75.6969);
    const encodedPolyline = 'a~l~Fjk~uOwHJy@P';

    const mockResult = gda.DirectionsResult(
      routes: [
        gda.DirectionsRoute(
          overviewPolyline: gda.OverviewPolyline(points: encodedPolyline),
        )
      ],
    );

    when(mockDirectionsService.route(any, any)).thenAnswer((invocation) async {
      final Function(gda.DirectionsResult, gda.DirectionsStatus?) callback =
          invocation.positionalArguments[1];
      callback(mockResult, gda.DirectionsStatus.ok);
    });

    // Act
    final result =
        await directionsService.fetchRouteFromCoords(origin, destination);

    // Assert
    expect(result, isA<List<LatLng>>());
  });

  testWidgets('OutdoorLocationMapView displays polygons and labels correctly',
      (WidgetTester tester) async {
    // Mocking the getCampusPolygonsAndLabels method to return fake data
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    // Build the widget with mock MapViewModel
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
          ),
        )));

    // Wait for the FutureBuilders to resolve
    await tester.pumpAndSettle();

    // Verify that the MapLayout widget and MapWidget are rendered
    expect(find.byType(MapLayout), findsOneWidget);
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  testWidgets('mode chip is displayed', (WidgetTester tester) async {
    // Mocking the getCampusPolygonsAndLabels method to return fake data
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    final time = {
      CustomTravelMode.driving: "5",
      CustomTravelMode.walking: "20",
      CustomTravelMode.bicycling: "10",
      CustomTravelMode.transit: "10"
    };

    // mock travelTimes to not be null
    when(mockMapViewModel.travelTimes).thenReturn(time);
    when(mockMapViewModel.selectedTravelMode)
        .thenReturn(CustomTravelMode.driving);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    // Build the widget with mock MapViewModel
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
          ),
        )));

    // Wait for the FutureBuilders to resolve
    await tester.pumpAndSettle();

    // verify that the mode chip is displayed
    expect(find.byIcon(Icons.directions_car), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('tapping a mode chip sets it as active mode',
      (WidgetTester tester) async {
    // Mocking the getCampusPolygonsAndLabels method to return fake data
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    final time = {
      CustomTravelMode.driving: "5",
      CustomTravelMode.walking: "20",
      CustomTravelMode.bicycling: "10",
      CustomTravelMode.transit: "10"
    };

    // mock travelTimes to not be null
    when(mockMapViewModel.travelTimes).thenReturn(time);
    when(mockMapViewModel.selectedTravelMode)
        .thenReturn(CustomTravelMode.driving);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.walking))
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    // Build the widget with mock MapViewModel
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
          ),
        )));

    // Wait for the FutureBuilders to resolve
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.directions_walk));
    await tester.pumpAndSettle();

    // verify setActiveModeForRoute was called
    verify(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.walking))
        .called(1);
  });

  testWidgets('tapping a mode chip sets it as active mode',
      (WidgetTester tester) async {
    // Mocking the getCampusPolygonsAndLabels method to return fake data
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    final time = {
      CustomTravelMode.driving: "5",
      CustomTravelMode.walking: "20",
      CustomTravelMode.bicycling: "10",
      CustomTravelMode.transit: "10"
    };

    // mock travelTimes to not be null
    when(mockMapViewModel.travelTimes).thenReturn(time);
    when(mockMapViewModel.selectedTravelMode)
        .thenReturn(CustomTravelMode.transit);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.transit))
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });
    when(mockPreferencesModel.selectedTransportation).thenReturn('Transit');

    // Build the widget with mock MapViewModel
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
          ),
        )));

    // Wait for the FutureBuilders to resolve
    await tester.pumpAndSettle();

    verify(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.transit))
        .called(1);
  });

  testWidgets('with default destination', (WidgetTester tester) async {
    // Mocking the getCampusPolygonsAndLabels method to return fake data
    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
    final time = {
      CustomTravelMode.driving: "5",
      CustomTravelMode.walking: "20",
      CustomTravelMode.bicycling: "10",
      CustomTravelMode.transit: "10"
    };

    // mock travelTimes to not be null
    when(mockMapViewModel.travelTimes).thenReturn(time);
    when(mockMapViewModel.selectedTravelMode)
        .thenReturn(CustomTravelMode.transit);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.transit))
        .thenAnswer((_) async => true);
    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });
    when(mockPreferencesModel.selectedTransportation).thenReturn('Transit');
    when(mockMapViewModel.odsDirectionsService).thenReturn(directionsService);

    const start = Location(45.4215, -75.6992, "Start", null, null, null, null);
    const end = Location(45.4215, -75.6992, "End", null, null, null, null);
    // Build the widget with mock MapViewModel
    await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
            building: BuildingRepository.h,
            providedJourneyStart: start,
            providedJourneyDest: end,
          ),
        )));

    // Wait for the FutureBuilders to resolve
    await tester.pumpAndSettle();

    verify(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.transit))
        .called(1);
  });

  group('outdoor directions appBar', () {
    testWidgets('appBar has the right title with non-constant key',
        (WidgetTester tester) async {
      // Mocking the getCampusPolygonsAndLabels method to return fake data
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.travelTimes)
          .thenReturn(<CustomTravelMode, String>{});

      // Build the outdoor directions view widget
      await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
            home: OutdoorLocationMapView(
              key: UniqueKey(),
              campus: ConcordiaCampus.sgw,
              mapViewModel: mockMapViewModel,
            ),
          )));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Sir George Williams Campus'), findsOneWidget);
    });

    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Mocking the getCampusPolygonsAndLabels method to return fake data
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);
      when(mockMapViewModel.getAllCampusPolygonsAndLabels())
          .thenAnswer((_) async => {
                "polygons": <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
                "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
              });
      when(mockMapViewModel.travelTimes)
          .thenReturn(<CustomTravelMode, String>{});
      // Build the outdoor directions view widget
      await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
            home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw,
              mapViewModel: mockMapViewModel,
            ),
          )));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Sir George Williams Campus'), findsOneWidget);
    });
  });

  group('compact location search widget test', () {
    testWidgets('verify two TextFields exist', (WidgetTester tester) async {
      // Mocking the getCampusPolygonsAndLabels method to return fake data
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);
      when(mockMapViewModel.getAllCampusPolygonsAndLabels())
          .thenAnswer((_) async => {
                "polygons": <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
                "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
              });
      when(mockMapViewModel.travelTimes)
          .thenReturn(<CustomTravelMode, String>{});
      // Build the outdoor directions view widget
      await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
            home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw,
              mapViewModel: mockMapViewModel,
            ),
          )));
      await tester.pump();

      // Verify that two TextFields exist
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('source TextField has right hintText',
        (WidgetTester tester) async {
      // Mocking the getCampusPolygonsAndLabels method to return fake data
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);
      when(mockMapViewModel.getAllCampusPolygonsAndLabels())
          .thenAnswer((_) async => {
                "polygons": <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
                "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
              });
      when(mockMapViewModel.travelTimes)
          .thenReturn(<CustomTravelMode, String>{});
      // Build the outdoor directions view widget
      await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
            home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw,
              mapViewModel: mockMapViewModel,
            ),
          )));
      await tester.pump();

      // Find the source TextField
      final TextField sourceWidget = tester.widget(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(TextField).first,
        ),
      );

      // Verify hintText for the source TextField
      expect(sourceWidget.decoration?.hintText, 'Your Location');
    });

    testWidgets('destination TextField has right hintText',
        (WidgetTester tester) async {
      // Mocking the getCampusPolygonsAndLabels method to return fake data
      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);
      when(mockMapViewModel.getAllCampusPolygonsAndLabels())
          .thenAnswer((_) async => {
                "polygons": <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
                "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
              });
      when(mockMapViewModel.travelTimes)
          .thenReturn(<CustomTravelMode, String>{});
      // Build the outdoor directions view widget
      await tester.pumpWidget(ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
            home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw,
              mapViewModel: mockMapViewModel,
            ),
          )));
      await tester.pump();

      // Find the destination Textfield
      final TextField destinationWidget = tester.widget(
        find.descendant(
            of: find.byType(Column), matching: find.byType(TextField).last),
      );

      // Verify hintText for the destination TextField
      expect(destinationWidget.decoration?.hintText, 'Enter Destination');
    });

    test('shouldRepaint returns false', () {
      final oldDottedLinePainter = DottedLinePainter(color: Colors.black);

      // check that it returns false
      expect(
          DottedLinePainter(color: Colors.cyan)
              .shouldRepaint(oldDottedLinePainter),
          false);
    });

    test('Can create VerticalDottedLine', () {
      const verticalDottedLine = VerticalDottedLine(height: 5);

      // check object values are correct
      expect(verticalDottedLine.color, Colors.grey);
      expect(verticalDottedLine.dashSpace, 4);
      expect(verticalDottedLine.height, 5);
    });
  });
}
