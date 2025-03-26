import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/utils/next_class/next_class_directions_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../map/map_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  group('NextClassViewModel', () {
    late NextClassViewModel viewModel;
    late MockODSDirectionsService mockService;

    setUp(() {
      // Create mock service
      mockService = MockODSDirectionsService();

      // Initialize the view model with mock service
      viewModel = NextClassViewModel(
        startLocation: const Location(
            45.4215, -75.6972, "", "", "", "", ""), // Example start location
        endLocation: const Location(45.4215, -75.6972, "", "", "", "", ""),
      );
    });

    test('initial values are correctly set', () {
      // Verify the initial state of the view model
      expect(viewModel.startLocation.lat, 45.4215);
      expect(viewModel.startLocation.lng, -75.6972);
      expect(viewModel.endLocation.lat, 45.4215);
      expect(viewModel.endLocation.lng, -75.6972);
      expect(viewModel.staticMapUrl, null);
    });

    test('updateLocations updates start and end locations', () {
      const newStartLocation = Location(45.4215, -75.6972, "", "", "", "", "");
      const newEndLocation = Location(45.4215, -75.6972, "", "", "", "", "");
      // Update locations in the view model
      viewModel.updateLocations(
        startLocation: newStartLocation,
        endLocation: newEndLocation,
      );

      // Verify the locations are updated
      expect(viewModel.startLocation.lat, newStartLocation.lat);
      expect(viewModel.startLocation.lng, newStartLocation.lng);
      expect(viewModel.endLocation.lat, newEndLocation.lat);
      expect(viewModel.endLocation.lng, newEndLocation.lng);
    });

    test('fetchStaticMapWithSize returns a URL', () async {
      // Mock the response from ODSDirectionsService
      when(mockService.fetchStaticMapUrl(
        originAddress: '45.4215,-75.6972',
        destinationAddress: '45.423,-75.699',
        width: 400,
        height: 300,
      )).thenAnswer((_) async => 'http://example.com/staticmap.png');

      // Set the service in the view model to mock
      viewModel = NextClassViewModel(
          startLocation: const Location(
              45.4215, -75.6972, "", "", "", "", ""), // Example start location
          endLocation: const Location(45.423, -75.699, "", "", "", "", ""),
          odsDirectionsService: mockService);

      // Fetch the static map URL
      final mapUrl = await viewModel.fetchStaticMapWithSize(400, 300);

      // Verify the map URL is returned
      expect(mapUrl, 'http://example.com/staticmap.png');
      expect(viewModel.staticMapUrl, 'http://example.com/staticmap.png');
    });

    test('fetchStaticMapWithSize returns null if service fails', () async {
      // Mock the response from ODSDirectionsService to return null
      when(mockService.fetchStaticMapUrl(
        originAddress: '45.4215,-75.6972',
        destinationAddress: '45.423,-75.699',
        width: 400,
        height: 300,
      )).thenAnswer((_) async => null);

      viewModel = NextClassViewModel(
          startLocation: const Location(
              45.4215, -75.6972, "", "", "", "", ""), // Example start location
          endLocation: const Location(45.423, -75.699, "", "", "", "", ""),
          odsDirectionsService: mockService);

      // Fetch the static map URL
      final mapUrl = await viewModel.fetchStaticMapWithSize(400, 300);

      // Verify the map URL is null
      expect(mapUrl, null);
      expect(viewModel.staticMapUrl, null);
    });
  });
}
