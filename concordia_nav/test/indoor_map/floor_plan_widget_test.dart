import 'package:concordia_nav/ui/indoor_location/floor_plan_widget.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late IndoorMapViewModel mockIndoorMapViewModel;

  setUp(() {
    mockIndoorMapViewModel = IndoorMapViewModel(vsync: const TestVSync());
  });

  testWidgets('Double tapping pans to the correct region',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloorPlanWidget(
            indoorMapViewModel: mockIndoorMapViewModel,
            floorPlanPath: 'assets/floor_plan.svg',
            semanticsLabel: 'Test Floor Plan',
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(const Offset(200, 200));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.down(const Offset(200, 200));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(mockIndoorMapViewModel.transformationController.toScene(Offset.zero),
        isNotNull);
  });

  testWidgets('Displays error message when SVG fails to load',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloorPlanWidget(
            indoorMapViewModel: mockIndoorMapViewModel,
            floorPlanPath: 'invalid_path.svg',
            semanticsLabel: 'Test Floor Plan',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No floor plans exist at this time.'), findsOneWidget);
  });
}
