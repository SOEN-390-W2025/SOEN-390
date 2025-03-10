import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/ui/search/search_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

import 'map_viewmodel_test.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  late MockMapViewModel mockMapViewModel;
  late TextEditingController mockController;
  late TextEditingController mockController2;
  late List<String> mockSearchList;

  final mockResponse = {
    'polygons': <Polygon>{const Polygon(polygonId: PolygonId('1'))},
    'labels': <Marker>{const Marker(markerId: MarkerId('1'))},
  };

  setUp(() {
    mockMapViewModel = MockMapViewModel();
    mockController = TextEditingController();
    mockController2 = TextEditingController();
    mockSearchList = ['Building A', 'Building B', 'Your Location'];

    final double distanceToLoy = (MapViewModel()).getDistance(
        const LatLng(45.458, -73.639),
        LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng));

    when(mockMapViewModel.startShuttleBusTimer()).thenReturn(null);

    when(mockMapViewModel.checkBuildingAtCurrentLocation(any))
        .thenAnswer((_) async {});

    when(mockMapViewModel.checkLocationAccess()).thenAnswer((_) async => true);

    when(mockMapViewModel.fetchCurrentLocation())
        .thenAnswer((_) async => const LatLng(45.458, -73.639)); // Near LOY

    when(mockMapViewModel.getDistance(const LatLng(45.458, -73.639),
            LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng)))
        .thenReturn(distanceToLoy); // Within 1km

    when(mockMapViewModel.getDistance(const LatLng(45.458, -73.639),
            LatLng(ConcordiaCampus.sgw.lat, ConcordiaCampus.sgw.lng)))
        .thenReturn(5000.0); // More than 1km

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.4215, -75.6992), zoom: 10);
    });

    when(mockMapViewModel.getInitialCameraPosition(any)).thenAnswer((_) async {
      return const CameraPosition(target: LatLng(45.458, -73.639), zoom: 10);
    });

    when(mockMapViewModel.getCampusPolygonsAndLabels(ConcordiaCampus.loy))
        .thenAnswer((_) async => mockResponse);
  });

  testWidgets('Should handle selection and update text field',
      (WidgetTester tester) async {
    // Set up the test app with the button and routes
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Trigger handleSelection when the button is pressed
                      await SearchBarWidget(
                        controller: mockController,
                        hintText: 'Search...',
                        icon: Icons.search,
                        iconColor: Colors.black,
                        searchList: mockSearchList,
                        mapViewModel: mockMapViewModel,
                      ).handleSelection(context);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
          '/SearchView': (context) {
            return Builder(
              builder: (context) {
                Future.delayed(Duration.zero, () {
                  // Simulate a selection in SearchView
                  Navigator.pop(context, ['Hall Building', 'Vanier Library']);
                });
                return SearchView(mapViewModel: mockMapViewModel);
              },
            );
          },
        },
      ),
    );

    // Simulate pressing the button to trigger handleSelection
    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    // Verify the text field was updated with the selected building
    expect(mockController.text, 'Hall Building');
  });

  testWidgets('Should select a building in drawer mode',
      (WidgetTester tester) async {
    when(mockMapViewModel.selectBuilding(any)).thenReturn(null);
    when(mockMapViewModel.handleSelection(any, any)).thenAnswer((_) async {});

    // Set up the test app with the button and routes
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Trigger handleSelection when the button is pressed
                      await SearchBarWidget(
                        controller: mockController,
                        hintText: 'Search...',
                        icon: Icons.search,
                        iconColor: Colors.black,
                        searchList: mockSearchList,
                        mapViewModel: mockMapViewModel,
                        drawer: true,
                      ).handleSelection(context);
                    },
                    child: const Text('Test Select Building'),
                  );
                },
              ),
          '/SearchView': (context) {
            return Builder(
              builder: (context) {
                Future.delayed(Duration.zero, () {
                  // Simulate a selection in SearchView
                  Navigator.pop(context,
                      ['Hall Building', const LatLng(45.458, -73.639)]);
                });
                return SearchView(mapViewModel: mockMapViewModel);
              },
            );
          },
        },
      ),
    );

    // Simulate pressing the button to trigger handleSelection
    await tester.tap(find.text('Test Select Building'));
    await tester.pumpAndSettle();

    // Verify that selectBuilding was called once
    verify(mockMapViewModel.selectBuilding(any)).called(1);
  });

  testWidgets('Should fetch directions when a destination is selected',
      (WidgetTester tester) async {
    when(mockMapViewModel.fetchRoutesForAllModes(any, any))
        .thenAnswer((_) async {});

    // Set up the test app with the button and routes
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Set the text for the controllers before triggering getDirections
                      mockController.text = 'Hall Building';
                      mockController2.text = 'Vanier Library';

                      // Trigger getDirections when the button is pressed
                      await SearchBarWidget(
                        controller: mockController,
                        controller2: mockController2,
                        hintText: 'Search...',
                        icon: Icons.search,
                        iconColor: Colors.black,
                        searchList: mockSearchList,
                        mapViewModel: mockMapViewModel,
                      ).getDirections();
                    },
                    child: const Text('Test Get Directions'),
                  );
                },
              ),
          '/SearchView': (context) {
            return Builder(
              builder: (context) {
                Future.delayed(Duration.zero, () {
                  // Simulate a selection in SearchView
                  Navigator.pop(context, ['Hall Building', 'Vanier Library']);
                });
                return SearchView(mapViewModel: mockMapViewModel);
              },
            );
          },
        },
      ),
    );

    // Simulate pressing the button to trigger getDirections
    await tester.tap(find.text('Test Get Directions'));
    await tester.pumpAndSettle();

    // Verify that fetchRoutesForAllModes was called with the correct arguments
    verify(mockMapViewModel.fetchRoutesForAllModes(
            'Hall Building', 'Vanier Library'))
        .called(1);
  });
}
