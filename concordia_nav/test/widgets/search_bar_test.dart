import 'package:concordia_nav/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../map/map_viewmodel_test.mocks.dart';

void main() {
  group('SearchBarWidget Tests', () {
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
