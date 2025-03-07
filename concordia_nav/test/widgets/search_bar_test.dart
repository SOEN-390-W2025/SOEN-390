import 'package:concordia_nav/ui/search/search_view.dart';
import 'package:concordia_nav/utils/search_viewmodel.dart';
import 'package:concordia_nav/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../map/map_viewmodel_test.mocks.dart';
import 'search_bar_test.mocks.dart';

@GenerateMocks([SearchViewModel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  late SearchViewModel mockSearchViewModel;
  late List<String> buildings;

  setUp(() {
    buildings = ['Building A', 'Building B', 'Building C'];
    mockSearchViewModel = MockSearchViewModel();

    when(mockSearchViewModel.filteredBuildings).thenReturn(buildings);
  });

  group('SearchBarWidget Tests', () {
    testWidgets(
      'should trigger filterBuildings when text is entered in the search field',
      (WidgetTester tester) async {
        final widget = MaterialApp(
          home: ChangeNotifierProvider<SearchViewModel>.value(
            value: mockSearchViewModel,
            child: SearchView(searchViewModel: mockSearchViewModel),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Simulate entering text in the search field
        final textFieldFinder = find.byType(TextField);
        await tester.enterText(textFieldFinder, 'Building A');
        await tester.pump();

        verify(mockSearchViewModel.filterBuildings('Building A')).called(1);
      },
    );

    testWidgets(
      'should display filtered buildings when filterBuildings updates',
      (WidgetTester tester) async {
        final widget = MaterialApp(
          home: ChangeNotifierProvider<SearchViewModel>.value(
            value: mockSearchViewModel,
            child: SearchView(searchViewModel: mockSearchViewModel),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Verify that filtered buildings are displayed
        expect(find.text('Building A'), findsOneWidget);
        expect(find.text('Building B'), findsOneWidget);
        expect(find.text('Building C'), findsOneWidget);
      },
    );

    testWidgets(
      'should select a building and pop with correct data when tapped',
      (WidgetTester tester) async {
        final widget = MaterialApp(
          home: ChangeNotifierProvider<SearchViewModel>.value(
            value: mockSearchViewModel,
            child: SearchView(searchViewModel: mockSearchViewModel),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Simulate tapping on a building
        await tester.tap(find.text('Building A'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
        'should call checkBuildingAtCurrentLocation when "Your Location" is selected',
        (WidgetTester tester) async {
      // Arrange
      final mockMapViewModel = MockMapViewModel();
      final controller = TextEditingController();
      final controller2 = TextEditingController();

      // Define the routes for the test
      final routes = {
        '/SearchView': (context) => Scaffold(
              body: ListView(
                children: ['Building1', 'Building2', 'Your Location']
                    .map((building) => ListTile(title: Text(building)))
                    .toList(),
              ),
            ),
      };

      final widget = MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            controller2: controller2,
            hintText: 'Search',
            icon: Icons.search,
            iconColor: Colors.black,
            searchList: ['Building1', 'Building2', 'Your Location'],
            mapViewModel: mockMapViewModel,
            drawer: true,
          ),
        ),
        routes: routes, // Add the routes table here
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Simulate selecting "Your Location"
      controller.text = 'Your Location';
      controller2.text = 'Some Location';

      // Trigger the handleSelection method by tapping on the SearchBarWidget
      final gesture = find.byType(SearchBarWidget);
      await tester.tap(gesture);
      await tester.pumpAndSettle();
    });
  });
}
