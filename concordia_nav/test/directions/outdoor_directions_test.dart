import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/services/outdoor_directions_service.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/widgets/compact_location_search_widget.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/outdoor_location/outdoor_location_map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../map/map_viewmodel_test.mocks.dart';
import 'outdoor_directions_test.mocks.dart';

@GenerateMocks([gda.DirectionsService, ODSDirectionsService])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  late MockMapViewModel mockMapViewModel;
  late MockMapService mockMapService;
  late ODSDirectionsService directionsService;
  late MockDirectionsService mockDirectionsService;

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

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);

    when(mockMapViewModel.mapService).thenReturn(mockMapService);
    when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
    when(mockMapViewModel.activePolylines).thenReturn(mockPolylines);

    mockDirectionsService = MockDirectionsService();
    directionsService = ODSDirectionsService();
    directionsService.directionsService = mockDirectionsService;
  });

  testWidgets('should call fetchRoute when valid data is provided',
      (WidgetTester tester) async {
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
    await tester.pumpWidget(MaterialApp(
      home: OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel),
    ));

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

    // Verify the button is now visible
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Tap the 'Get Directions' button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify if fetchRoute was called
    verify(mockMapViewModel.fetchRoutesForAllModes(origin, destination))
        .called(1);
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
    await tester.pumpWidget(MaterialApp(
      home: OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel),
    ));

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
    await tester.pumpWidget(MaterialApp(
      home: OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel),
    ));

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
    await tester.pumpWidget(MaterialApp(
      home: OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel),
    ));

    // Wait for the FutureBuilders to resolve
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.directions_walk));
    await tester.pumpAndSettle();

    // verify setActiveModeForRoute was called
    verify(mockMapViewModel.setActiveModeForRoute(CustomTravelMode.walking))
        .called(1);
  });

  group('outdoor directions appBar', () {
    testWidgets('appBar has the right title with non-constant key',
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
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              key: UniqueKey(),
              campus: ConcordiaCampus.sgw,
              mapViewModel: mockMapViewModel)));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Outdoor Location'), findsOneWidget);
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
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel)));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Outdoor Location'), findsOneWidget);
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
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel)));
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
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
        campus: ConcordiaCampus.sgw,
        mapViewModel: mockMapViewModel,
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
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel)));
      await tester.pump();

      // Find the destination Textfield
      final TextField destinationWidget = tester.widget(
        find.descendant(
            of: find.byType(Column), matching: find.byType(TextField).last),
      );

      // Verify hintText for the destination TextField
      expect(destinationWidget.decoration?.hintText, 'Enter Destination');
    });

    testWidgets('tapping the source text field closes drawer if open',
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
      when(mockMapViewModel.selectedBuildingNotifier)
          .thenReturn(ValueNotifier<ConcordiaBuilding?>(BuildingRepository.h));

      // Build the outdoor directions view widget
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel)));
      await tester.pump();

      // Find the source Textfield
      final destinationWidget = find.descendant(
          of: find.byType(Column), matching: find.byType(TextField).first);

      await tester.tap(destinationWidget);
      await tester.pumpAndSettle();

      // check that unselectBuilding was called
      verify(mockMapViewModel.unselectBuilding()).called(1);
    });

    testWidgets('tapping the destination text field closes drawer if open',
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
      when(mockMapViewModel.selectedBuildingNotifier)
          .thenReturn(ValueNotifier<ConcordiaBuilding?>(BuildingRepository.h));

      // Build the outdoor directions view widget
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel)));
      await tester.pump();

      // Find the destination Textfield
      final destinationWidget = find.descendant(
          of: find.byType(Column), matching: find.byType(TextField).last);

      await tester.tap(destinationWidget);
      await tester.pumpAndSettle();

      // check that unselectBuilding was called
      verify(mockMapViewModel.unselectBuilding()).called(1);
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
