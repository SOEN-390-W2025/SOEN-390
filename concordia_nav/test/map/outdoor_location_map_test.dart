import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/outdoor_location/outdoor_location_map_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart' as gda;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

import 'map_viewmodel_test.mocks.dart';

void main() {
  group('OutdoorLocationMapViewState', () {
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
      position: const LatLng(
          37.7749, -122.4194), // Example coordinates (San Francisco)
      rotation: 0.0,
      visible: true,
      zIndex: 0.0,
    );

    final Map<CustomTravelMode, String> mockTravelTimes = {
      CustomTravelMode.walking: "15 mins",
      CustomTravelMode.shuttle: "25 mins",
      CustomTravelMode.bicycling: "40 mins",
    };

    final Set<Marker> mockStaticBusStopMarkers = {
      const Marker(
        markerId: MarkerId('mock_marker'),
        alpha: 1.0,
        anchor: Offset(0.5, 1.0),
        consumeTapEvents: false,
        draggable: false,
        flat: false,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow.noText,
        position:
            LatLng(37.7749, -122.4194), // Example coordinates (San Francisco)
        rotation: 0.0,
        visible: true,
        zIndex: 0.0,
      ),
    };

    // Create a mock ValueNotifier with a Set of Marker objects
    final ValueNotifier<Set<Marker>> mockShuttleMarkersNotifier =
        ValueNotifier<Set<Marker>>({});

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

      when(mockMapViewModel.staticBusStopMarkers)
          .thenReturn(mockStaticBusStopMarkers);

      when(mockMapViewModel.travelTimes).thenReturn(mockTravelTimes);

      when(mockMapViewModel.selectedTravelMode)
          .thenReturn(CustomTravelMode.walking);

      when(mockMapViewModel.activePolylines).thenReturn(mockPolylines);

      when(mockMapViewModel.shuttleAvailable).thenReturn(false);

      when(mockMapViewModel.shuttleMarkersNotifier)
          .thenReturn(mockShuttleMarkersNotifier);

      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.selectedBuildingNotifier)
          .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));
      when(mockMapViewModel.shuttleMarkersNotifier)
          .thenReturn(ValueNotifier<Set<Marker>>({}));
      when(mockMapViewModel.staticBusStopMarkers).thenReturn({});

      when(mockMapViewModel.getCampusPolygonsAndLabels(any))
          .thenAnswer((_) async {
        return {
          "polygons": <Polygon>{
            const Polygon(polygonId: PolygonId('polygon1'))
          },
          "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
        };
      });

      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.mapService).thenReturn(mockMapService);
      when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
      when(mockMapViewModel.activePolylines).thenReturn(mockPolylines);

      when(mockMapViewModel.getAllCampusPolygonsAndLabels())
          .thenAnswer((_) async => {
                "polygons": <Polygon>{
                  const Polygon(polygonId: PolygonId('polygon1'))
                },
                "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
              });

      when(mockMapViewModel.checkLocationAccess())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.selectedBuildingNotifier)
          .thenReturn(ValueNotifier<ConcordiaBuilding?>(null));

      when(mockMapViewModel.staticBusStopMarkers)
          .thenReturn(mockStaticBusStopMarkers);

      when(mockMapViewModel.getCampusPolygonsAndLabels(any))
          .thenAnswer((_) async {
        return {
          "polygons": <Polygon>{
            const Polygon(polygonId: PolygonId('polygon1'))
          },
          "labels": <Marker>{const Marker(markerId: MarkerId('marker1'))}
        };
      });

      when(mockMapViewModel.getInitialCameraPosition(any))
          .thenAnswer((_) async {
        return const CameraPosition(
            target: LatLng(45.4215, -75.6992), zoom: 10);
      });

      when(mockMapService.checkAndRequestLocationPermission())
          .thenAnswer((_) async => true);

      when(mockMapViewModel.mapService).thenReturn(mockMapService);
      when(mockMapViewModel.destinationMarker).thenReturn(mockMarker);
      when(mockMapService.getPolylines()).thenReturn(mockPolylines);
    });

    testWidgets('updateBuilding should update destination controller text',
        (WidgetTester tester) async {
      // Create a mock ConcordiaBuilding with a street address
      const mockBuilding = BuildingRepository.h;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: OutdoorLocationMapView(
            campus: ConcordiaCampus.sgw,
            mapViewModel: mockMapViewModel,
          ),
        ),
      );

      // Find the destination text field
      final destinationField = find.byType(TextField).first;

      // Verify that the initial text is empty or whatever default value it should be
      expect(tester.widget<TextField>(destinationField).controller?.text, '');

      // Get the state of the widget to call updateBuilding
      final state = tester.state<OutdoorLocationMapViewState>(
        find.byType(OutdoorLocationMapView),
      );

      // Act: Call updateBuilding with the mock building
      state.updateBuilding(mockBuilding);

      // Wait for any asynchronous UI updates to settle
      await tester.pumpAndSettle();

      // Assert: Verify that the destination controller's text is updated to the mock building's street address
      expect(tester.widget<TextField>(destinationField).controller?.text, '');
    });

    group('toGdaTravelMode', () {
      test('should return null when CustomTravelMode.shuttle is passed', () {
        // Act: Call the function with CustomTravelMode.shuttle
        final result = toGdaTravelMode(CustomTravelMode.shuttle);

        // Assert: Verify the result is null
        expect(result, null);
      });

      // You can also add tests for other modes to verify they work as expected
      test('should return correct GDA TravelMode for driving', () {
        final result = toGdaTravelMode(CustomTravelMode.driving);
        expect(result, gda.TravelMode.driving);
      });

      test('should return correct GDA TravelMode for walking', () {
        final result = toGdaTravelMode(CustomTravelMode.walking);
        expect(result, gda.TravelMode.walking);
      });

      test('should return correct GDA TravelMode for bicycling', () {
        final result = toGdaTravelMode(CustomTravelMode.bicycling);
        expect(result, gda.TravelMode.bicycling);
      });

      test('should return correct GDA TravelMode for transit', () {
        final result = toGdaTravelMode(CustomTravelMode.transit);
        expect(result, gda.TravelMode.transit);
      });
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
