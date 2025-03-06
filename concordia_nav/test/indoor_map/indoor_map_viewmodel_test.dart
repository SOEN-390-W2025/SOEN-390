import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  late IndoorMapViewModel viewModel;

  setUp(() {
    viewModel = IndoorMapViewModel();
  });
  group('IndoorMapViewModel', () {
    test('Initial markers and polylines should be empty', () {
      expect(viewModel.markersNotifier.value, isEmpty);
      expect(viewModel.polylinesNotifier.value, isEmpty);
    });

    test('fetchRoutesForAllModes should select correct room', () async {
      await viewModel.fetchRoutesForAllModes('1', '2');
      expect(viewModel.selectedRoom, isNotNull);
      expect(viewModel.selectedRoom!.roomNumber, '2');
    });

    test('calculateDirections should add a polyline', () async {
      await viewModel.fetchRoutesForAllModes('1', '2');
      viewModel.calculateDirections();
      expect(viewModel.polylinesNotifier.value.length, 1);
    });

    test('_updateMarkers should update markers when a room is selected',
        () async {
      await viewModel.fetchRoutesForAllModes('1', '2');
      expect(viewModel.markersNotifier.value.length, 1);
    });

    test('_updateMarkers should clear markers when no room is selected', () {
      viewModel.selectedRoom = null;
      viewModel.updateMarkers();
      expect(viewModel.markersNotifier.value, isEmpty);
    });
  });
}
