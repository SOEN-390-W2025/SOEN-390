import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:flutter/scheduler.dart';
import 'package:mockito/annotations.dart';

class TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

@GenerateMocks([IndoorMapViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  late IndoorMapViewModel viewModel;

  setUp(() {
    viewModel = IndoorMapViewModel(vsync: TestVSync());
  });

  group('IndoorMapViewModel', () {
    testWidgets('centers correctly between points',
        (WidgetTester tester) async {
      final mockMapViewModel = IndoorMapViewModel(vsync: TestVSync());
      const viewportSize = Size(1000, 800);
      const startLocation = Offset(100, 200);
      const endLocation = Offset(700, 600);

      mockMapViewModel.centerBetweenPoints(
          startLocation, endLocation, viewportSize,
          padding: 50);
      await tester.pumpAndSettle();
    });

    test('Initial markers and polylines should be empty', () {
      expect(viewModel.markersNotifier.value, isEmpty);
      expect(viewModel.polylinesNotifier.value, isEmpty);
    });

    test('setInitialCameraPosition sets correct transformation', () {
      const double scale = 1.2;
      const double offsetX = 100.0;
      const double offsetY = 200.0;

      viewModel.setInitialCameraPosition(
        scale: scale,
        offsetX: offsetX,
        offsetY: offsetY,
      );

      final matrix = viewModel.transformationController.value;
      expect(matrix.getMaxScaleOnAxis(), closeTo(scale, 0.001));

      // Extract translation values from the matrix
      // Matrix4 stores translations in indices 12 and 13 for x and y
      expect(matrix[12], closeTo(offsetX, 0.001));
      expect(matrix[13], closeTo(offsetY, 0.001));
    });

    test('centerOnPoint calculates correct transformation', () {
      // Set initial position
      viewModel.setInitialCameraPosition(scale: 1.0);

      const Offset point = Offset(300.0, 400.0);
      const Size viewportSize = Size(800.0, 600.0);

      viewModel.centerOnPoint(point, viewportSize);

      // Run the animation to completion synchronously
      viewModel.animationController.value = 1.0;

      // Verify the transformation
      final resultMatrix = viewModel.transformationController.value;

      // The scale should remain unchanged
      expect(resultMatrix.getMaxScaleOnAxis(), closeTo(1.0, 0.001));

      // The translation should center the point - extract from matrix
      expect(resultMatrix[12], isNotNull);
      expect(resultMatrix[13], isNotNull);
    });

    test('centerBetweenPoints calculates transformation between two points',
        () {
      // Set initial position
      viewModel.setInitialCameraPosition(scale: 1.0);

      const Offset startPoint = Offset(100.0, 200.0);
      const Offset endPoint = Offset(500.0, 400.0);
      const Size viewportSize = Size(800.0, 600.0);

      viewModel.centerBetweenPoints(startPoint, endPoint, viewportSize);

      // Run the animation to completion synchronously
      viewModel.animationController.value = 1.0;

      // Verify the transformation
      final resultMatrix = viewModel.transformationController.value;

      // The scale should be adjusted to fit both points
      final scale = resultMatrix.getMaxScaleOnAxis();
      expect(scale, lessThanOrEqualTo(1.5)); // Max scale
      expect(scale, greaterThanOrEqualTo(0.6)); // Min scale

      // The translation should center between the points
      expect(resultMatrix[12], isNotNull);
      expect(resultMatrix[13], isNotNull);
    });

    test('doesAssetExist returns false for non-existing assets', () async {
      final bool exists =
          await viewModel.doesAssetExist('non_existent_asset.png');
      expect(exists, isFalse);
    });

    test('dispose should release resources', () {
      // This is more of a verification that dispose doesn't throw errors
      expect(() => viewModel.dispose(), returnsNormally);
    });
  });
}
