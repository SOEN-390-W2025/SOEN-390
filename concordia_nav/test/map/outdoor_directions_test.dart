import 'package:concordia_nav/data/domain-model/concordia_campus.dart';
import 'package:concordia_nav/data/repositories/map_repository.dart';
import 'package:concordia_nav/data/services/map_service.dart';
import 'package:concordia_nav/utils/map_viewmodel.dart';
import 'package:concordia_nav/widgets/map_layout.dart';
import 'package:concordia_nav/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concordia_nav/ui/outdoor_location/outdoor_location_map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'map_viewmodel_test.mocks.dart';

@GenerateMocks([MapRepository, MapService])
void main() {
  late MapViewModel mapViewModel;
  late MockMapRepository mockMapRepository;
  late MockMapService mockMapService;

  setUp(() {
    mockMapRepository = MockMapRepository();
    mockMapService = MockMapService();
    mapViewModel = MapViewModel(
        mapRepository: mockMapRepository, mapService: mockMapService);
  });

  group('outdoor directions appBar', () {
    testWidgets('appBar has the right title with non-constant key',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(
              key: UniqueKey(), campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Outdoor Directions'), findsOneWidget);
    });

    testWidgets('appBar has the right title', (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Verify that the appBar exists and has the right title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Outdoor Directions'), findsOneWidget);
    });
  });

  group('outdoor directions view page', () {
    testWidgets('mapLayout widget exists', (WidgetTester tester) async {
     // Arrange
      final buildingLocations = [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.7849, -122.4294),
      ];
      final expectedMarkers = {
        Marker(
            markerId: MarkerId(const LatLng(37.7749, -122.4194).toString()),
            position: buildingLocations[0]),
        Marker(
            markerId: MarkerId(const LatLng(37.7849, -122.4294).toString()),
            position: buildingLocations[1]),
      };
      when(mockMapService.getCampusMarkers([])).thenReturn(expectedMarkers);
      when(mockMapRepository.getCameraPosition(ConcordiaCampus.loy)).thenReturn(CameraPosition(target: LatLng(ConcordiaCampus.loy.lat, ConcordiaCampus.loy.lng), zoom: 17.0));
      when(mockMapService.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockMapService.checkAndRequestLocationPermission()).thenAnswer((_) async => true);
      when(mapViewModel.checkLocationAccess()).thenAnswer((_) async => true);
      
      // Build the outdoor directions view widget
      await tester.pumpWidget(MaterialApp(
          home: OutdoorLocationMapView(campus: ConcordiaCampus.loy, mapViewModel: mapViewModel)));
      await tester.pump();
      
      // Verify that MapLayout widget exists
      expect(find.byType(MapLayout), findsOneWidget);

      // find current location button
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('verify two SearchBarWidgets exist',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Verify that two SearchBarWidgets exist
      expect(find.byType(SearchBarWidget), findsNWidgets(2));
    });

    testWidgets('source SearchBarWidget has right icon and hintText',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Find the source searchbarwidget
      final SearchBarWidget sourceWidget = tester.widget(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(SearchBarWidget).first,
        ),
      );

      const expectedIcon = const Icon(Icons.location_on);

      // Verify icon and hintText for the source SearchBar
      expect(sourceWidget.icon, expectedIcon.icon);
      expect(sourceWidget.hintText, 'Your Location');
    });

    testWidgets('destination SearchBarWidget has right icon and hintText',
        (WidgetTester tester) async {
      // Build the outdoor directions view widget
      await tester.pumpWidget(const MaterialApp(
          home: const OutdoorLocationMapView(campus: ConcordiaCampus.sgw)));
      await tester.pump();

      // Find the destination searchbarwidget
      final SearchBarWidget destinationWidget = tester.widget(
        find.descendant(
            of: find.byType(Positioned),
            matching: find.byType(SearchBarWidget).last),
      );

      const expectedIcon =
          const Icon(Icons.location_on, color: const Color(0xFFDA3A16));

      // Verify icon and hintText for the destination SearchBar
      expect(destinationWidget.icon, expectedIcon.icon);
      expect(destinationWidget.iconColor, expectedIcon.color);
      expect(destinationWidget.hintText, 'Enter Destination');
    });
  });
}
