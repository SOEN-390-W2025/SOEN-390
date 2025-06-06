import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/connection.dart';
import 'package:concordia_nav/data/domain-model/indoor_route.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/ui/indoor_location/indoor_step_view.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_map_viewmodel.dart';
import 'package:concordia_nav/utils/indoor_step_viewmodel.dart';
import 'package:concordia_nav/utils/settings/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../settings/preferences_view_test.mocks.dart';
import 'indoor_step_view_test.mocks.dart';

@GenerateMocks([VirtualStepGuideViewModel, IndoorDirectionsViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late MockVirtualStepGuideViewModel mockViewModel;
  late IndoorMapViewModel viewModel;
  late IndoorDirectionsViewModel directionsViewModel;
  late IndoorDirectionsViewModel mockDirectionsViewModel;
  late MockPreferencesModel mockPreferencesModel;

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
    mockPreferencesModel = MockPreferencesModel();
    when(mockPreferencesModel.selectedTransportation).thenReturn('Driving');
    when(mockPreferencesModel.selectedMeasurementUnit).thenReturn('Metric');
  });

  group('VirtualStepGuideView Tests', () {
    testWidgets(
        'Displays "No navigation steps available" when there are no steps',
        (WidgetTester tester) async {
      when(mockViewModel.navigationSteps).thenReturn([]);

      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: VirtualStepGuideView(
                    viewModel: mockViewModel,
                    sourceRoom: 'Room A',
                    building: 'Hall Building',
                    floor: 'Floor 1',
                    endRoom: 'Room B',
                    isMultiFloor: false,
                  ),
                ),
        )
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
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: VirtualStepGuideView(
                    viewModel: mockViewModel,
                    sourceRoom: 'Room A',
                    building: 'Hall Building',
                    floor: 'Floor 1',
                    endRoom: 'Room B',
                    isMultiFloor: false,
                  ),
                ),
        )
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
      when(mockViewModel.currentStepIndex).thenReturn(1);

      // Mock methods for time and distance estimates
      when(mockViewModel.getCurrentStepTimeEstimate()).thenReturn('5 mins');
      when(mockViewModel.getCurrentStepDistanceEstimate())
          .thenReturn('100 meters');

      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: VirtualStepGuideView(
                    viewModel: mockViewModel,
                    sourceRoom: 'H 827',
                    building: 'Hall Building',
                    floor: '8',
                    endRoom: 'H 830',
                    isMultiFloor: false,
                  ),
                ),
        )
      );
      
      expect(find.text('Go straight'), findsOneWidget);
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
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: VirtualStepGuideView(
                    viewModel: mockViewModel,
                    sourceRoom: 'Room A',
                    building: 'Hall Building',
                    floor: 'Floor 1',
                    endRoom: 'Room B',
                    isMultiFloor: false,
                  ),
                ),
        )
      );

      // Check that the "Finish" button is displayed
      expect(find.text('Finish'), findsOneWidget);
    });
  });

  group('IndoorStepViewmodel tests', () {
    VirtualStepGuideViewModel? indoorStepViewModel;

    setUp(() {
      mockDirectionsViewModel = MockIndoorDirectionsViewModel();
      when(mockDirectionsViewModel
              .getSvgDimensions('assets/maps/indoor/floorplans/H8.svg'))
          .thenAnswer((_) async => const Size(1024, 1024));
      when(mockDirectionsViewModel.startLocation)
          .thenReturn(const Offset(2, 4));
      when(mockDirectionsViewModel.endLocation).thenReturn(const Offset(6, 8));

      indoorStepViewModel = VirtualStepGuideViewModel(
          sourceRoom: '801',
          building: 'Hall Building',
          floor: '8',
          endRoom: '805',
          isDisability: false,
          vsync: const TestVSync(),
          directionsViewModel: mockDirectionsViewModel);
    });

    test('initializeRoute updates navigationSteps', () async {
      // Create IndoorRoute object
      const building = BuildingRepository.h;
      final floor1 = ConcordiaFloor('1', building, 1.0);
      final floor2 = ConcordiaFloor('2', building, 1.0);
      final floor3 = ConcordiaFloor('3', building, 1.0);
      final point1 = ConcordiaFloorPoint(floor1, 0.0, 0.0);
      final point2 = ConcordiaFloorPoint(floor1, 3.0, 4.0);
      final point3 = ConcordiaFloorPoint(floor2, 6.0, 8.0);
      final point4 = ConcordiaFloorPoint(floor3, 1.0, 2.0);
      final point5 = ConcordiaFloorPoint(floor3, 0.0, 0.0);

      final connection1 =
          Connection([floor1, floor2], {}, true, 'Elevator', 5.0, 3.0);
      final connection2 =
          Connection([floor2, floor3], {}, true, 'Stairs', 4.0, 2.5);

      final route = IndoorRoute(
        building,
        [point1, point2],
        connection1,
        [point3, point3],
        building,
        [point4, point4],
        connection2,
        [point4, point5],
      );

      when(mockDirectionsViewModel.calculateRoute(
              'Hall Building', '8', '801', '805', false))
          .thenAnswer((_) async => route);
      when(mockDirectionsViewModel.calculatedRoute).thenReturn(route);

      // Act
      await indoorStepViewModel?.initializeRoute();

      // verify method called
      verify(mockDirectionsViewModel.calculateRoute(
              'Hall Building', '8', '801', '805', false))
          .called(1);

      expect(indoorStepViewModel?.navigationSteps, isNotEmpty);
    });
  });

  group('Step-by-Step Navigation tests', () {
    testWidgets('test navigation between steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: const MaterialApp(
                  home: VirtualStepGuideView(
                    sourceRoom: '801',
                    building: 'Hall Building',
                    floor: '8',
                    endRoom: '805',
                    isMultiFloor: false,
                  ),
                ),
        )
      );
      await tester.pump();

      expect(find.text('Begin navigation from H 801'), findsOneWidget);

      // Simulate tapping the next button
      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // second step is shown
      expect(find.text('Prepare to turn left'), findsOneWidget);
      expect(find.byIcon(Icons.turn_left), findsOneWidget);

      // Simulate tapping the next button
      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // last step is shown
      expect(find.text('Finish'), findsOneWidget);
      expect(find.byIcon(Icons.place), findsOneWidget);
    });

    testWidgets('Can go back to previous step', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: const MaterialApp(
                  home: VirtualStepGuideView(
                    sourceRoom: '801',
                    building: 'Hall Building',
                    floor: '8',
                    endRoom: '805',
                    isMultiFloor: false,
                  ),
                ),
        )
      );
      await tester.pump();

      expect(find.text('Begin navigation from H 801'), findsOneWidget);

      // Simulate tapping the next button
      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // second step is shown
      expect(find.text('Prepare to turn left'), findsOneWidget);
      expect(find.byIcon(Icons.turn_left), findsOneWidget);

      // Simulate tapping the back button
      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
    });

    testWidgets('Selecting back in first step does nothing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: const MaterialApp(
                  home: VirtualStepGuideView(
                    sourceRoom: '801',
                    building: 'Hall Building',
                    floor: '8',
                    endRoom: '805',
                    isMultiFloor: false,
                  ),
                ),
        )
      );
      await tester.pump();

      expect(find.text('Begin navigation from H 801'), findsOneWidget);

      // Simulate tapping the back button
      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
    });

    testWidgets('Selecting finish on last page returns to IndoorDirectionsView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: IndoorDirectionsView(
                    sourceRoom: '801',
                    building: 'Hall Building',
                    endRoom: '805',
                  ),
                ),
        )
      );
      await tester.pump();

      // go to VirtualStepGuideView page
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Begin navigation from H 801'), findsOneWidget);

      // Simulate tapping the next button
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // second step is shown
      expect(find.text('Prepare to turn left'), findsOneWidget);

      // Simulate tapping the next button
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // last step is shown
      expect(find.text('Finish'), findsOneWidget);

      // Simulate tapping the Finish button
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Verify returned to Floor Navigation
      expect(find.text('Floor Navigation'), findsOneWidget);
    });

    testWidgets(
        'Selecting exit in step-by-step page returns to IndoorDirectionsView',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesModel>(
          create: (BuildContext context) => mockPreferencesModel,
          child: MaterialApp(
                  home: IndoorDirectionsView(
                    sourceRoom: '801',
                    building: 'Hall Building',
                    endRoom: '805',
                  ),
                ),
        )
      );
      await tester.pump();

      // go to VirtualStepGuideView page
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Begin navigation from H 801'), findsOneWidget);

      // Simulate tapping the next button
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      // Verify returned to Floor Navigation
      expect(find.text('Floor Navigation'), findsOneWidget);
    });
  });

  testWidgets('VirtualStepGuideView initializes and displays correctly',
      (WidgetTester tester) async {
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.navigationSteps).thenReturn([
      NavigationStep(
        icon: Icons.arrow_forward,
        title: 'Go straight',
        description: 'Walk straight ahead for 20 meters',
        focusPoint: Offset.zero,
      ),
    ]);
    when(mockViewModel.currentStepIndex).thenReturn(0);
    when(mockViewModel.getRemainingTimeEstimate()).thenReturn('10 mins');
    when(mockViewModel.getRemainingDistanceEstimate()).thenReturn('200 meters');

    await tester.pumpWidget(
      ChangeNotifierProvider<PreferencesModel>(
        create: (BuildContext context) => mockPreferencesModel,
        child: MaterialApp(
                home: VirtualStepGuideView(
                  sourceRoom: 'H 827',
                  building: 'Hall Building',
                  floor: '8',
                  endRoom: 'H 830',
                  isMultiFloor: false,
                  viewModel: mockViewModel,
                ),
              ),
      )
    );

    // Get the state and call extractFloor
    final state = tester.state(find.byType(VirtualStepGuideView))
        as VirtualStepGuideViewState;
    final floor = state.extractFloor('H 827');
    expect(floor, '8');

    // Verify the initial state of the widget
    expect(find.text('Step-by-Step Guide'), findsOneWidget);
    expect(find.text('Go straight'), findsOneWidget);
    expect(find.text('Walk straight ahead for 20 meters'), findsOneWidget);
    expect(find.text('10 mins'), findsOneWidget);
    expect(find.text('200 meters'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);
  });
}
