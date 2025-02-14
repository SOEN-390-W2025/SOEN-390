import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:concordia_nav/data/repositories/map_repository.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';

import 'map_viewmodel_test.mocks.dart';

@GenerateMocks([MapRepository, MapService])
void main() {
  late MapViewModel mapViewModel;
  late MockMapRepository mockMapRepository;
  late MockMapService mockMapService;

  setUp(() {
    mockMapRepository = MockMapRepository();
    mockMapService = MockMapService();
    mapViewModel = MapViewModel(
        mapRepository: mockMapRepository, mapService: mockMapService);
  });

  group('MapViewModel Tests', () {
    test(
        'getInitialCameraPosition should return CameraPosition from repository',
        () async {
      // Arrange
      const campus = ConcordiaCampus.sgw;
      final expectedCameraPosition =
          CameraPosition(target: LatLng(campus.lat, campus.lng), zoom: 17.0);

      when(mockMapRepository.getCameraPosition(campus))
          .thenReturn(expectedCameraPosition);

      // Act
      final result = await mapViewModel.getInitialCameraPosition(campus);

      // Assert
      expect(result, equals(expectedCameraPosition));
    });

    test('onMapCreated should set map controller in map service', () {
      // Arrange
      final mockController = MockGoogleMapController();

      // Act
      mapViewModel.onMapCreated(mockController);

      // Assert
      verify(mockMapService.setMapController(mockController)).called(1);
    });

    test('switchCampus should move camera to new campus location', () {
      // Arrange
      const campus = ConcordiaCampus.loy;

      // Act
      mapViewModel.switchCampus(campus);

      // Assert
      verify(mockMapService.moveCamera(LatLng(campus.lat, campus.lng)))
          .called(1);
    });

    test('getCampusPolygonsAndLabels should return polygons and markers',
        () async {
      // Arrange
      const campus = ConcordiaCampus.sgw;
      final mockPolygons = <Polygon>{};
      final mockMarkers = <Marker>{};
      final mockData = {"polygons": mockPolygons, "labels": mockMarkers};

      when(mockMapService.getCampusPolygonsAndLabels(campus))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await mapViewModel.getCampusPolygonsAndLabels(campus);

      // Assert
      expect(result["polygons"], equals(mockPolygons));
      expect(result["labels"], equals(mockMarkers));
    });
  });
}

// Mock class for GoogleMapController
class MockGoogleMapController extends Mock implements GoogleMapController {}
