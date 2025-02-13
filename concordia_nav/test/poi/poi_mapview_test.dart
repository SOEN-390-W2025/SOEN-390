import 'package:concordia_nav/data/domain-model/poi.dart';
import 'package:concordia_nav/ui/poi/poi_choice_view.dart';
import 'package:concordia_nav/ui/poi/poi_map_view.dart';
import 'package:concordia_nav/utils/poi/poi_viewmodel.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:concordia_nav/data/repositories/poi_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateMocks([POIRepository])
import 'poi_mapview_test.mocks.dart';

class MockPOIViewModel extends Mock implements POIViewModel {}

void main() {
  late POIViewModel viewModel;
  late MockPOIRepository mockRepository;

  setUp(() {
    mockRepository = MockPOIRepository();

    // Mock successful data fetching
    when(mockRepository.fetchPOIData()).thenAnswer((_) async => [
          POIModel(title: 'Title1', icon: Icons.place, route: '/route1'),
          POIModel(title: 'Title2', icon: Icons.place, route: '/route2'),
        ]);

    viewModel = POIViewModel(repository: mockRepository);
  });

  testWidgets('shows error message when POIViewModel has error message',
      (WidgetTester tester) async {
    // Arrange: Mock the POIRepository to simulate an error in loading POI data
    when(mockRepository.fetchPOIData())
        .thenThrow(Exception('Failed to load data'));

    // Build the POIChoiceView wrapped with ChangeNotifierProvider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<POIViewModel>(
          create: (_) => POIViewModel(repository: mockRepository),
          child: POIChoiceView(
              viewModel: POIViewModel(
                  repository: mockRepository)), // Injecting viewModel
        ),
      ),
    );

    // Wait for the view model to fetch data (this may take a few frames)
    await tester.pumpAndSettle();

    // Act: Trigger the state change after error message is set
    final errorMessageTextFinder =
        find.text('Failed to load data. Try again later.');

    // Assert: Verify that the error message is shown in the UI
    expect(errorMessageTextFinder, findsOneWidget);
  });

  test('loadPOIData sets errorMessage when repository throws an exception',
      () async {
    // Arrange
    when(mockRepository.fetchPOIData()).thenThrow(Exception('Network Error'));

    // Act
    await viewModel.loadPOIData();

    // Assert
    expect(viewModel.errorMessage,
        equals('Failed to load data. Try again later.'));
    expect(viewModel.isLoading, isFalse);
  });

  group('poi_map_view appBar', () {
    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(MaterialApp(home: POIMapView(key: UniqueKey())));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Nearby Facility'), findsWidgets);
    });

    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Nearby Facility'), findsWidgets);
    });

    testWidgets('tapping back btn in appBar brings back to poiPage',
        (WidgetTester tester) async {
      // define routes needed for this test
      final routes = {
        '/': (context) => const POIChoiceView(),
        '/POIMapView': (context) => const POIMapView(),
      };

      // Build the POIChoiceView widget
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: routes,
      ));
      await tester.pumpAndSettle();

      // tap on restrooms PoiBox
      await tester.tap(find.text('Restrooms'));
      await tester.pumpAndSettle(); // wait till change page
      expect(find.text('Nearby Facility'), findsWidgets);

      // find the back button and tap it
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(); // wait till screen changes

      // Should be in POI page
      expect(find.text('Nearby Facilities'), findsOneWidget);
    });
  });

  group('POI map view page', () {
    testWidgets('mapLayout widget exists', (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // Verify that MapLayout widget exists
      expect(find.byType(MapLayout), findsOneWidget);
    });

    testWidgets('time and distance text fields exist',
        (WidgetTester tester) async {
      // Build the POI map view widget
      await tester.pumpWidget(const MaterialApp(home: const POIMapView()));
      await tester.pump();

      // Find the row the two fields are in
      final Row fieldBox = tester.widget(find.descendant(
          of: find.byType(Container), matching: find.byType(Row).first));

      // Verify that it contains exactly 2 children (the two fields)
      expect(fieldBox.children.length, 2);
    });
  });
}
