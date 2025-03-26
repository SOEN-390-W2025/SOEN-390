import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/campus_map/campus_map_view.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/ui/indoor_map/building_selection.dart';
import 'package:concordia_nav/ui/next_class/next_class_directions_view.dart';
import 'package:concordia_nav/ui/outdoor_location/outdoor_location_map_view.dart';
import 'package:concordia_nav/ui/poi/poi_choice_view.dart';
import 'package:concordia_nav/ui/smart_planner/smart_planner_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/home/homepage_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'map/map_viewmodel_test.mocks.dart';
import 'settings/preferences_view_test.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  late MockMapViewModel mockMapViewModel;
  late MockMapService mockMapService;
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
    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));
    when(mockMapViewModel.mapService).thenReturn(mockMapService);
    when(mockMapViewModel.originMarker).thenReturn(mockMarker);
    when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
    when(mockMapViewModel.activePolylines).thenReturn(mockPolylines);
    mockPreferencesModel = MockPreferencesModel();
    when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
    when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');
  });

  testWidgets('HomePage should render correctly', (WidgetTester tester) async {
    // Build the HomePage widget
    await tester.pumpWidget(const MaterialApp(home: const HomePage()));

    // Verify that the app bar is present and has the correct title
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Verify that the Concordia Campus Guide text and icon are present
    expect(find.text('Concordia Campus Guide'), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    // Verify that the SGW map and LOY map FeatureCards are present
    expect(find.text('SGW map'), findsOneWidget);
    expect(find.text('LOY map'), findsOneWidget);
    expect(find.byIcon(Icons.map), findsNWidgets(2));

    // Verify that the Outdoor directions and Navigation to Next Class FeatureCards are present
    expect(find.text('Outdoor directions'), findsOneWidget);
    expect(find.text('Navigation to Next Class'), findsOneWidget);
    expect(find.byIcon(Icons.maps_home_work), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    // Verify that the Floor Navigation and Find nearby facilities FeatureCards are present
    expect(find.text('Floor Navigation'), findsOneWidget);
    expect(find.text('Find nearby facilities'), findsOneWidget);
    expect(find.byIcon(Icons.meeting_room), findsOneWidget);
    expect(find.byIcon(Icons.wash), findsOneWidget);
  });

  testWidgets('should create new MapViewModel if none provided',
      (WidgetTester tester) async {
    // Arrange
    const campus = ConcordiaCampus.loy;
    when(mockMapViewModel.startShuttleBusTimer()).thenAnswer((_) async => true);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

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

    // Act
    await tester.pumpWidget(MaterialApp(
      home: CampusMapPage(
          campus: campus,
          mapViewModel: mockMapViewModel,
          buildMapViewModel: mockMapViewModel),
    ));

    // Assert
    final state = tester.state<CampusMapPageState>(find.byType(CampusMapPage));
    expect(state.mapViewModel, isA<MapViewModel>());
  });

  testWidgets('SGW campus navigation should work', (WidgetTester tester) async {
    // define routes needed for this test
    final routes = {
      '/HomePage': (context) => const HomePage(),
      '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel,
            buildMapViewModel: mockMapViewModel,
          ),
    };

    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));

    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.getCampusPolygonsAndLabels(any))
        .thenAnswer((_) async {
      return {
        "polygons": <Polygon>{const Polygon(polygonId: PolygonId('polygon1'))},
        "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
      };
    });

    when(mockMapViewModel.startShuttleBusTimer()).thenAnswer((_) async => true);
    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/HomePage',
      routes: routes,
    ));

    // Tap on the SGW map FeatureCard
    await tester.tap(find.text('SGW map'));
    await tester.pumpAndSettle();
    expect(find.text('Sir George Williams Campus'), findsOneWidget);

    // Press the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Loyola campus navigation should work',
      (WidgetTester tester) async {
    // define routes needed for this test
    final routes = {
      '/HomePage': (context) => const HomePage(),
      '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel,
            buildMapViewModel: mockMapViewModel,
          ),
    };

    when(mockMapViewModel.startShuttleBusTimer()).thenAnswer((_) async => true);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

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

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/HomePage',
      routes: routes,
    ));

    // Tap on the Loyola map FeatureCard
    await tester.tap(find.text('LOY map'));
    await tester.pumpAndSettle();
    expect(find.text('Loyola Campus'), findsOneWidget);

    // Press the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Floor Navigation navigation should work',
      (WidgetTester tester) async {
    // define routes needed for this test
    final routes = {
      '/': (context) => const HomePage(),
      '/BuildingSelection': (context) => const BuildingSelection(),
    };

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: routes,
    ));

    // Tap on the Floor Navigation FeatureCard
    await tester.tap(find.byIcon(Icons.meeting_room));
    await tester.pumpAndSettle(); // Wait for navigation to complete
    expect(find.text('Floor Navigation'), findsOneWidget);

    // Scroll down until the 'Floor Navigation' is visible
    while (!tester.any(find.text('Floor Navigation'))) {
      await tester.drag(
          find.byType(Scrollable), const Offset(0, -300)); // drag up
      await tester.pumpAndSettle(); // Wait for the scroll to finish
    }

    // Verify if the 'Floor Navigation' text is visible after scrolling
    expect(find.text('Floor Navigation'), findsOneWidget);

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Nearby Facilities navigation should work',
      (WidgetTester tester) async {
    // define routes needed for this test
    final routes = {
      '/': (context) => const HomePage(),
      '/POIChoiceView': (context) => const POIChoiceView(),
    };

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: routes,
    ));

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });

  testWidgets('Next Class navigation should work with two classrooms',
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
                  ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
          ConcordiaRoom(
              'H-805',
              RoomCategory.classroom,
              ConcordiaFloor("1", BuildingRepository.h),
              ConcordiaFloorPoint(
                  ConcordiaFloor("1", BuildingRepository.h), 0, 0))
        ];
        if (routeArgs is List<Location>) {
          locations = routeArgs;
        }
        return NextClassDirectionsPreview(journeyItems: locations);
      },
    };

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: routes,
    ));

    // Tap on the Navigation to Next Class FeatureCard
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });

  testWidgets('Outdoor Directions navigation should work',
      (WidgetTester tester) async {
    // Assemble
    when(mockMapViewModel.shuttleMarkersNotifier)
        .thenReturn(ValueNotifier<Set<Marker>>({}));
    when(mockMapViewModel.staticBusStopMarkers).thenReturn({});
    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});

    // define routes needed for this test
    final routes = {
      '/': (context) => const HomePage(),
      '/CampusMapPage': (context) => CampusMapPage(
            campus:
                ModalRoute.of(context)!.settings.arguments as ConcordiaCampus,
            mapViewModel: mockMapViewModel,
          ),
      '/OutdoorLocationMapView': (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return OutdoorLocationMapView(
          campus: args['campus'] as ConcordiaCampus,
          mapViewModel: mockMapViewModel,
        );
      },
    };

    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));

    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });

    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);

    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

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

    // Build the HomePage widget
    await tester.pumpWidget(
      ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
                initialRoute: '/',
                routes: routes,
              ),
      )
    );

    // Tap on the Outdoor Directions FeatureCard
    await tester.tap(find.text("Outdoor directions"));
    await tester.pumpAndSettle();

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });

  testWidgets('Smart Planner navigation should work',
      (WidgetTester tester) async {
    // define routes needed for this test
    final routes = {
      '/': (context) => const HomePage(),
      '/SmartPlannerView': (context) => const SmartPlannerView(),
    };

    // Build the HomePage widget
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: routes,
    ));
    await tester.pump();

    // Tap on the Menu button
    expect(find.byIcon(Icons.edit_note), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();

    // Tap the back button in the app bar
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Wait for navigation to complete
  });
}
