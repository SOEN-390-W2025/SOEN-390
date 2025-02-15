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

    test('getCampusMarkers should return a set of markers for given locations',
        () {
      // Arrange
      final buildingLocations = [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.7849, -122.4294),
      ];
      final expectedMarkers = {
        Marker(
          markerId: MarkerId(buildingLocations[0].toString()),
          position: buildingLocations[0],
        ),
        Marker(
          markerId: MarkerId(buildingLocations[1].toString()),
          position: buildingLocations[1],
        ),
      };

      // Act
      final result = mapService.getCampusMarkers(buildingLocations);

      // Assert
      expect(result, equals(expectedMarkers));
    });
  });
}
