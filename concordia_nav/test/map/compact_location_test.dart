import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/ui/search/search_view.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/widgets/compact_location_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'compact_location_test.mocks.dart';

@GenerateMocks([MapViewModel])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  late MockMapViewModel mockMapViewModel;
  late TextEditingController originController;
  late TextEditingController destinationController;
  late List<String> searchList;
  late CompactSearchCardWidget widget;

  final mockResponse = {
    'polygons': <Polygon>{const Polygon(polygonId: PolygonId('1'))},
    'labels': <Marker>{const Marker(markerId: MarkerId('1'))},
  };

  setUp(() {
    mockMapViewModel = MockMapViewModel();
    originController = TextEditingController();
    destinationController = TextEditingController();
    searchList = ['Hall Building', 'Vanier Library'];

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

    widget = CompactSearchCardWidget(
      originController: originController,
      destinationController: destinationController,
      mapViewModel: mockMapViewModel,
      searchList: searchList,
    );
  });

  tearDown(() {
    originController.dispose();
    destinationController.dispose();
  });

  group('_getDirections', () {
    test('Should not fetch directions if input fields are empty', () async {
      await widget.getDirections();

      verifyNever(mockMapViewModel.fetchRoutesForAllModes(any, any));
    });

    test('Should fetch directions if both origin and destination are provided',
        () async {
      originController.text = 'Building A';
      destinationController.text = 'Building B';

      await widget.getDirections();

      verify(mockMapViewModel.fetchRoutesForAllModes(
              'Building A', 'Building B'))
          .called(1);
    });

    test('Should call onDirectionFetched if directions are fetched', () async {
      bool callbackCalled = false;
      widget = CompactSearchCardWidget(
        originController: originController,
        destinationController: destinationController,
        mapViewModel: mockMapViewModel,
        searchList: searchList,
        onDirectionFetched: () => callbackCalled = true,
      );

      originController.text = 'Building A';
      destinationController.text = 'Building B';

      await widget.getDirections();

      expect(callbackCalled, isTrue);
    });
  });

  group('_handleSelection', () {
    testWidgets('Should update text field when a building is selected',
        (WidgetTester tester) async {
      final mockController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await widget.handleSelection(context, mockController);
                    },
                    child: const Text('Test'),
                  );
                }),
            '/SearchView': (context) {
              return Builder(builder: (context) {
                Future.delayed(Duration.zero, () {
                  // Simulate a selection in SearchView
                  Navigator.pop(context,
                      ['Hall Building', const LatLng(45.458, -73.639)]);
                });
                return SearchView(mapViewModel: mockMapViewModel);
              });
            },
          },
        ),
      );

      // Simulate tapping the button to trigger navigation
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Verify the text field was updated with the selected building
      expect(mockController.text, 'Hall Building');
    });

    testWidgets('Should select a building if drawer mode is enabled',
        (WidgetTester tester) async {
      when(mockMapViewModel.checkBuildingAtCurrentLocation(any))
          .thenAnswer((_) async {});
      when(mockMapViewModel.handleSelection(any, any)).thenAnswer((_) async {});
      when(mockMapViewModel.selectBuilding(any)).thenReturn(null);

      widget = CompactSearchCardWidget(
        originController: originController,
        destinationController: destinationController,
        mapViewModel: mockMapViewModel,
        searchList: searchList,
        drawer: true,
      );

      await tester.pumpWidget(MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Builder(builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    // Call handleSelection directly after navigation
                    await widget.handleSelection(context, originController);
                  },
                  child: const Text('Test'),
                );
              }),
          '/SearchView': (context) {
            return Builder(builder: (context) {
              Future.delayed(Duration.zero, () {
                // Simulate returning a building selection from SearchView
                Navigator.pop(
                    context, ['Hall Building', const LatLng(45.458, -73.639)]);
              });
              return SearchView(mapViewModel: mockMapViewModel);
            });
          },
        },
      ));

      // Simulate tapping the button
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Verify the expected method was called
      verify(mockMapViewModel.selectBuilding(any)).called(1);
    });
  });
}
