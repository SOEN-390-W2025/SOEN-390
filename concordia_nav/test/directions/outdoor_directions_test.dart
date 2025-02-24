import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/services/outdoor_directions_service.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:concordia_nav/widgets/search_bar.dart';
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

    when(mockMapViewModel.getCampusPolygonsAndLabels(any))
        .thenAnswer((_) async {
      return {
        "polygons": <Polygon>{const Polygon(polygonId: PolygonId('polygon1'))},
        "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
      };
    });

    when(mockMapViewModel.fetchMapData(ConcordiaCampus.sgw, false))
      .thenAnswer((_) async => {
        'cameraPosition': const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10),
              'polygons': <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
              'labels': <Marker>{const Marker(markerId: MarkerId('marker1'))}
      });

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);

    when(mockMapViewModel.mapService).thenReturn(mockMapService);
    when(mockMapViewModel.markers).thenReturn([mockMarker]);
    when(mockMapViewModel.polylines).thenReturn(mockPolylines);

    mockDirectionsService = MockDirectionsService();
    directionsService = ODSDirectionsService();
    directionsService.directionsService = mockDirectionsService;
  });

  testWidgets('widgets are present in the page',
      (WidgetTester tester) async {
    // Arrange
    const String origin = 'Current Location';
    const String destination = 'Destination Address';

    // Build the widget tree
    await tester.pumpWidget(MaterialApp(
      home: OutdoorLocationMapView(
          campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel),
    ));

    // Enter text in the search bars
    await tester.enterText(find.byType(SearchBarWidget).first, origin);
    await tester.enterText(find.byType(SearchBarWidget).at(1), destination);

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
/*
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
*/
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

  group('outdoor directions appBar', () {
    testWidgets('appBar has the right title with non-constant key',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              key: UniqueKey(), campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Outdoor Directions'), findsOneWidget);
    });

    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Outdoor Directions'), findsOneWidget);
    });
  });

  group('outdoor directions view page', () {
    testWidgets('verify two SearchBarWidgets exist',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Verify that two SearchBarWidgets exist
      expect(find.byType(SearchBarWidget), findsNWidgets(2));
    });

    testWidgets('source SearchBarWidget has right icon and hintText',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Find the source searchbarwidget
      final SearchBarWidget sourceWidget = tester.widget(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(SearchBarWidget).first,
        ),
      );

      const expectedIcon = const Icon(Icons.location_on);

      // Verify icon and hintText for the source SearchBar
      expect(sourceWidget.icon, expectedIcon.icon);
      expect(sourceWidget.hintText, 'Your Location');
    });

    testWidgets('destination SearchBarWidget has right icon and hintText',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Find the destination searchbarwidget
      final SearchBarWidget destinationWidget = tester.widget(
        find.descendant(
            of: find.byType(Positioned),
            matching: find.byType(SearchBarWidget).last),
      );

      const expectedIcon =
          const Icon(Icons.location_on, color: const Color(0xFFDA3A16));

      // Verify icon and hintText for the destination SearchBar
      expect(destinationWidget.icon, expectedIcon.icon);
      expect(destinationWidget.iconColor, expectedIcon.color);
      expect(destinationWidget.hintText, 'Enter Destination');
    });
  });
}
