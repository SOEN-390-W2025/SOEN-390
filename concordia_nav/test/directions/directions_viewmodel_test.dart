import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:concordia_nav/utils/directions_viewmodel.dart';

import '../map/map_service_test.mocks.dart';
import 'outdoor_directions_test.mocks.dart';

// Generate mocks for the required services
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  late DirectionsViewModel viewModel;
  late MockODSDirectionsService mockDirectionsService;
  late MockMapService mockMapService;

  setUp(() {
    mockDirectionsService = MockODSDirectionsService();
    mockMapService = MockMapService();
    viewModel = DirectionsViewModel();

    viewModel.directionsService = mockDirectionsService;
    viewModel.mapService = mockMapService;
  });

  group('DirectionsViewModel', () {
    const String originAddress = "1455 Blvd. De Maisonneuve O, Montreal, QC";
    const String destinationAddress = "7141 Sherbrooke St W, Montreal, QC";
    final List<LatLng> fakePolyline = [
      const LatLng(45.4973, -73.578),
      const LatLng(45.5000, -73.590),
    ];

    test('should return polyline when origin is provided', () async {
      // Arrange
      when(mockDirectionsService.fetchRoute(any, any))
          .thenAnswer((_) async => fakePolyline);

      // Act
      final result =
          await viewModel.getRoutePolyline(originAddress, destinationAddress);

      // Assert
      expect(result, fakePolyline);
      verify(mockDirectionsService.fetchRoute(
              originAddress, destinationAddress))
          .called(1);
    });

    test(
        'should fetch current location and return polyline if no origin is provided',
        () async {
      // Arrange
      const LatLng mockLocation = LatLng(45.4973, -73.578);
      when(mockMapService.getCurrentLocation())
          .thenAnswer((_) async => mockLocation);
      when(mockDirectionsService.fetchRoute(any, any))
          .thenAnswer((_) async => fakePolyline);

      // Act
      final result = await viewModel.getRoutePolyline(null, destinationAddress);

      // Assert
      expect(result, fakePolyline);
      verify(mockMapService.getCurrentLocation()).called(1);
      verify(mockDirectionsService.fetchRoute(
              "${mockLocation.latitude},${mockLocation.longitude}",
              destinationAddress))
          .called(1);
    });

    test('should throw an exception if current location is unavailable',
        () async {
      // Arrange
      when(mockMapService.getCurrentLocation()).thenAnswer((_) async => null);

      // Act & Assert
      expect(() => viewModel.getRoutePolyline(null, destinationAddress),
          throwsException);
      verify(mockMapService.getCurrentLocation()).called(1);
      verifyNever(mockDirectionsService.fetchRoute(any, any));
    });

    test('should throw an exception if fetchRoute fails', () async {
      // Arrange
      when(mockDirectionsService.fetchRoute(any, any))
          .thenThrow(Exception("Failed to fetch route"));

      // Act & Assert
      expect(
          () => viewModel.getRoutePolyline(originAddress, destinationAddress),
          throwsException);
      verify(mockDirectionsService.fetchRoute(
              originAddress, destinationAddress))
          .called(1);
    });
  });
}
