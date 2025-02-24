import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/outdoor_location/outdoor_location_map_view.dart';
import 'package:concordia_nav/utils/building_drawer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/widgets/building_info_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../map/map_viewmodel_test.mocks.dart';
import 'building_info_drawer_test.mocks.dart';

@GenerateMocks([BuildingInfoDrawerViewModel])
void main() async {
  late MockBuildingInfoDrawerViewModel mockViewModel;
  late VoidCallback mockOnClose;
  late MockMapViewModel mockMapViewModel;
  late MockMapService mockMapService;
  late OutdoorLocationMapView mockMapView;

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
    mockViewModel = MockBuildingInfoDrawerViewModel();
    mockOnClose = () {};

    mockMapViewModel = MockMapViewModel();
    mockMapService = MockMapService();

    when(mockMapViewModel.getAllCampusPolygonsAndLabels())
        .thenAnswer((_) async => {
              "polygons": <Polygon>{
                const Polygon(polygonId: PolygonId('polygon1'))
              },
              "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
            });

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

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    when(mockMapService.checkAndRequestLocationPermission())
        .thenAnswer((_) async => true);

    when(mockMapViewModel.mapService).thenReturn(mockMapService);
    when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
    when(mockMapViewModel.polylines).thenReturn(mockPolylines);

    mockMapView = OutdoorLocationMapView(
        campus: ConcordiaCampus.sgw, mapViewModel: mockMapViewModel);
  });

  testWidgets('Close button calls drawerViewModel.closeDrawer',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingInfoDrawer(
              building: BuildingRepository.h,
              onClose: mockOnClose,
              viewModel: mockViewModel),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the close button
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);

    // Tap the close button
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    // Verify that closeDrawer was called
    verify(mockViewModel.closeDrawer(mockOnClose)).called(1);
  });

  testWidgets('Test BuildingInfoDrawer with mock map view',
      (WidgetTester tester) async {
    // Use the mock map view
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingInfoDrawer(
            building: BuildingRepository.h,
            onClose: () => true,
            outdoorLocationMapView: mockMapView, // Pass the mock map view here
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Simulate the button press to navigate to the mock map view
    final directionsButton = find.byIcon(Icons.directions);
    expect(directionsButton, findsOneWidget);

    await tester.tap(directionsButton);
    await tester.pumpAndSettle();

    // Verify that the mock map view was used
    expect(find.byType(OutdoorLocationMapView), findsOneWidget);
  });

  group('test building info drawer', () {
    testWidgets('drawer can render', (WidgetTester tester) async {
      // Build the buildinginfodrawer widget
      await tester.pumpWidget(MaterialApp(
          home: BuildingInfoDrawer(
              building: BuildingRepository.ad, onClose: () {})));

      // finds widgets
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byIcon(Icons.directions),
          findsOneWidget); // finds directions button
      expect(find.byIcon(Icons.map), findsOneWidget); // finds indoor map button
      expect(find.text(BuildingRepository.ad.name), findsOneWidget);
    });
  });
}
