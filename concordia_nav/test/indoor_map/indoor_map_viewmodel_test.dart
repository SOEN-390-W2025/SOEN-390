import 'package:concordia_nav/data/domain-model/concordia_building.dart';
import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_location_view.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  late IndoorMapViewModel viewModel;

  setUp(() {
    viewModel = IndoorMapViewModel(vsync: TestVSync());
  });

  group('IndoorMapViewModel', () {
    test('getInitialCameraPositionFloor returns correct camera position',
        () async {
      final viewModel = IndoorMapViewModel(vsync: TestVSync());
      final floor = ConcordiaFloor(
        '1',
        const ConcordiaBuilding(
          45.4972159,
          -73.5790067,
          'Hall Building',
          '1455 Boulevard de Maisonneuve O',
          'Montreal',
          'QC',
          'H3G 1M8',
          'H',
          ConcordiaCampus.sgw,
        ),
      );

      final cameraPosition =
          await viewModel.getInitialCameraPositionFloor(floor);

      expect(cameraPosition.target.latitude, 45.4972159);
      expect(cameraPosition.target.longitude, -73.5790067);
      expect(cameraPosition.zoom, 18.0);
    });

    testWidgets('panToRegion updates transformation matrix',
        (WidgetTester tester) async {
      // Build the widget tree
      final viewModel = IndoorMapViewModel(vsync: TestVSync());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndoorLocationView(viewModel: viewModel),
          ),
        ),
      );

      // Trigger the panToRegion function
      viewModel.panToRegion(offsetX: 100.0, offsetY: 50.0);

      // Wait for the animation to complete
      await tester.pumpAndSettle();

      // Get the matrix after the animation is completed
      final matrix = viewModel.transformationController.value;
      expect(matrix[12], 100.0);
      expect(matrix[13], 50.0);
    });

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
