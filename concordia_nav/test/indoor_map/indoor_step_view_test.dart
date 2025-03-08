import 'package:concordia_nav/ui/indoor_location/indoor_step_view.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_step_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'indoor_step_view_test.mocks.dart';

@GenerateMocks([VirtualStepGuideViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  late MockVirtualStepGuideViewModel mockViewModel;
  late IndoorMapViewModel viewModel;
  late IndoorDirectionsViewModel directionsViewModel;

  setUp(() {
    mockViewModel = MockVirtualStepGuideViewModel();
    viewModel = IndoorMapViewModel(vsync: const TestVSync());
    directionsViewModel = IndoorDirectionsViewModel();
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.indoorMapViewModel).thenReturn(viewModel);
    when(mockViewModel.directionsViewModel).thenReturn(directionsViewModel);
    when(mockViewModel.floorPlanPath).thenReturn('assets/floor_plan.svg');
    when(mockViewModel.sourceRoom).thenReturn('Room A');
    when(mockViewModel.building).thenReturn('Hall Building');
    when(mockViewModel.floor).thenReturn('Floor 1');
    when(mockViewModel.endRoom).thenReturn('Room B');
    when(mockViewModel.buildingAbbreviation).thenReturn("H");
    when(mockViewModel.width).thenReturn(0);
    when(mockViewModel.height).thenReturn(0);
    when(mockViewModel.currentStepIndex).thenReturn(0);
    when(mockViewModel.getRemainingTimeEstimate()).thenReturn('10 mins');
    when(mockViewModel.getRemainingDistanceEstimate()).thenReturn('200 meters');
    when(mockViewModel.isLoading).thenReturn(false);
  });

  group('VirtualStepGuideView Tests', () {
    testWidgets(
        'Displays "No navigation steps available" when there are no steps',
        (WidgetTester tester) async {
      when(mockViewModel.navigationSteps).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          home: VirtualStepGuideView(
            viewModel: mockViewModel,
            sourceRoom: 'Room A',
            building: 'Hall Building',
            floor: 'Floor 1',
            endRoom: 'Room B',
          ),
        ),
      );

      // Verify "No navigation steps available" text is displayed
      expect(find.text('No navigation steps available'), findsOneWidget);
    });

    testWidgets('Displays step details correctly', (WidgetTester tester) async {
      final step = NavigationStep(
        icon: Icons.arrow_forward,
        title: 'Go straight',
        description: 'Walk straight ahead for 20 meters',
        focusPoint: Offset.zero,
      );
      when(mockViewModel.navigationSteps).thenReturn([step]);
      when(mockViewModel.currentStepIndex).thenReturn(0);

      await tester.pumpWidget(
        MaterialApp(
          home: VirtualStepGuideView(
            viewModel: mockViewModel,
            sourceRoom: 'Room A',
            building: 'Hall Building',
            floor: 'Floor 1',
            endRoom: 'Room B',
          ),
        ),
      );

      // Check for the step icon, title, and description
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Go straight'), findsOneWidget);
      expect(find.text('Walk straight ahead for 20 meters'), findsOneWidget);
    });

    testWidgets('Displays step metrics when not first or last step',
        (WidgetTester tester) async {
      final step = NavigationStep(
        icon: Icons.arrow_forward,
        title: 'Go straight',
        description: 'Walk straight ahead for 20 meters',
        focusPoint: Offset.zero,
      );
      when(mockViewModel.navigationSteps).thenReturn([step, step, step]);
      when(mockViewModel.currentStepIndex).thenReturn(1); // Middle step

      // Mock methods for time and distance estimates
      when(mockViewModel.getCurrentStepTimeEstimate()).thenReturn('5 mins');
      when(mockViewModel.getCurrentStepDistanceEstimate())
          .thenReturn('100 meters');

      await tester.pumpWidget(
        MaterialApp(
          home: VirtualStepGuideView(
            viewModel: mockViewModel,
            sourceRoom: 'Room A',
            building: 'Hall Building',
            floor: 'Floor 1',
            endRoom: 'Room B',
          ),
        ),
      );

      // Check for time and distance estimates
      expect(find.text('5 mins'), findsOneWidget);
      expect(find.text('100 meters'), findsOneWidget);
    });

    testWidgets('Displays Finish button on last step',
        (WidgetTester tester) async {
      final step = NavigationStep(
        icon: Icons.arrow_forward,
        title: 'Go straight',
        description: 'Walk straight ahead for 20 meters',
        focusPoint: Offset.zero,
      );
      when(mockViewModel.navigationSteps).thenReturn([step, step, step]);
      when(mockViewModel.currentStepIndex).thenReturn(2); // Last step

      await tester.pumpWidget(
        MaterialApp(
          home: VirtualStepGuideView(
            viewModel: mockViewModel,
            sourceRoom: 'Room A',
            building: 'Hall Building',
            floor: 'Floor 1',
            endRoom: 'Room B',
          ),
        ),
      );

      // Check that the "Finish" button is displayed
      expect(find.text('Finish'), findsOneWidget);
    });
  });
}
