import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/navigation_decision.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/journey/journey_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/widgets/journey/navigation_step_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../map/map_viewmodel_test.mocks.dart';
import 'journey_view_test.mocks.dart';

@GenerateMocks([NavigationDecision])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late MockMapViewModel mockMapViewModel;
  late MockMapService mockMapService;

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

  setUpAll(() {
    mockMapViewModel = MockMapViewModel();
    mockMapService = MockMapService();
    when(mockMapViewModel.selectedBuildingNotifier)
        .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));
    when(mockMapViewModel.mapService).thenReturn(mockMapService);
    when(mockMapViewModel.originMarker).thenReturn(mockMarker);
    when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
    when(mockMapViewModel.activePolylines).thenReturn(mockPolylines);
    when(mockMapViewModel.startShuttleBusTimer()).thenAnswer((_) async => true);
    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);
    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });
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
    when(mockMapViewModel.shuttleMarkersNotifier)
        .thenReturn(ValueNotifier<Set<Marker>>({}));
    when(mockMapViewModel.staticBusStopMarkers).thenReturn({});
    when(mockMapViewModel.travelTimes).thenReturn(<CustomTravelMode, String>{});
  });

  group('NavigationJourneyPage Tests', () {
    testWidgets('throws exception if journeyItems has less than 2 locations',
        (WidgetTester tester) async {
      // Capture Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        expect(details.exception, isA<Exception>());
      };

      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(
          home: NavigationJourneyPage(
            journeyItems: [
              Location(100, 100, "Mock location", null, null, null, null),
            ],
            journeyName: 'Test Journey',
          ),
        ));
      });

      // Reset FlutterError handling
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });

    testWidgets(
        'renders NavigationStepPage with correct page count and same building',
        (WidgetTester tester) async {
      final decision = MockNavigationDecision();
      when(decision.pageCount).thenReturn(1);

      await tester.pumpWidget(MaterialApp(
        home: NavigationJourneyPage(
          journeyItems: [
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
                    ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
          ],
          journeyName: 'Test Journey',
          decision: decision,
        ),
      ));

      expect(find.byType(NavigationStepPage), findsOneWidget);
    });

    testWidgets(
        'renders NavigationStepPage with correct page count and different buildings',
        (WidgetTester tester) async {
      final decision = MockNavigationDecision();
      when(decision.pageCount).thenReturn(3);

      await tester.pumpWidget(MaterialApp(
        home: NavigationJourneyPage(
          mapViewModel: mockMapViewModel,
          journeyItems: [
            ConcordiaRoom(
                'H-801',
                RoomCategory.classroom,
                ConcordiaFloor("1", BuildingRepository.h),
                ConcordiaFloorPoint(
                    ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
            ConcordiaRoom(
                'H-805',
                RoomCategory.classroom,
                ConcordiaFloor("1", BuildingRepository.lb),
                ConcordiaFloorPoint(
                    ConcordiaFloor("1", BuildingRepository.lb), 0, 0)),
          ],
          journeyName: 'Test Journey',
          decision: decision,
        ),
      ));

      expect(find.byType(NavigationStepPage), findsOneWidget);

      await tester.tap(find.text("Proceed to The Next Direction Step"));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationStepPage), findsOneWidget);

      await tester.tap(find.text("Proceed to The Next Direction Step"));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationStepPage), findsOneWidget);
    });

    testWidgets(
        'renders NavigationStepPage with correct page count and outdoor to classroom',
        (WidgetTester tester) async {
      final decision = MockNavigationDecision();
      when(decision.pageCount).thenReturn(2);

      await tester.pumpWidget(MaterialApp(
        home: NavigationJourneyPage(
          mapViewModel: mockMapViewModel,
          journeyItems: [
            BuildingRepository.h,
            ConcordiaRoom(
                'H-805',
                RoomCategory.classroom,
                ConcordiaFloor("1", BuildingRepository.h),
                ConcordiaFloorPoint(
                    ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
          ],
          journeyName: 'Test Journey',
          decision: decision,
        ),
      ));

      expect(find.byType(NavigationStepPage), findsOneWidget);

      await tester.tap(find.text("Proceed to The Next Direction Step"));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationStepPage), findsOneWidget);
    });
  });
}
