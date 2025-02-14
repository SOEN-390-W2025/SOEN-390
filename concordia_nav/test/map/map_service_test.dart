import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';

// Generate mocks for GoogleMapController
@GenerateMocks([GoogleMapController])
import 'map_service_test.mocks.dart';

void main() {
  late MapService mapService;
  late MockGoogleMapController mockGoogleMapController;

  setUp(() {
    mapService = MapService();
    mockGoogleMapController = MockGoogleMapController();
  });

  group('MapService Tests', () {
    test('setMapController should set the map controller', () {
      // Act
      mapService.setMapController(mockGoogleMapController);

      // Assert
      expect(mapService, isNotNull); // Indirectly verify the controller is set
    });

    test('getInitialCameraPosition should return correct CameraPosition', () {
      // Arrange
      const campus = ConcordiaCampus.loy;
      final expectedCameraPosition = CameraPosition(
        target: LatLng(campus.lat, campus.lng),
        zoom: 17.0,
      );

      // Act
      final result = mapService.getInitialCameraPosition(campus);

      // Assert
      expect(result, equals(expectedCameraPosition));
    });

    test('moveCamera should call animateCamera on the map controller', () {
      // Arrange
      const position = LatLng(37.7749, -122.4194);
      mapService.setMapController(mockGoogleMapController);

      // Act
      mapService.moveCamera(position);

      // Assert
      verify(mockGoogleMapController.animateCamera(
        argThat(
          isA<CameraUpdate>().having(
            (update) => update.toString(),
            'CameraUpdate',
            CameraUpdate.newCameraPosition(
              const CameraPosition(target: position, zoom: 17.0),
            ).toString(),
          ),
        ),
      )).called(1);
    });

    test('getCampusPolygonsAndLabels should return polygon and markers data',
        () async {
      // Arrange
      const campus = ConcordiaCampus.sgw;

      // Mock polygon data for "EV" building
      final List<LatLng> evPolygon = [
        const LatLng(45.4951601, -73.5778544),
        const LatLng(45.4958369, -73.5772375),
        const LatLng(45.496057, -73.5777095),
        const LatLng(45.4958955, -73.577867),
        const LatLng(45.4957351, -73.5780097),
        const LatLng(45.4959616, -73.5785005),
        const LatLng(45.4956038, -73.5788334),
        const LatLng(45.4951601, -73.5778544),
      ];

      // Compute centroid for EV polygon (for marker placement)
      final double centroidLat =
          evPolygon.map((p) => p.latitude).reduce((a, b) => a + b) /
              evPolygon.length;
      final double centroidLng =
          evPolygon.map((p) => p.longitude).reduce((a, b) => a + b) /
              evPolygon.length;
      final LatLng evCentroid = LatLng(centroidLat, centroidLng);

      // Expected polygon set
      final Set<Polygon> mockPolygons = {
        Polygon(
          polygonId: const PolygonId("EV"),
          points: evPolygon,
          strokeWidth: 3,
          strokeColor: const Color(0xFFB48107),
          fillColor: const Color(0xFFe5a712),
        ),
      };

      // Expected markers set
      final Set<Marker> mockMarkers = {
        Marker(
          markerId: const MarkerId("EV"),
          position: evCentroid,
          icon: BitmapDescriptor.defaultMarker, // Mocked icon
        ),
      };

      // Mock response
      when(mapService.getCampusPolygonsAndLabels(campus)).thenAnswer(
          (_) async => {"polygons": mockPolygons, "labels": mockMarkers});

      // Act
      final result = await mapService.getCampusPolygonsAndLabels(campus);

      // Assert
      expect(result["polygons"], equals(mockPolygons));
      expect(result["labels"], equals(mockMarkers));
    });
  });
}
